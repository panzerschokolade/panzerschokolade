package main

import (
	"log"
	"net/http"
	"os"
)

func HandleLiveStream(w http.ResponseWriter, r *http.Request) {
	streamKey, ok := os.LookupEnv("LIVE_STREAM_KEY")
	if !ok {
		log.Println("FATAL: LIVE_STREAM_KEY environment variable not set")
		http.Error(w, "Server configuration error", http.StatusInternalServerError)
		return
	}
	if r.Method != http.MethodPost {
		http.Error(w, "only POST", http.StatusMethodNotAllowed)
		return
	}
	if err := r.ParseForm(); err != nil {
		log.Printf("Error parsing live strewam form: %v", err)
		http.Error(w, "Failed to parse form", http.StatusBadRequest)
		return
	}
	//		streamName := r.Form.Get("name")
	//		var key string
	//		if parts := strings.SplitN(streamName, "?", 2); len(parts) == 2 {
	//			query, err := url.ParseQuery(parts[1])
	//			if err == nil {
	//				key = query.Get("key")
	//			}
	//		}
	key := r.Form.Get("key")
	if key != streamKey {
		log.Printf("Unauthorized stream key")
		w.WriteHeader(http.StatusUnauthorized)
		return
	}
	log.Printf("Live stream authorized")
	w.WriteHeader(http.StatusOK)
}
