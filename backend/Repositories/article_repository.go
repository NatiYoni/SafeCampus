package repositories

import (
	"context"

	domain "github.com/StartUp/safecampus/backend/Domain"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type ArticleRepository struct {
	collection *mongo.Collection
}

func NewArticleRepository(db *mongo.Database) domain.ArticleRepository {
	return &ArticleRepository{
		collection: db.Collection("articles"),
	}
}

func (r *ArticleRepository) Create(ctx context.Context, article *domain.Article) error {
	_, err := r.collection.InsertOne(ctx, article)
	return err
}

func (r *ArticleRepository) FetchAll(ctx context.Context) ([]*domain.Article, error) {
	var articles []*domain.Article
	opts := options.Find().SetSort(bson.D{{Key: "created_at", Value: -1}})
	cursor, err := r.collection.Find(ctx, bson.M{}, opts)
	if err != nil {
		return nil, err
	}
	if err = cursor.All(ctx, &articles); err != nil {
		return nil, err
	}
	return articles, nil
}
