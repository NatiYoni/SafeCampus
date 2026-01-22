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

	// Override UserID from context (Token) to ensure authenticity
	// unless completely anonymous where we might want to respect that?
	// But binding usually captures JSON. Let's ensure we use the authenticated user's ID
	// if the token is present, even if they mark it anonymous (for internal tracking if law requires)
	// OR if we purely trust "is_anonymous" to scrub it.
	// Current requirement: "If user is not anonymous he sends the data... if anonymous print message [no name]"
	
	userID := c.GetString("user_id")
	if userID != "" {
		report.UserID = userID
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

func (h *ReportHandler) ResolveReport(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "id is required"})
		return
	}

	if err := h.ReportUsecase.ResolveReport(c, id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Report resolved"})
}
