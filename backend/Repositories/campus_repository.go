package repositories

import (
	"context"
	"time"

	domain "github.com/StartUp/safecampus/backend/Domain"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type CampusRepository struct {
	collection *mongo.Collection
}

func NewCampusRepository(db *mongo.Database) domain.CampusRepository {
	return &CampusRepository{
		collection: db.Collection("campus_presence"),
	}
}

func (r *CampusRepository) UpdatePresence(ctx context.Context, presence *domain.CampusPresence) error {
	filter := bson.M{"user_id": presence.UserID}
	update := bson.M{"$set": presence}
	opts := options.Update().SetUpsert(true)
	_, err := r.collection.UpdateOne(ctx, filter, update, opts)
	return err
}

func (r *CampusRepository) GetActivePresences(ctx context.Context, since time.Time) ([]*domain.CampusPresence, error) {
	var presences []*domain.CampusPresence
	filter := bson.M{"last_seen": bson.M{"$gte": since}}
	cursor, err := r.collection.Find(ctx, filter)
	if err != nil {
		return nil, err
	}
	if err = cursor.All(ctx, &presences); err != nil {
		return nil, err
	}
	// Return empty list instead of nil for JSON safety
	if presences == nil {
		return []*domain.CampusPresence{}, nil
	}
	return presences, nil
}
