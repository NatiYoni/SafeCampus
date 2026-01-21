package usecases

import (
	"context"
	"time"

	domain "github.com/StartUp/safecampus/backend/Domain"
	"github.com/google/uuid"
)

// ReportUsecase defines the business logic for incident reporting.
type ReportUsecase interface {
	SubmitReport(ctx context.Context, report *domain.Report) error
	GetReports(ctx context.Context) ([]*domain.Report, error)
}

type reportUsecase struct {
	reportRepo     domain.ReportRepository
	userRepo       domain.UserRepository // Added to fetch user name
	contextTimeout time.Duration
}

func NewReportUsecase(reportRepo domain.ReportRepository, userRepo domain.UserRepository, timeout time.Duration) ReportUsecase {
	return &reportUsecase{
		reportRepo:     reportRepo,
		userRepo:       userRepo,
		contextTimeout: timeout,
	}
}

func (r *reportUsecase) SubmitReport(ctx context.Context, report *domain.Report) error {
	ctx, cancel := context.WithTimeout(ctx, r.contextTimeout)
	defer cancel()

	if !report.IsAnonymous && report.UserID != "" {
		user, err := r.userRepo.GetByID(ctx, report.UserID)
		if err == nil && user != nil {
			report.UserName = user.FullName
		}
	}

	report.ID = uuid.New().String()
	report.CreatedAt = time.Now()
	report.Timestamp = time.Now() // Ensure Timestamp is also set for frontend compatibility
	report.Status = "Pending"


	return r.reportRepo.Create(ctx, report)
}

func (r *reportUsecase) GetReports(ctx context.Context) ([]*domain.Report, error) {
	ctx, cancel := context.WithTimeout(ctx, r.contextTimeout)
	defer cancel()
	return r.reportRepo.FetchAll(ctx, nil)
}
