package repositories

import (
	"context"
	"errors"

	domain "github.com/StartUp/safecampus/backend/Domain"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

type SafetyTimerRepository struct {
	collection *mongo.Collection
}

func NewSafetyTimerRepository(db *mongo.Database) domain.SafetyTimerRepository {
	return &SafetyTimerRepository{
		collection: db.Collection("safety_timers"),
	}
}

func (r *SafetyTimerRepository) Create(ctx context.Context, timer *domain.SafetyTimer) error {
	_, err := r.collection.InsertOne(ctx, timer)
	return err
}

func (r *SafetyTimerRepository) GetByID(ctx context.Context, id string) (*domain.SafetyTimer, error) {
	var timer domain.SafetyTimer
	filter := bson.M{"_id": id}
	err := r.collection.FindOne(ctx, filter).Decode(&timer)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("timer not found")
		}
		return nil, err
	}
	return &timer, nil
}

func (r *SafetyTimerRepository) UpdateStatus(ctx context.Context, id string, status domain.TimerStatus) error {
	filter := bson.M{"_id": id}
	update := bson.M{"$set": bson.M{"status": status}}
	_, err := r.collection.UpdateOne(ctx, filter, update)
	return err
}

func (r *SafetyTimerRepository) GetActiveByUserID(ctx context.Context, userID string) (*domain.SafetyTimer, error) {
	var timer domain.SafetyTimer
	// Active usually means "ACTIVE".
	filter := bson.M{
		"user_id": userID,
		"status":  domain.TimerActive,
	}
	err := r.collection.FindOne(ctx, filter).Decode(&timer)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, nil // Return nil if no active timer
		}
		return nil, err
	}
	return &timer, nil
}
