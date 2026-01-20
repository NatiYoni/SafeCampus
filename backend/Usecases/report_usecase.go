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
	contextTimeout time.Duration
}

func NewReportUsecase(reportRepo domain.ReportRepository, timeout time.Duration) ReportUsecase {
	return &reportUsecase{
		reportRepo:     reportRepo,
		contextTimeout: timeout,
	}
}

func (r *reportUsecase) SubmitReport(ctx context.Context, report *domain.Report) error {
	ctx, cancel := context.WithTimeout(ctx, r.contextTimeout)
	defer cancel()

	report.ID = uuid.New().String()
	report.CreatedAt = time.Now()
	report.Status = "Pending"

	return r.reportRepo.Create(ctx, report)
}

func (r *reportUsecase) GetReports(ctx context.Context) ([]*domain.Report, error) {
	ctx, cancel := context.WithTimeout(ctx, r.contextTimeout)
	defer cancel()
	return r.reportRepo.FetchAll(ctx, nil)
}
