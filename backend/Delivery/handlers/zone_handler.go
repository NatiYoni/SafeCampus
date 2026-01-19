package handlers

import (
	"net/http"

	domain "github.com/StartUp/safecampus/backend/Domain"
	usecases "github.com/StartUp/safecampus/backend/Usecases"
	"github.com/gin-gonic/gin"
)

type ZoneHandler struct {
	ZoneUsecase usecases.ZoneUsecase
}

func NewZoneHandler(z usecases.ZoneUsecase) *ZoneHandler {
	return &ZoneHandler{
		ZoneUsecase: z,
	}
}

func (h *ZoneHandler) CheckZone(c *gin.Context) {
	var loc domain.Location
	if err := c.ShouldBindJSON(&loc); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Assume UserID comes from auth middleware
	userID := "temp-user-id"

	zone, err := h.ZoneUsecase.CheckAndNotify(c, userID, loc)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if zone != nil {
		c.JSON(http.StatusOK, gin.H{"in_zone": true, "zone": zone})
	} else {
		c.JSON(http.StatusOK, gin.H{"in_zone": false})
	}
}
