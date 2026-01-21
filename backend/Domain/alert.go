package domain

import (
	"time"
)

// AlertType defines the severity/type of the alert.
type AlertType string

const (
	AlertSOS     AlertType = "SOS"
	AlertManDown AlertType = "MAN_DOWN"
	AlertMedical AlertType = "MEDICAL"
	AlertFire    AlertType = "FIRE"
	AlertFall    AlertType = "FALL"
)

// Alert represents an emergency signal triggered by a user.
type Alert struct {
	ID        string                 `json:"id" bson:"_id"`
	UserID    string                 `json:"user_id" bson:"user_id"`
	UserName  string                 `json:"user_name" bson:"user_name"` // Added user name for easy identification
	Type      AlertType              `json:"type" bson:"type"`
	Status    string                 `json:"status" bson:"status"` // e.g., "Active", "Resolved", "False Alarm"
	Location  Location               `json:"location" bson:"location"`
	Timestamp time.Time              `json:"timestamp" bson:"timestamp"`
	Metadata  map[string]interface{} `json:"metadata,omitempty" bson:"metadata,omitempty"` // Extra info like battery level, etc.
}

// Location represents geospatial coordinates.
type Location struct {
	Latitude  float64   `json:"latitude" bson:"latitude"`
	Longitude float64   `json:"longitude" bson:"longitude"`
	Accuracy  float64   `json:"accuracy,omitempty" bson:"accuracy,omitempty"`
	Floor     int       `json:"floor,omitempty" bson:"floor,omitempty"` // For Indoor Positioning
	Building  string    `json:"building,omitempty" bson:"building,omitempty"`
	Timestamp time.Time `json:"timestamp,omitempty" bson:"timestamp,omitempty"` // Added for tracking paths
}
