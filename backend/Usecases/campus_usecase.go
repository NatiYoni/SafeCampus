package usecases

import (
	"context"
	"time"

	domain "github.com/StartUp/safecampus/backend/Domain"
)

type CampusUseCase struct {
	CampusRepo domain.CampusRepository
}

func NewCampusUseCase(campusRepo domain.CampusRepository) *CampusUseCase {
	return &CampusUseCase{
		CampusRepo: campusRepo,
	}
}

func (uc *CampusUseCase) Heartbeat(ctx context.Context, userID string, lat, lng, heading float64, status string) error {
	presence := &domain.CampusPresence{
		UserID:    userID,
		Latitude:  lat,
		Longitude: lng,
		Heading:   heading,
		Status:    status,
		LastSeen:  time.Now(),
	}
	return uc.CampusRepo.UpdatePresence(ctx, presence)
}

func (uc *CampusUseCase) GetCampusStatus(ctx context.Context) ([]*domain.CampusPresence, error) {
	// Considers users active in the last 5 minutes
	threshold := time.Now().Add(-5 * time.Minute)
	return uc.CampusRepo.GetActivePresences(ctx, threshold)
}
