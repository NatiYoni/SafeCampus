package handlers

import (
	"net/http"

	domain "github.com/StartUp/safecampus/backend/Domain"
	usecases "github.com/StartUp/safecampus/backend/Usecases"
	"github.com/gin-gonic/gin"
)

type AlertHandler struct {
	AlertUsecase usecases.AlertUsecase
}

func NewAlertHandler(a usecases.AlertUsecase) *AlertHandler {
	return &AlertHandler{
		AlertUsecase: a,
	}
}

func (h *AlertHandler) TriggerSOS(c *gin.Context) {
	var req struct {
		UserID   string          `json:"user_id"`
		Location domain.Location `json:"location"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	alert, err := h.AlertUsecase.TriggerSOS(c, req.UserID, req.Location)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, alert)
}

func (h *AlertHandler) ResolveAlert(c *gin.Context) {
	alertID := c.Param("id")
	if err := h.AlertUsecase.ResolveAlert(c, alertID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Alert resolved"})
}

func (h *AlertHandler) GetAllAlerts(c *gin.Context) {
	alerts, err := h.AlertUsecase.GetAllAlerts(c)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, alerts)
}
