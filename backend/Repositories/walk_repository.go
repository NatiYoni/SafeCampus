package repositories

import (
	"context"
	"errors"

	domain "github.com/StartUp/safecampus/backend/Domain"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

type WalkRepository struct {
	collection *mongo.Collection
}

func NewWalkRepository(db *mongo.Database) domain.WalkRepository {
	return &WalkRepository{
		collection: db.Collection("walks"),
	}
}

func (r *WalkRepository) Create(ctx context.Context, session *domain.WalkSession) error {
	_, err := r.collection.InsertOne(ctx, session)
	return err
}

func (r *WalkRepository) GetByID(ctx context.Context, id string) (*domain.WalkSession, error) {
	var session domain.WalkSession
	filter := bson.M{"_id": id}
	err := r.collection.FindOne(ctx, filter).Decode(&session)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("walk session not found")
		}
		return nil, err
	}
	return &session, nil
}

func (r *WalkRepository) UpdateLocation(ctx context.Context, id string, location domain.Location) error {
	filter := bson.M{"_id": id}
	update := bson.M{
		"$set":  bson.M{"current_location": location},
		"$push": bson.M{"path": location},
	}
	_, err := r.collection.UpdateOne(ctx, filter, update)
	return err
}

func (r *WalkRepository) EndWalk(ctx context.Context, id string) error {
	filter := bson.M{"_id": id}
	update := bson.M{"$set": bson.M{"status": "completed"}} // Or "ended"
	_, err := r.collection.UpdateOne(ctx, filter, update)
	return err
}

func (r *WalkRepository) GetActiveWalksByGuardian(ctx context.Context, guardianID string) ([]*domain.WalkSession, error) {
	var sessions []*domain.WalkSession
	filter := bson.M{
		"guardian_id": guardianID,
		"status":      "active",
	}
	cursor, err := r.collection.Find(ctx, filter)
	if err != nil {
		return nil, err
	}
	if err = cursor.All(ctx, &sessions); err != nil {
		return nil, err
	}
	return sessions, nil
}
