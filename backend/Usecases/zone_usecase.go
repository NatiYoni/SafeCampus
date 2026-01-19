package usecases

import (
	"context"
	"time"

	domain "github.com/StartUp/safecampus/backend/Domain"
)

type ZoneUsecase interface {
	CheckAndNotify(ctx context.Context, userID string, location domain.Location) (*domain.Zone, error)
}

type zoneUsecase struct {
	zoneRepo       domain.ZoneRepository
	contextTimeout time.Duration
}

func NewZoneUsecase(zoneRepo domain.ZoneRepository, timeout time.Duration) ZoneUsecase {
	return &zoneUsecase{
		zoneRepo:       zoneRepo,
		contextTimeout: timeout,
	}
}

func (z *zoneUsecase) CheckAndNotify(ctx context.Context, userID string, location domain.Location) (*domain.Zone, error) {
	ctx, cancel := context.WithTimeout(ctx, z.contextTimeout)
	defer cancel()

	zone, err := z.zoneRepo.CheckContainment(ctx, location)
	if err != nil {
		return nil, err
	}
	if zone != nil {
		// Logic to send push notification to userID
		// triggerNotification(userID, zone.Message)
	}
	return zone, nil
}
