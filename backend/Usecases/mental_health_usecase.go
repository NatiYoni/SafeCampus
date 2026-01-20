package usecases

import (
	"time"

	repositories "github.com/StartUp/safecampus/backend/Repositories"
)

type MentalHealthUsecase struct {
	repo           *repositories.MentalHealthRepository // Using concrete type as interface definition was in domain but not strictly separated here in previous patterns
	contextTimeout time.Duration
}

// Fixed: Import cycle if we use repositories package in usecases signature if domain interface isn't clean.
// Let's stick to domain interfaces if possible, but for now I'll use the interface I defined in domain.go (Wait, I put the interface in domain/mental_health.go but it needs "context").
// Let me fix domain/mental_health.go first to include "context"
