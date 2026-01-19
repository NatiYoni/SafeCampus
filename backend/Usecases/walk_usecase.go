package usecases

import (
	"context"
	"time"

	domain "github.com/StartUp/safecampus/backend/Domain"
	"github.com/google/uuid"
)

type WalkUseCase struct {
	WalkRepo domain.WalkRepository
}

func NewWalkUseCase(walkRepo domain.WalkRepository) *WalkUseCase {
	return &WalkUseCase{
		WalkRepo: walkRepo,
	}
}

func (uc *WalkUseCase) StartWalk(ctx context.Context, walkerID string, guardianID string) (*domain.WalkSession, error) {
	session := &domain.WalkSession{
		ID:         uuid.New().String(),
		WalkerID:   walkerID,
		GuardianID: guardianID,
		StartTime:  time.Now(),
		Status:     "active",
		Path:       make([]domain.Location, 0),
	}
	err := uc.WalkRepo.Create(ctx, session)
	if err != nil {
		return nil, err
	}
	return session, nil
}

func (uc *WalkUseCase) UpdateLocation(ctx context.Context, walkID string, lat float64, lng float64) error {
	loc := domain.Location{
		Latitude:  lat,
		Longitude: lng,
		Timestamp: time.Now(),
	}
	return uc.WalkRepo.UpdateLocation(ctx, walkID, loc)
}

func (uc *WalkUseCase) EndWalk(ctx context.Context, walkID string) error {
	return uc.WalkRepo.EndWalk(ctx, walkID)
}
