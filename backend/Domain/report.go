package domain

import (
	"time"
)

// ReportCategory defines the category of the tip.
type ReportCategory string

const (
	ReportBullying   ReportCategory = "BULLYING"
	ReportTheft      ReportCategory = "THEFT"
	ReportHarassment ReportCategory = "HARASSMENT"
	ReportHazard     ReportCategory = "HAZARD"
	ReportOther      ReportCategory = "OTHER"
)

// Report represents an anonymous or named tip submitted by a user.
type Report struct {
	ID          string         `json:"id" bson:"_id"`
	UserID      string         `json:"user_id,omitempty" bson:"user_id,omitempty"` // Optional if fully anonymous
	Category    ReportCategory `json:"category" bson:"category"`
	Description string         `json:"description" bson:"description"`
	Attachments []string       `json:"attachments" bson:"attachments"` // URLs to photos/videos
	IsAnonymous bool           `json:"is_anonymous" bson:"is_anonymous"`
	Location    *Location      `json:"location,omitempty" bson:"location,omitempty"`
	Status      string         `json:"status" bson:"status"` // "Pending", "Reviewed", "Resolved"
	CreatedAt   time.Time      `json:"created_at" bson:"created_at"`
	Timestamp   time.Time      `json:"timestamp" bson:"timestamp"` // Added for frontend compatibility
}
