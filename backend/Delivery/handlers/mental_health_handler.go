package handlers

import (
	"net/http"

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
	c.JSON(http.StatusOK, resources)
}
