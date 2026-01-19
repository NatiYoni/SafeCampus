package usecases

import (
	"context"
	"time"

	domain "github.com/StartUp/safecampus/backend/Domain"
)

type ChatUsecase interface {
	SendMessage(ctx context.Context, msg *domain.Message) error
	GetChatHistory(ctx context.Context, reportID string) ([]*domain.Message, error)
}

type chatUsecase struct {
	chatRepo       domain.ChatRepository
	contextTimeout time.Duration
}

func NewChatUsecase(chatRepo domain.ChatRepository, timeout time.Duration) ChatUsecase {
	return &chatUsecase{
		chatRepo:       chatRepo,
		contextTimeout: timeout,
	}
}

func (c *chatUsecase) SendMessage(ctx context.Context, msg *domain.Message) error {
	ctx, cancel := context.WithTimeout(ctx, c.contextTimeout)
	defer cancel()

	msg.Timestamp = time.Now()
	msg.IsRead = false
	return c.chatRepo.SaveMessage(ctx, msg)
}

func (c *chatUsecase) GetChatHistory(ctx context.Context, reportID string) ([]*domain.Message, error) {
	ctx, cancel := context.WithTimeout(ctx, c.contextTimeout)
	defer cancel()
	return c.chatRepo.GetMessagesByReportID(ctx, reportID)
}
