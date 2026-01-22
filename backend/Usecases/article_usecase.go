package usecases

import (
	"context"
	"time"

	domain "github.com/StartUp/safecampus/backend/Domain"
	"github.com/google/uuid"
)

type ArticleUsecase interface {
	CreateArticle(ctx context.Context, title, content, authorID string) error
	GetArticles(ctx context.Context) ([]*domain.Article, error)
}

type articleUsecase struct {
	articleRepo domain.ArticleRepository
	userRepo    domain.UserRepository
	timeout     time.Duration
}

func NewArticleUsecase(articleRepo domain.ArticleRepository, userRepo domain.UserRepository, timeout time.Duration) ArticleUsecase {
	return &articleUsecase{
		articleRepo: articleRepo,
		userRepo:    userRepo,
		timeout:     timeout,
	}
}

func (u *articleUsecase) CreateArticle(ctx context.Context, title, content, authorID string) error {
	ctx, cancel := context.WithTimeout(ctx, u.timeout)
	defer cancel()

	user, err := u.userRepo.GetByID(ctx, authorID)
	if err != nil {
		return err
	}

	article := &domain.Article{
		ID:         uuid.New().String(),
		Title:      title,
		Content:    content,
		AuthorID:   authorID,
		AuthorName: user.FullName,
		CreatedAt:  time.Now(),
	}

	return u.articleRepo.Create(ctx, article)
}

func (u *articleUsecase) GetArticles(ctx context.Context) ([]*domain.Article, error) {
	ctx, cancel := context.WithTimeout(ctx, u.timeout)
	defer cancel()
	return u.articleRepo.FetchAll(ctx)
}
