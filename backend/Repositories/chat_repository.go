package repositories

import (
	"context"

	domain "github.com/StartUp/safecampus/backend/Domain"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type ChatRepository struct {
	collection *mongo.Collection
}

func NewChatRepository(db *mongo.Database) domain.ChatRepository {
	return &ChatRepository{
		collection: db.Collection("messages"),
	}
}

func (r *ChatRepository) SaveMessage(ctx context.Context, msg *domain.Message) error {
	_, err := r.collection.InsertOne(ctx, msg)
	return err
}

func (r *ChatRepository) GetMessagesByReportID(ctx context.Context, reportID string) ([]*domain.Message, error) {
	var messages []*domain.Message
	filter := bson.M{"report_id": reportID}
	opts := options.Find().SetSort(bson.D{{Key: "timestamp", Value: 1}}) // Ascending order
	cursor, err := r.collection.Find(ctx, filter, opts)
	if err != nil {
		return nil, err
	}
	if err = cursor.All(ctx, &messages); err != nil {
		return nil, err
	}
	return messages, nil
}
