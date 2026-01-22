package handlers

import (
	"net/http"

	usecases "github.com/StartUp/safecampus/backend/Usecases"
	"github.com/gin-gonic/gin"
)

type ArticleHandler struct {
	ArticleUsecase usecases.ArticleUsecase
}

func NewArticleHandler(u usecases.ArticleUsecase) *ArticleHandler {
	return &ArticleHandler{
		ArticleUsecase: u,
	}
}

type CreateArticleRequest struct {
	Title   string `json:"title" binding:"required"`
	Content string `json:"content" binding:"required"`
}

func (h *ArticleHandler) CreateArticle(c *gin.Context) {
	var req CreateArticleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	authorID := c.GetString("user_id")
	if err := h.ArticleUsecase.CreateArticle(c, req.Title, req.Content, authorID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Article created successfully"})
}

func (h *ArticleHandler) GetArticles(c *gin.Context) {
	articles, err := h.ArticleUsecase.GetArticles(c)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, articles)
}
