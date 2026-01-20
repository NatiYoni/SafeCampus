package repositories

import (
	"context"

	domain "github.com/StartUp/safecampus/backend/Domain"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

type MentalHealthRepository struct {
	collection *mongo.Collection
}

func NewMentalHealthRepository(db *mongo.Database) *MentalHealthRepository {
	return &MentalHealthRepository{
		collection: db.Collection("mental_health_resources"),
	}
}

func (r *MentalHealthRepository) GetAllResources(ctx context.Context) ([]*domain.MentalHealthResource, error) {
	var resources []*domain.MentalHealthResource
	cursor, err := r.collection.Find(ctx, bson.M{})
	if err != nil {
		return nil, err
	}
	if err = cursor.All(ctx, &resources); err != nil {
		return nil, err
	}
	return resources, nil
}
