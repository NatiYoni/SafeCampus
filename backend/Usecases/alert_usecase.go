package usecases

import (
	"context"
	"time"

	domain "github.com/StartUp/safecampus/backend/Domain"
	"github.com/google/uuid"
)

// AlertUsecase defines the business logic for emergency alerts.
type AlertUsecase interface {
	TriggerSOS(ctx context.Context, userID string, location domain.Location) (*domain.Alert, error)
	UpdateLocation(ctx context.Context, alertID string, location domain.Location) error
	ResolveAlert(ctx context.Context, alertID string) error
}

type alertUsecase struct {
	alertRepo      domain.AlertRepository
	userRepo       domain.UserRepository // To fetch user details for dispatch
	contextTimeout time.Duration
}

func NewAlertUsecase(alertRepo domain.AlertRepository, userRepo domain.UserRepository, timeout time.Duration) AlertUsecase {
	return &alertUsecase{
		alertRepo:      alertRepo,
		userRepo:       userRepo,
		contextTimeout: timeout,
	}
}

func (a *alertUsecase) TriggerSOS(ctx context.Context, userID string, location domain.Location) (*domain.Alert, error) {
	ctx, cancel := context.WithTimeout(ctx, a.contextTimeout)
	defer cancel()

	alert := &domain.Alert{
		ID:        uuid.New().String(),
		UserID:    userID,
		Type:      domain.AlertSOS,
		Status:    "Active",
		Location:  location,
		Timestamp: time.Now(),
	}

	// TODO: Notify guardians/dispatch logic here
	// Simulating notification to guardians/security
	// In a real app, this would use FCM, SMS (Twilio), or WebSocket
	go func() {
		// Simulate async notification
		// log.Printf("ALARM: SOS Triggered by User %s at %v", userID, location)
		// SendWSNotification(userID, "SOS")
	}()

	err := a.alertRepo.Create(ctx, alert)
	return alert, err
}

func (a *alertUsecase) UpdateLocation(ctx context.Context, alertID string, location domain.Location) error {
	// Logic to update live tracking
	return nil
}

func (a *alertUsecase) ResolveAlert(ctx context.Context, alertID string) error {
	ctx, cancel := context.WithTimeout(ctx, a.contextTimeout)
	defer cancel()
	return a.alertRepo.UpdateStatus(ctx, alertID, "Resolved")
}
