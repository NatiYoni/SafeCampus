package handlers

import (
	"net/http"

	domain "github.com/StartUp/safecampus/backend/Domain"
	usecases "github.com/StartUp/safecampus/backend/Usecases"
	"github.com/gin-gonic/gin"
)

type ChatHandler struct {
	ChatUsecase usecases.ChatUsecase
}

func NewChatHandler(c usecases.ChatUsecase) *ChatHandler {
	return &ChatHandler{
		ChatUsecase: c,
	}
}

func (h *ChatHandler) SendMessage(c *gin.Context) {
	var msg domain.Message
	if err := c.ShouldBindJSON(&msg); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := h.ChatUsecase.SendMessage(c, &msg); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Message sent"})
}

func (h *ChatHandler) GetHistory(c *gin.Context) {
	reportID := c.Param("reportId")
	msgs, err := h.ChatUsecase.GetChatHistory(c, reportID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, msgs)
}
