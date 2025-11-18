package main

import (
	"crypto/rand"
	"crypto/tls"
	"database/sql"
	"encoding/hex"
	"fmt"
	"log"
	"net"
	"net/http"
	"net/smtp"
	"os"
	"regexp"
	"strings"
	"time"

	_ "modernc.org/sqlite"
)

var (
	db *sql.DB

	baseURL    = getEnv("BASE_URL", "")
	dbPath     = getEnv("DB_PATH", "")
	adminEmail = getEnv("ADMIN_EMAIL", "")

	smtpServer = getEnv("SMTP_SERVER", "")
	smtpUser   = getEnv("SMTP_USER", "")
	smtpPass   = getEnv("SMTP_PASS", "")
	fromEmail  = getEnv("FROM_EMAIL", "")

	urlSubscribeSuccess = getEnv("URL_SUBSCRIBE_SUCCESS", "")
	urlConfirmSuccess   = getEnv("URL_CONFIRM_SUCCESS", "")
	urlConfirmError     = getEnv("URL_CONFIRM_ERROR", "")
	urlUnsub            = getEnv("URL_UNSUB", "")
	urlUnsubSuccess     = getEnv("URL_UNSUB_SUCCESS", "")
	urlUnsubError       = getEnv("URL_UNSUB_ERROR", "")
	urlUnsubRequested   = getEnv("URL_UNSUB_REQUESTED", "")

	confirmSubject = getEnv("CONFIRM_SUBJECT", "")
	confirmBody    = getEnv("CONFIRM_BODY", "")

	welcomeSubject = getEnv("WELCOME_SUBJECT", "")
	welcomeBody    = getEnv("WELCOME_BODY", "")

	unsubscribeSubject = getEnv("UNSUBSCRIBE_SUBJECT", "")
	unsubscribeBody    = getEnv("UNSUBSCRIBE_BODY", "")

	unsubscribedSubject = getEnv("UNSUBSCRIBED_SUBJECT", "")
	unsubscribedBody    = getEnv("UNSUBSCRIBED_BODY", "")
)

func main() {
	var err error
	db, err = sql.Open("sqlite", dbPath)
	if err != nil {
		log.Fatal(err)
	}

	createTable()

	// http.HandleFunc("/", formHandler)
	http.HandleFunc("/service/newsletter/subscribe", subscribeHandler)
	http.HandleFunc("/service/newsletter/confirm", confirmHandler)
	http.HandleFunc("/service/newsletter/unsubscribe", unsubscribeHandler)
	http.HandleFunc("/service/newsletter/request-unsubscribe", requestUnsubscribeHandler)

	fmt.Println("Listening on :8388")
	log.Fatal(http.ListenAndServe(":8388", nil))
}

func createTable() {
	_, err := db.Exec(`
	CREATE TABLE IF NOT EXISTS subscribers (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		email TEXT NOT NULL UNIQUE,
		status TEXT NOT NULL CHECK(status IN ('pending','active','unsubscribed')),
		token_confirm TEXT NOT NULL,
		token_unsub TEXT NOT NULL,
		created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
		confirmed_at DATETIME,
		unsubscribed_at DATETIME,
		ip_address TEXT
	)`)
	if err != nil {
		log.Fatal(err)
	}
}

func subscribeHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "only POST", http.StatusMethodNotAllowed)
		return
	}
	email := strings.TrimSpace(strings.ToLower(r.FormValue("email")))
	if !validEmail(email) {
		http.Error(w, "invalid email", 400)
		return
	}

	var currentStatus string
	err := db.QueryRow("SELECT status FROM subscribers WHERE email = ?", email).Scan(&currentStatus)
	if err != nil && err != sql.ErrNoRows {
		// A real db error occurred
		http.Error(w, "db query error", 500)
		log.Println(err)
		return
	}

	// Only send a confirmation email if the user is new or has unsubscribed.
	// For active or pending users, we do nothing but show the same success page
	// to prevent leaking information about who is subscribed.
	if err == sql.ErrNoRows || currentStatus == "unsubscribed" {
		ip := r.Header.Get("X-Real-IP")
		if ip == "" {
			ip, _, _ = net.SplitHostPort(r.RemoteAddr)
		}

		tokenConfirm := genToken()
		tokenUnsub := genToken()

		// upsert: if exists, update tokens & set pending again
		_, err = db.Exec(`
		INSERT INTO subscribers(email, status, token_confirm, token_unsub, ip_address)
		VALUES (?, 'pending', ?, ?, ?)
		ON CONFLICT(email)
		DO UPDATE SET status='pending', token_confirm=excluded.token_confirm, token_unsub=excluded.token_unsub, confirmed_at=NULL, unsubscribed_at=NULL, ip_address=excluded.ip_address
		`, email, tokenConfirm, tokenUnsub, ip)
		if err != nil {
			http.Error(w, "db error", 500)
			log.Println(err)
			return
		}

		// Send confirmation email
		confirmURL := fmt.Sprintf("%s/service/newsletter/confirm?token=%s", baseURL, tokenConfirm)
		err = sendMail(email, confirmSubject, fmt.Sprintf(confirmBody, confirmURL))
		if err != nil {
			http.Error(w, "send error", 500)
			log.Println(err)
			return
		}
	}

	// In all cases, redirect to the same success page to prevent address sniffing.
	http.Redirect(w, r, urlSubscribeSuccess, http.StatusFound)
}

func confirmHandler(w http.ResponseWriter, r *http.Request) {
	token := r.URL.Query().Get("token")
	if token == "" {
		http.Redirect(w, r, urlConfirmError, http.StatusFound)
		return
	}
	res, err := db.Exec(`UPDATE subscribers SET status='active', confirmed_at=? WHERE token_confirm=? AND status='pending'`,
		time.Now(), token)
	if err != nil {
		http.Error(w, "db error", 500)
		return
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		http.Redirect(w, r, urlConfirmError, http.StatusFound)
		return
	}

	var email, ip string
	err = db.QueryRow("SELECT email, ip_address FROM subscribers WHERE token_confirm = ?", token).Scan(&email, &ip)
	if err != nil {
		log.Println("Failed to retrieve email and IP for token", token, ":", err)
		http.Redirect(w, r, urlConfirmError, http.StatusFound)
		return
	}

	// Send welcome email to user
	unsubURL := fmt.Sprintf("%s/%s", baseURL, urlUnsub)
	err = sendMail(email, welcomeSubject, fmt.Sprintf(welcomeBody, unsubURL))
	if err != nil {
		log.Println("Failed to send welcome email to", email, ":", err)
	}

	// Send subscription notification to admin
	if adminEmail != "" {
		adminSubject := fmt.Sprintf("New confirmed subscriber: %s", email)
		adminBody := fmt.Sprintf("Email: %s<br>IP Address: %s", email, ip)
		err = sendMail(adminEmail, adminSubject, adminBody)
		if err != nil {
			log.Println("Failed to send admin notification email:", err)
		}
	}

	http.Redirect(w, r, urlConfirmSuccess, http.StatusFound)
}

func requestUnsubscribeHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "only POST", http.StatusMethodNotAllowed)
		return
	}
	email := strings.TrimSpace(strings.ToLower(r.FormValue("email")))

	var tokenUnsub string
	// We only send the mail if the user is currently active.
	err := db.QueryRow("SELECT token_unsub FROM subscribers WHERE email = ? AND status = 'active'", email).Scan(&tokenUnsub)
	if err == nil { // User found and is active
		unsubURL := fmt.Sprintf("%s/service/newsletter/unsubscribe?token=%s", baseURL, tokenUnsub)
		err = sendMail(email, unsubscribeSubject, fmt.Sprintf(unsubscribeBody, unsubURL))
		if err != nil {
			// Log the error but don't show it to the user, to prevent info leaks.
			log.Println("sendMail error during unsubscribe request:", err)
		}
	} else if err != sql.ErrNoRows {
		log.Println("db.QueryRow error during unsubscribe request:", err)
	}

	// Always redirect to the same page to prevent address sniffing.
	http.Redirect(w, r, urlUnsubRequested, http.StatusFound)
}

func unsubscribeHandler(w http.ResponseWriter, r *http.Request) {
	token := r.URL.Query().Get("token")
	if token == "" {
		http.Redirect(w, r, urlUnsubError, http.StatusFound)
		return
	}
	res, err := db.Exec(`UPDATE subscribers SET status='unsubscribed', unsubscribed_at=? WHERE token_unsub=? AND status='active'`,
		time.Now(), token)
	if err != nil {
		http.Error(w, "db error", 500)
		return
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		http.Redirect(w, r, urlUnsubError, http.StatusFound)
		return
	}

	var email string
	err = db.QueryRow("SELECT email FROM subscribers WHERE token_unsub = ?", token).Scan(&email)
	if err != nil {
		log.Println("Failed to retrieve email for token", token, "during unsubscription:", err)
		// Continue to redirect to success page to avoid leaking information
	} else {

		// Send unsubscribed info to user
		err = sendMail(email, unsubscribedSubject, unsubscribedBody)
		if err != nil {
			// Log the error but don't show it to the user, to prevent info leaks.
			log.Println("sendMail error during unsubscribe request:", err)
		}

		// Send notification to admin
		adminSubject := fmt.Sprintf("Newsletter unsubscription: %s", email)
		adminBody := fmt.Sprintf("<p>Email: %s has unsubscribed.</p>", email)
		err = sendMail(adminEmail, adminSubject, adminBody)
		if err != nil {
			log.Println("Failed to send admin unsubscription notification email:", err)
		}
	}

	http.Redirect(w, r, urlUnsubSuccess, http.StatusFound)
}

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

// === Helpers ===

func genToken() string {
	b := make([]byte, 32)
	_, _ = rand.Read(b)
	return hex.EncodeToString(b)
}

var emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)

func validEmail(e string) bool {
	return emailRegex.MatchString(e)
}

func sendMail(to, subject, body string) error {
	msg := "From: " + fromEmail + "\r\n" +
		"To: " + to + "\r\n" +
		"Subject: " + subject + "\r\n" +
		"MIME-Version: 1.0\r\n" +
		"Content-Type: text/html; charset=UTF-8\r\n\r\n" +
		body

	host, port, _ := net.SplitHostPort(smtpServer)
	auth := smtp.PlainAuth("", smtpUser, smtpPass, host)

	// SMTPS (implicit TLS) for ports 465 and 993
	if port == "465" || port == "993" {
		tlsconfig := &tls.Config{
			// In production, set to false and provide a proper cert pool.
			InsecureSkipVerify: true,
			ServerName:         host,
		}
		conn, err := tls.Dial("tcp", smtpServer, tlsconfig)
		if err != nil {
			return err
		}
		defer conn.Close()
		c, err := smtp.NewClient(conn, host)
		if err != nil {
			return err
		}
		defer c.Close()
		if err = c.Auth(auth); err != nil {
			return err
		}
		if err = c.Mail(fromEmail); err != nil {
			return err
		}
		if err = c.Rcpt(to); err != nil {
			return err
		}
		w, err := c.Data()
		if err != nil {
			return err
		}
		_, err = w.Write([]byte(msg))
		if err != nil {
			return err
		}
		err = w.Close()
		if err != nil {
			return err
		}
		return c.Quit()
	}

	return smtp.SendMail(smtpServer, auth, fromEmail, []string{to}, []byte(msg))
}
