package domain

import (
	"context"
)

// UserRepository defines the interface for user persistence.
type UserRepository interface {
	Create(ctx context.Context, user *User) error
	GetByID(ctx context.Context, id string) (*User, error)
	GetByEmail(ctx context.Context, email string) (*User, error)
	GetByPhoneNumber(ctx context.Context, phone string) (*User, error)
	Update(ctx context.Context, user *User) error
	UpdateLocation(ctx context.Context, userID string, location Location) error
	UpdateRole(ctx context.Context, userID string, role Role) error
}

// InvitationRepository defines the interface for invitation persistence.
type InvitationRepository interface {
	Create(ctx context.Context, invitation *Invitation) error
	GetByToken(ctx context.Context, token string) (*Invitation, error)
	GetByEmail(ctx context.Context, email string) (*Invitation, error)
	MarkAsUsed(ctx context.Context, id string) error
}

// AlertRepository defines the interface for alert persistence.
type AlertRepository interface {
	Create(ctx context.Context, alert *Alert) error
	GetByID(ctx context.Context, id string) (*Alert, error)
	GetActiveByUserID(ctx context.Context, userID string) ([]*Alert, error)
	GetAll(ctx context.Context) ([]*Alert, error)
	UpdateStatus(ctx context.Context, id string, status string) error
	FetchNearby(ctx context.Context, loc Location, radius float64) ([]*Alert, error)
}

// ReportRepository defines the interface for report persistence.
type ReportRepository interface {
	Create(ctx context.Context, report *Report) error
	GetByID(ctx context.Context, id string) (*Report, error)
	FetchAll(ctx context.Context, filter map[string]interface{}) ([]*Report, error)
}

// ChatRepository defines the interface for chat persistence.
type ChatRepository interface {
	SaveMessage(ctx context.Context, msg *Message) error
	GetMessagesByReportID(ctx context.Context, reportID string) ([]*Message, error)
}

// ZoneRepository defines the interface for zone management.
type ZoneRepository interface {
	Create(ctx context.Context, zone *Zone) error
	GetAll(ctx context.Context) ([]*Zone, error)
	CheckContainment(ctx context.Context, loc Location) (*Zone, error) // Returns zone if loc is inside
}

// SafetyTimerRepository defines the interface for SAFETY timer persistence.
type SafetyTimerRepository interface {
	Create(ctx context.Context, timer *SafetyTimer) error
	GetByID(ctx context.Context, id string) (*SafetyTimer, error)
	UpdateStatus(ctx context.Context, id string, status TimerStatus) error
	GetActiveByUserID(ctx context.Context, userID string) (*SafetyTimer, error)
}

// MentalHealthRepository defines the interface for mental health resources.
type MentalHealthRepository interface {
	GetAllResources(ctx context.Context) ([]*MentalHealthResource, error)
}
