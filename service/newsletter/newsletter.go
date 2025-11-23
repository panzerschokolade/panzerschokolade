package newsletter

import (
	"crypto/rand"
	"crypto/tls"
	"database/sql"
	"encoding/hex"
	"fmt"
	"log"
	"net"
	"net/smtp"
	"os"
	"regexp"
	"time"

	_ "modernc.org/sqlite"
)

type Config struct {
	BaseURL             string
	DBPath              string
	AdminEmail          string
	SMTPServer          string
	SMTPUser            string
	SMTPPass            string
	FromEmail           string
	URLSubscribeSuccess string
	URLConfirmSuccess   string
	URLConfirmError     string
	URLUnsub            string
	URLUnsubSuccess     string
	URLUnsubError       string
	URLUnsubRequested   string
	ConfirmSubject      string
	ConfirmBody         string
	WelcomeSubject      string
	WelcomeBody         string
	UnsubscribeSubject  string
	UnsubscribeBody     string
	UnsubscribedSubject string
	UnsubscribedBody    string
}

type Service struct {
	db  *sql.DB
	cfg *Config
}

func NewConfig() *Config {
	return &Config{
		BaseURL:             getEnv("BASE_URL", ""),
		DBPath:              getEnv("DB_PATH", ""),
		AdminEmail:          getEnv("ADMIN_EMAIL", ""),
		SMTPServer:          getEnv("SMTP_SERVER", ""),
		SMTPUser:            getEnv("SMTP_USER", ""),
		SMTPPass:            getEnv("SMTP_PASS", ""),
		FromEmail:           getEnv("FROM_EMAIL", ""),
		URLSubscribeSuccess: getEnv("URL_SUBSCRIBE_SUCCESS", ""),
		URLConfirmSuccess:   getEnv("URL_CONFIRM_SUCCESS", ""),
		URLConfirmError:     getEnv("URL_CONFIRM_ERROR", ""),
		URLUnsub:            getEnv("URL_UNSUB", ""),
		URLUnsubSuccess:     getEnv("URL_UNSUB_SUCCESS", ""),
		URLUnsubError:       getEnv("URL_UNSUB_ERROR", ""),
		URLUnsubRequested:   getEnv("URL_UNSUB_REQUESTED", ""),
		ConfirmSubject:      getEnv("CONFIRM_SUBJECT", ""),
		ConfirmBody:         getEnv("CONFIRM_BODY", ""),
		WelcomeSubject:      getEnv("WELCOME_SUBJECT", ""),
		WelcomeBody:         getEnv("WELCOME_BODY", ""),
		UnsubscribeSubject:  getEnv("UNSUBSCRIBE_SUBJECT", ""),
		UnsubscribeBody:     getEnv("UNSUBSCRIBE_BODY", ""),
		UnsubscribedSubject: getEnv("UNSUBSCRIBED_SUBJECT", ""),
		UnsubscribedBody:    getEnv("UNSUBSCRIBED_BODY", ""),
	}
}

func NewService(cfg *Config) (*Service, error) {
	db, err := sql.Open("sqlite", cfg.DBPath)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}
	service := &Service{db: db, cfg: cfg}
	if err := service.createTable(); err != nil {
		return nil, fmt.Errorf("failed to create database table: %w", err)
	}
	return service, nil
}

func (s *Service) createTable() error {
	_, err := s.db.Exec(`
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
	return err
}

func (s *Service) Subscribe(email, ipAddress string) error {
	if !validEmail(email) {
		return fmt.Errorf("invalid email format")
	}
	var currentStatus string
	err := s.db.QueryRow("SELECT status FROM subscribers WHERE email = ?", email).Scan(&currentStatus)
	if err != nil && err != sql.ErrNoRows {
		log.Println(err)
		return fmt.Errorf("database query failed")
	}
	if err == sql.ErrNoRows || currentStatus == "unsubscribed" {
		tokenConfirm := genToken()
		tokenUnsub := genToken()
		_, err = s.db.Exec(`
		INSERT INTO subscribers(email, status, token_confirm, token_unsub, ip_address)
		VALUES (?, 'pending', ?, ?, ?)
		ON CONFLICT(email)
		DO UPDATE SET status='pending', token_confirm=excluded.token_confirm, token_unsub=excluded.token_unsub, confirmed_at=NULL, unsubscribed_at=NULL, ip_address=excluded.ip_address
		`, email, tokenConfirm, tokenUnsub, ipAddress)
		if err != nil {
			log.Println(err)
			return fmt.Errorf("database insert/update failed")
		}
		confirmURL := fmt.Sprintf("%s/service/newsletter/confirm?token=%s", s.cfg.BaseURL, tokenConfirm)
		err = s.sendMail(email, s.cfg.ConfirmSubject, fmt.Sprintf(s.cfg.ConfirmBody, confirmURL))
		if err != nil {
			log.Println(err)
			return fmt.Errorf("sending confirmation email failed")
		}
	}
	return nil
}

// Confirm activates a subscription using a confirmation token.
func (s *Service) Confirm(token string) error {
	res, err := s.db.Exec(`UPDATE subscribers SET status='active', confirmed_at=? WHERE token_confirm=? AND status='pending'`,
		time.Now(), token)
	if err != nil {
		log.Println("db error during confirmation:", err)
		return fmt.Errorf("database update failed")
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		return fmt.Errorf("no pending subscription found for this token")
	}

	var email, ip string
	err = s.db.QueryRow("SELECT email, ip_address FROM subscribers WHERE token_confirm = ?", token).Scan(&email, &ip)
	if err != nil {
		log.Println("Failed to retrieve email and IP for token", token, ":", err)
		return fmt.Errorf("could not retrieve subscriber details")
	}

	// Send welcome email to user
	unsubURL := fmt.Sprintf("%s/%s", s.cfg.BaseURL, s.cfg.URLUnsub)
	err = s.sendMail(email, s.cfg.WelcomeSubject, fmt.Sprintf(s.cfg.WelcomeBody, unsubURL))
	if err != nil {
		log.Println("Failed to send welcome email to", email, ":", err)
	}

	// Send subscription notification to admin
	if s.cfg.AdminEmail != "" {
		adminSubject := fmt.Sprintf("New confirmed subscriber: %s", email)
		adminBody := fmt.Sprintf("Email: %s<br>IP Address: %s", email, ip)
		err = s.sendMail(s.cfg.AdminEmail, adminSubject, adminBody)
		if err != nil {
			log.Println("Failed to send admin notification email:", err)
		}
	}
	return nil
}

// RequestUnsubscribe sends an email to an active subscriber with a link to unsubscribe.
func (s *Service) RequestUnsubscribe(email string) {
	var tokenUnsub string
	err := s.db.QueryRow("SELECT token_unsub FROM subscribers WHERE email = ? AND status = 'active'", email).Scan(&tokenUnsub)
	if err == nil { // User found and is active
		unsubURL := fmt.Sprintf("%s/service/newsletter/unsubscribe?token=%s", s.cfg.BaseURL, tokenUnsub)
		err = s.sendMail(email, s.cfg.UnsubscribeSubject, fmt.Sprintf(s.cfg.UnsubscribeBody, unsubURL))
		if err != nil {
			log.Println("sendMail error during unsubscribe request:", err)
		}
	} else if err != sql.ErrNoRows {
		log.Println("db.QueryRow error during unsubscribe request:", err)
	}
	// We don't return errors to the handler to prevent leaking information.
}

// Unsubscribe deactivates a subscription using an unsubscribe token.
func (s *Service) Unsubscribe(token string) error {
	res, err := s.db.Exec(`UPDATE subscribers SET status='unsubscribed', unsubscribed_at=? WHERE token_unsub=? AND status='active'`,
		time.Now(), token)
	if err != nil {
		log.Println("db error during unsubscription:", err)
		return fmt.Errorf("database update failed")
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		return fmt.Errorf("no active subscription found for this token")
	}

	var email string
	err = s.db.QueryRow("SELECT email FROM subscribers WHERE token_unsub = ?", token).Scan(&email)
	if err != nil {
		log.Println("Failed to retrieve email for token", token, "during unsubscription:", err)
		// Don't return error here, proceed with success redirect.
	} else {
		// Send unsubscribed info to user
		err = s.sendMail(email, s.cfg.UnsubscribedSubject, s.cfg.UnsubscribedBody)
		if err != nil {
			log.Println("sendMail error during unsubscribe confirmation:", err)
		}

		// Send notification to admin
		if s.cfg.AdminEmail != "" {
			adminSubject := fmt.Sprintf("Newsletter unsubscription: %s", email)
			adminBody := fmt.Sprintf("<p>Email: %s has unsubscribed.</p>", email)
			err = s.sendMail(s.cfg.AdminEmail, adminSubject, adminBody)
			if err != nil {
				log.Println("Failed to send admin unsubscription notification email:", err)
			}
		}
	}
	return nil
}

// --- Helpers ---

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

func genToken() string {
	b := make([]byte, 32)
	_, _ = rand.Read(b)
	return hex.EncodeToString(b)
}

var emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)

func validEmail(e string) bool {
	return emailRegex.MatchString(e)
}

func (s *Service) sendMail(to, subject, body string) error {
	msg := "From: " + s.cfg.FromEmail + "\r\n" +
		"To: " + to + "\r\n" +
		"Subject: " + subject + "\r\n" +
		"MIME-Version: 1.0\r\n" +
		"Content-Type: text/html; charset=UTF-8\r\n\r\n" +
		body
	host, port, _ := net.SplitHostPort(s.cfg.SMTPServer)
	auth := smtp.PlainAuth("", s.cfg.SMTPUser, s.cfg.SMTPPass, host)
	if port == "465" || port == "993" {
		tlsconfig := &tls.Config{
			InsecureSkipVerify: true, // In production, set to false
			ServerName:         host,
		}
		conn, err := tls.Dial("tcp", s.cfg.SMTPServer, tlsconfig)
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
		if err = c.Mail(s.cfg.FromEmail); err != nil {
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
	return smtp.SendMail(s.cfg.SMTPServer, auth, s.cfg.FromEmail, []string{to}, []byte(msg))
}
