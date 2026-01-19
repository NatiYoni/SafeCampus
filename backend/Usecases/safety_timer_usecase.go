package usecases

import (
	"context"
	"time"

	domain "github.com/StartUp/safecampus/backend/Domain"
	"github.com/google/uuid"
)

type SafetyTimerRepository interface {
	Create(ctx context.Context, timer *domain.SafetyTimer) error
	GetByID(ctx context.Context, id string) (*domain.SafetyTimer, error)
	UpdateStatus(ctx context.Context, id string, status domain.TimerStatus) error
}

type SafetyTimerUsecase struct {
	repo           SafetyTimerRepository
	contextTimeout time.Duration
}

func NewSafetyTimerUsecase(repo SafetyTimerRepository, timeout time.Duration) *SafetyTimerUsecase {
	return &SafetyTimerUsecase{
		repo:           repo,
		contextTimeout: timeout,
	}
}

func (uc *SafetyTimerUsecase) SetTimer(ctx context.Context, userID string, durationMinutes int, guardians []string) (*domain.SafetyTimer, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.contextTimeout)
	defer cancel()

	startTime := time.Now()
	endTime := startTime.Add(time.Duration(durationMinutes) * time.Minute)

	timer := &domain.SafetyTimer{
		ID:              uuid.New().String(),
		UserID:          userID,
		Guardians:       guardians,
		StartTime:       startTime,
		DurationMinutes: durationMinutes,
		EndTime:         endTime,
		Status:          domain.TimerActive,
		// Assuming location is optional or passed separately.
		// For simplicity, zero-value location here, or update later.
	}

	err := uc.repo.Create(ctx, timer)
	if err != nil {
		return nil, err
	}
	return timer, nil
}

func (uc *SafetyTimerUsecase) CancelTimer(ctx context.Context, timerID string) error {
	ctx, cancel := context.WithTimeout(ctx, uc.contextTimeout)
	defer cancel()
	return uc.repo.UpdateStatus(ctx, timerID, domain.TimerCancelled)
}
