package domain

import (
	"context"
	"time"
)

type Article struct {
	ID        string    `json:"id" bson:"_id"`
	Title     string    `json:"title" bson:"title"`
	Content   string    `json:"content" bson:"content"`
	AuthorID  string    `json:"author_id" bson:"author_id"`
	AuthorName string   `json:"author_name" bson:"author_name"`
	CreatedAt time.Time `json:"created_at" bson:"created_at"`
}

type ArticleRepository interface {
	Create(ctx context.Context, article *Article) error
	FetchAll(ctx context.Context) ([]*Article, error)
}
