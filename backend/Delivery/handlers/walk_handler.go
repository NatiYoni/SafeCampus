package handlers

import (
	"net/http"

	usecases "github.com/StartUp/safecampus/backend/Usecases"

	"github.com/gin-gonic/gin"
)

type WalkHandler struct {
	WalkUseCase *usecases.WalkUseCase
}

func NewWalkHandler(uc *usecases.WalkUseCase) *WalkHandler {
	return &WalkHandler{
		WalkUseCase: uc,
	}
}

func (h *WalkHandler) StartWalk(c *gin.Context) {
	var req struct {
		WalkerID   string `json:"walker_id"`
		GuardianID string `json:"guardian_id"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	session, err := h.WalkUseCase.StartWalk(c, req.WalkerID, req.GuardianID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, session)
}

func (h *WalkHandler) UpdateLocation(c *gin.Context) {
	walkID := c.Param("id")
	var req struct {
		Lat float64 `json:"lat"`
		Lng float64 `json:"lng"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := h.WalkUseCase.UpdateLocation(c, walkID, req.Lat, req.Lng)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "location updated"})
}

func (h *WalkHandler) EndWalk(c *gin.Context) {
	walkID := c.Param("id")
	err := h.WalkUseCase.EndWalk(c, walkID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "walk ended"})
}

func (h *WalkHandler) GetAllActiveWalks(c *gin.Context) {
	walks, err := h.WalkUseCase.GetAllActiveWalks(c)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, walks)
}
