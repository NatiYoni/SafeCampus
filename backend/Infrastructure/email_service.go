package infrastructure

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
)

type EmailService struct {
	apiKey    string
	fromEmail string
}

func NewEmailService() *EmailService {
	// BREVO (Sendinblue) Configuration
	apiKey := os.Getenv("BREVO_API_KEY")
	fromEmail := os.Getenv("BREVO_FROM_EMAIL")

	if apiKey == "" {
		fmt.Println("Warning: BREVO_API_KEY is not set. Switching to Console/Mock mode.")
	}

	return &EmailService{
		apiKey:    apiKey,
		fromEmail: fromEmail,
	}
}

func (s *EmailService) SendVerificationEmail(toEmail, code string) error {
	// 1. Mock Mode (If no Key provided)
	if s.apiKey == "" {
		fmt.Println("\n==================================================")
		fmt.Printf(" [MOCK EMAIL] Verification Code for %s: %s\n", toEmail, code)
		fmt.Println("==================================================\n")
		return nil
	}

	// 2. Real Send via Brevo API (HTTP Post)
	url := "https://api.brevo.com/v3/smtp/email"

	senderEmail := s.fromEmail
	if senderEmail == "" {
		senderEmail = "no-reply@safecampus.com" // Default if not set
	}

	payload := map[string]interface{}{
		"sender": map[string]string{
			"name":  "SafeCampus Security",
			"email": senderEmail,
		},
		"to": []map[string]string{
			{"email": toEmail},
		},
		"subject": "SafeCampus Verification Code",
		"htmlContent": fmt.Sprintf(
			"<h3>Verify your SafeCampus Account</h3><p>Your code is: <strong>%s</strong></p><p>This code expires in 15 minutes.</p>",
			code,
		),
	}

	jsonPayload, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonPayload))
	if err != nil {
		return err
	}

	req.Header.Set("accept", "application/json")
	req.Header.Set("api-key", s.apiKey)
	req.Header.Set("content-type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("Failed to connect to Brevo: %v\n", err)
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 200 && resp.StatusCode < 300 {
		fmt.Printf("Successfully sent email to %s via Brevo\n", toEmail)
		return nil
	}

	// Read error body for debugging
	buf := new(bytes.Buffer)
	buf.ReadFrom(resp.Body)
	fmt.Printf("Brevo API Error (Status %d): %s\n", resp.StatusCode, buf.String())
	return fmt.Errorf("brevo api error: %d", resp.StatusCode)
}
