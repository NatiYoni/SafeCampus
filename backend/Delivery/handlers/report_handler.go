package handlers

import (
	"net/http"

	domain "github.com/StartUp/safecampus/backend/Domain"
	usecases "github.com/StartUp/safecampus/backend/Usecases"
	"github.com/gin-gonic/gin"
)

type ReportHandler struct {
	ReportUsecase usecases.ReportUsecase
}

func NewReportHandler(r usecases.ReportUsecase) *ReportHandler {
	return &ReportHandler{
		ReportUsecase: r,
	}
}

func (h *ReportHandler) SubmitReport(c *gin.Context) {
	var report domain.Report
	if err := c.ShouldBindJSON(&report); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := h.ReportUsecase.SubmitReport(c, &report); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, report)
}

func (h *ReportHandler) GetReports(c *gin.Context) {
	reports, err := h.ReportUsecase.GetReports(c)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, reports)
}
