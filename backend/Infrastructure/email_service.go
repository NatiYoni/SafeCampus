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
	host := os.Getenv("SMTP_HOST")
	port := 587 // Default for Gmail/Sendgrid
	user := os.Getenv("SMTP_USER")
	pass := os.Getenv("SMTP_PASS")

	d := gomail.NewDialer(host, port, user, pass)
	d.TLSConfig = &tls.Config{InsecureSkipVerify: true} // For development; remove in prod if possible

	return &EmailService{dialer: d}
}

func (s *EmailService) SendVerificationEmail(toEmail, code string) error {
	m := gomail.NewMessage()
	m.SetHeader("From", os.Getenv("SMTP_USER")) // "SafeCampus <auth@safecampus.com>"
	m.SetHeader("To", toEmail)
	m.SetHeader("Subject", "Safe Campus - Verify Your Email")
	m.SetBody("text/plain", fmt.Sprintf("Your verification code is: %s\n\nIt expires in 15 minutes.", code))

	if err := s.dialer.DialAndSend(m); err != nil {
		return fmt.Errorf("failed to send email: %v", err)
	}
	return nil
}
