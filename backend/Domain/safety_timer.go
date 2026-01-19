package domain

import (
	"time"
)

// TimerStatus represents the state of a safety timer.
type TimerStatus string

const (
	TimerActive    TimerStatus = "ACTIVE"
	TimerFinished  TimerStatus = "FINISHED"
	TimerExpired   TimerStatus = "EXPIRED" // Triggered alert
	TimerCancelled TimerStatus = "CANCELLED"
)

// SafetyTimer represents a "Virtual Escort" session.
type SafetyTimer struct {
	ID              string      `json:"id" bson:"_id"`
	UserID          string      `json:"user_id" bson:"user_id"`
	Guardians       []string    `json:"guardians" bson:"guardians"` // List of Contact IDs or Phone Numbers
	StartTime       time.Time   `json:"start_time" bson:"start_time"`
	DurationMinutes int         `json:"duration_minutes" bson:"duration_minutes"`
	EndTime         time.Time   `json:"end_time" bson:"end_time"` // Calculated end time
	Status          TimerStatus `json:"status" bson:"status"`
	StartLocation   Location    `json:"start_location" bson:"start_location"`
	LastLocation    Location    `json:"last_location" bson:"last_location"`
}
