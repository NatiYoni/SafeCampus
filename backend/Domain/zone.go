package domain

import "time"

// Zone represents a geofenced area on campus.
type Zone struct {
	ID          string     `json:"id" bson:"_id"`
	Name        string     `json:"name" bson:"name"`
	Description string     `json:"description" bson:"description"`
	Coordinates []Location `json:"coordinates" bson:"coordinates"` // Polygon points
	RiskLevel   string     `json:"risk_level" bson:"risk_level"`   // "High", "Medium", "Safe"
	Message     string     `json:"message" bson:"message"`         // Message to send upon entry
}

// Notification represents a push notification payload.
type Notification struct {
	ID     string    `json:"id" bson:"_id"`
	UserID string    `json:"user_id,omitempty" bson:"user_id,omitempty"` // Null if broadcast
	Title  string    `json:"title" bson:"title"`
	Body   string    `json:"body" bson:"body"`
	ZoneID string    `json:"zone_id,omitempty" bson:"zone_id,omitempty"` // If triggered by zone
	SentAt time.Time `json:"sent_at" bson:"sent_at"`
}
