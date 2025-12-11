package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"strings"

	"panzerschokolade/service/newsletter"
)

func main() {
	addr := flag.String("addr", ":8388", "host address")
	flag.Parse()

	cfg := newsletter.NewConfig()

	// Create a new newsletter service instance
	newsSvc, err := newsletter.NewService(cfg)
	if err != nil {
		log.Fatalf("Failed to initialize newsletter service: %v", err)
	}
	h := &handler{
		newsSvc: newsSvc,
		cfg:     cfg,
	}
	http.HandleFunc("/service/newsletter/subscribe", h.subscribe)
	http.HandleFunc("/service/newsletter/confirm", h.confirm)
	http.HandleFunc("/service/newsletter/unsubscribe", h.unsubscribe)
	http.HandleFunc("/service/newsletter/request-unsubscribe", h.requestUnsubscribe)

	http.HandleFunc("/service/live", HandleLiveStream)

	fmt.Println("Starting service on:", *addr)
	log.Fatal(http.ListenAndServe(*addr, nil))
}

type handler struct {
	newsSvc *newsletter.Service
	cfg     *newsletter.Config
}

func (h *handler) subscribe(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "only POST", http.StatusMethodNotAllowed)
		return
	}
	email := strings.TrimSpace(strings.ToLower(r.FormValue("email")))

	ip := r.Header.Get("X-Real-IP")
	if ip == "" {
		ip, _, _ = net.SplitHostPort(r.RemoteAddr)
	}

	if err := h.newsSvc.Subscribe(email, ip); err != nil {
		// Log the specific error but return a generic message to the user
		// for invalid email format. For other errors, the service logs them.
		if err.Error() == "invalid email format" {
			http.Error(w, "invalid email", http.StatusBadRequest)
			return
		}
		// For other errors, we still redirect to prevent information leakage.
	}

	// In all cases, redirect to the same success page to prevent address sniffing.
	http.Redirect(w, r, h.cfg.URLSubscribeSuccess, http.StatusFound)
}

func (h *handler) confirm(w http.ResponseWriter, r *http.Request) {
	token := r.URL.Query().Get("token")
	if token == "" {
		http.Redirect(w, r, h.cfg.URLConfirmError, http.StatusFound)
		return
	}

	if err := h.newsSvc.Confirm(token); err != nil {
		// The service layer logs the details. We just redirect.
		http.Redirect(w, r, h.cfg.URLConfirmError, http.StatusFound)
		return
	}

	http.Redirect(w, r, h.cfg.URLConfirmSuccess, http.StatusFound)
}

func (h *handler) requestUnsubscribe(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "only POST", http.StatusMethodNotAllowed)
		return
	}
	email := strings.TrimSpace(strings.ToLower(r.FormValue("email")))

	// The service layer handles all logic, including error logging.
	// We don't check for errors here to prevent leaking information about
	// which email addresses are subscribed.
	h.newsSvc.RequestUnsubscribe(email)

	// Always redirect to the same page.
	http.Redirect(w, r, h.cfg.URLUnsubRequested, http.StatusFound)
}

func (h *handler) unsubscribe(w http.ResponseWriter, r *http.Request) {
	token := r.URL.Query().Get("token")
	if token == "" {
		http.Redirect(w, r, h.cfg.URLUnsubError, http.StatusFound)
		return
	}
	if err := h.newsSvc.Unsubscribe(token); err != nil {
		http.Redirect(w, r, h.cfg.URLUnsubError, http.StatusFound)
		return
	}
	http.Redirect(w, r, h.cfg.URLUnsubSuccess, http.StatusFound)
}
