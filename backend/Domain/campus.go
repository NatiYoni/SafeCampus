package domain

import (
	"context"
	"time"
)

type CampusPresence struct {
	UserID     string    `json:"user_id" bson:"user_id"`
	Latitude   float64   `json:"latitude" bson:"latitude"`
	Longitude  float64   `json:"longitude" bson:"longitude"`
	Heading    float64   `json:"heading" bson:"heading"`
	Status     string    `json:"status" bson:"status"` // "safe", "sos", "warning"
	LastSeen   time.Time `json:"last_seen" bson:"last_seen"`
}

type CampusRepository interface {
	UpdatePresence(ctx context.Context, presence *CampusPresence) error
	GetActivePresences(ctx context.Context, since time.Time) ([]*CampusPresence, error)
}
