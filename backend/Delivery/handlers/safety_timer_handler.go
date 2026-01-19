package handlers

import (
	"net/http"

	usecases "github.com/StartUp/safecampus/backend/Usecases"
	"github.com/gin-gonic/gin"
)

type SafetyTimerHandler struct {
	Usecase *usecases.SafetyTimerUsecase
}

func NewSafetyTimerHandler(u *usecases.SafetyTimerUsecase) *SafetyTimerHandler {
	return &SafetyTimerHandler{
		Usecase: u,
	}
}

func (h *SafetyTimerHandler) SetTimer(c *gin.Context) {
	var req struct {
		UserID          string   `json:"user_id"`
		DurationMinutes int      `json:"duration_minutes"`
		Guardians       []string `json:"guardians"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	timer, err := h.Usecase.SetTimer(c, req.UserID, req.DurationMinutes, req.Guardians)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, timer)
}

func (h *SafetyTimerHandler) CancelTimer(c *gin.Context) {
	id := c.Param("id")
	if err := h.Usecase.CancelTimer(c, id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "cancelled"})
}
