package infrastructure

import (
	"crypto/tls"
	"fmt"
	"os"

	"gopkg.in/gomail.v2"
)

type EmailService struct {
	dialer *gomail.Dialer
}

func NewEmailService() *EmailService {
	// 1. Try Port 465 (SSL) - Alternative if 587 is blocked
	host := os.Getenv("SMTP_HOST")
	port := 465
	user := os.Getenv("SMTP_USER")
	pass := os.Getenv("SMTP_PASS")

	fmt.Printf("Initializing Email Service: Host=%s, Port=%d, User=%s\n", host, port, user)

	d := gomail.NewDialer(host, port, user, pass)
	d.TLSConfig = &tls.Config{InsecureSkipVerify: true} // Allow implicit TLS

	return &EmailService{dialer: d}
}

func (s *EmailService) SendVerificationEmail(toEmail, code string) error {
	fmt.Printf("Attempting to send verification email to %s\n", toEmail)
	m := gomail.NewMessage()
	m.SetHeader("From", os.Getenv("SMTP_USER")) // "SafeCampus <auth@safecampus.com>"
	m.SetHeader("To", toEmail)
	m.SetHeader("Subject", "Safe Campus - Verify Your Email")
	m.SetBody("text/plain", fmt.Sprintf("Your verification code is: %s\n\nIt expires in 15 minutes.", code))

	if err := s.dialer.DialAndSend(m); err != nil {
		fmt.Printf("Failed to send email to %s: %v\n", toEmail, err)
		return fmt.Errorf("failed to send email: %v", err)
	}
	fmt.Printf("Successfully sent verification email to %s\n", toEmail)
	return nil
}
