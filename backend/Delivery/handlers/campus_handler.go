package handlers

import (
	"net/http"

	usecases "github.com/StartUp/safecampus/backend/Usecases"
	"github.com/gin-gonic/gin"
)

type CampusHandler struct {
	CampusUseCase *usecases.CampusUseCase
}

func NewCampusHandler(uc *usecases.CampusUseCase) *CampusHandler {
	return &CampusHandler{
		CampusUseCase: uc,
	}
}

func (h *CampusHandler) Heartbeat(c *gin.Context) {
	var req struct {
		Latitude  float64 `json:"latitude"`
		Longitude float64 `json:"longitude"`
		Heading   float64 `json:"heading"`
		Status    string  `json:"status"` // "safe" or "sos"
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Assuming AuthMiddleware sets "user_id"
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	err := h.CampusUseCase.Heartbeat(c, userID, req.Latitude, req.Longitude, req.Heading, req.Status)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "heartbeat received"})
}

func (h *CampusHandler) GetCampusStatus(c *gin.Context) {
	status, err := h.CampusUseCase.GetCampusStatus(c)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, status)
}
