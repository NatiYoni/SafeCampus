package usecases

import (
	"context"
	"time"

	domain "github.com/StartUp/safecampus/backend/Domain"
)

type MentalHealthUsecase interface {
	GetResources(ctx context.Context) ([]*domain.MentalHealthResource, error)
}

type mentalHealthUsecase struct {
	repo           domain.MentalHealthRepository
	contextTimeout time.Duration
}

func NewMentalHealthUsecase(repo domain.MentalHealthRepository, timeout time.Duration) MentalHealthUsecase {
	return &mentalHealthUsecase{
		repo:           repo,
		contextTimeout: timeout,
	}
}

func (u *mentalHealthUsecase) GetResources(ctx context.Context) ([]*domain.MentalHealthResource, error) {
	ctx, cancel := context.WithTimeout(ctx, u.contextTimeout)
	defer cancel()
	return u.repo.GetAllResources(ctx)
}
