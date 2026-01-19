package domain

import (
	"context"
	"time"
)

type WalkSession struct {
	ID         string     `json:"id"`
	WalkerID   string     `json:"walker_id"`
	GuardianID string     `json:"guardian_id"`
	StartTime  time.Time  `json:"start_time"`
	EndTime    time.Time  `json:"end_time,omitempty"`
	Status     string     `json:"status"` // "active", "completed", "cancelled"
	Path       []Location `json:"path"`   // History of locations
	CurrentLoc Location   `json:"current_location"`
}

type WalkRepository interface {
	Create(ctx context.Context, session *WalkSession) error
	GetByID(ctx context.Context, id string) (*WalkSession, error)
	UpdateLocation(ctx context.Context, id string, location Location) error
	EndWalk(ctx context.Context, id string) error
	GetActiveWalksByGuardian(ctx context.Context, guardianID string) ([]*WalkSession, error)
}
