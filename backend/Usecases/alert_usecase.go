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
	GetAllAlerts(ctx context.Context) ([]*domain.Alert, error)
	GetActiveAlertForUser(ctx context.Context, userID string) (*domain.Alert, error)
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

	user, err := a.userRepo.GetByID(ctx, userID)
	userName := "Unknown"
	universityID := "Unknown"
	if err == nil {
		userName = user.FullName
		universityID = user.UniversityID
	}

	// 1. Remove ANY existing alerts for this user to ensure only one active or inactive record exists
	// This satisfies the requirement: "existing alerts we should remove them and the user should only generate one sos"
	_ = a.alertRepo.DeleteByUserID(ctx, userID)

	// 2. Create new alert
	alert := &domain.Alert{
		ID:           uuid.New().String(),
		UserID:       userID,
		UserName:     userName,
		UniversityID: universityID,
		Type:         domain.AlertSOS,
		Status:       "Active",
		Location:     location,
		Timestamp:    time.Now().UTC(),
	}

	// TODO: Notify guardians/dispatch logic here
	go func() {
		// Simulate async notification
	}()

	err = a.alertRepo.Create(ctx, alert)
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

func (a *alertUsecase) GetAllAlerts(ctx context.Context) ([]*domain.Alert, error) {
	ctx, cancel := context.WithTimeout(ctx, a.contextTimeout)
	defer cancel()
	return a.alertRepo.GetAll(ctx)
}

func (a *alertUsecase) GetActiveAlertForUser(ctx context.Context, userID string) (*domain.Alert, error) {
	ctx, cancel := context.WithTimeout(ctx, a.contextTimeout)
	defer cancel()
	return a.alertRepo.GetByUserID(ctx, userID)
}
