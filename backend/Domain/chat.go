package domain

import "time"

// Message represents a single message in a confidential chat.
type Message struct {
	ID        string    `json:"id" bson:"_id"`
	ReportID  string    `json:"report_id" bson:"report_id"` // Linked to a specific report
	SenderID  string    `json:"sender_id" bson:"sender_id"` // UserID or "DISPATCH"
	Content   string    `json:"content" bson:"content"`
	Timestamp time.Time `json:"timestamp" bson:"timestamp"`
	IsRead    bool      `json:"is_read" bson:"is_read"`
}

// ChatSession represents the metadata of a conversation.
type ChatSession struct {
	ReportID   string    `json:"report_id" bson:"_id"`
	UserAnonID string    `json:"user_anon_id" bson:"user_anon_id"` // Encrypted/Hashed ID for anonymity
	IsActive   bool      `json:"is_active" bson:"is_active"`
	CreatedAt  time.Time `json:"created_at" bson:"created_at"`
}
