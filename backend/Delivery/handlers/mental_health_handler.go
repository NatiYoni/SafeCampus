package handlers

import (
	"net/http"

	domain "github.com/StartUp/safecampus/backend/Domain"
	usecases "github.com/StartUp/safecampus/backend/Usecases"
	"github.com/gin-gonic/gin"
)

type MentalHealthHandler struct {
	Usecase usecases.MentalHealthUsecase
}

func NewMentalHealthHandler(u usecases.MentalHealthUsecase) *MentalHealthHandler {
	return &MentalHealthHandler{
		Usecase: u,
	}
}

func (h *MentalHealthHandler) GetResources(c *gin.Context) {
	resources, err := h.Usecase.GetResources(c)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if resources == nil {
		resources = []*domain.MentalHealthResource{}
	}
	c.JSON(http.StatusOK, resources)
}

func (h *MentalHealthHandler) ChatWithCompanion(c *gin.Context) {
	var req domain.AIChatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	response, err := h.Usecase.GetAICompanionResponse(c, req.Message, req.History)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, domain.AIChatResponse{Response: response})
}
