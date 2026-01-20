package main

import (
	"fmt"

	"gopkg.in/gomail.v2"
)

func main() {
	// 1. HARDCODE YOUR CREDENTIALS HERE FOR TESTING
	// (Don't commit this file with real passwords!)
	host := "smtp.gmail.com"
	port := 465 // Try SSL port
	user := "YOUR_EMAIL@gmail.com"
	pass := "YOUR_APP_PASSWORD"             
	toEmail := "RECIPIENT_EMAIL@gmail.com"
	m.SetHeader("To", toEmail)
	m.SetHeader("Subject", "Test Email from SafeCampus (SSL)")
	m.SetBody("text/plain", "If you satisfy this message, your SMTP settings are correct!")

	d := gomail.NewDialer(host, port, user, pass)
	d.SSL = true // Enable implicit SSL

	if err := d.DialAndSend(m); err != nil {
		fmt.Printf("❌ FAILED: %v\n", err)
	} else {
		fmt.Println("✅ SUCCESS! Email sent successfully.")
	}
}
