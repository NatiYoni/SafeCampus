package repositories

import (
	"context"
	"errors"

	domain "github.com/StartUp/safecampus/backend/Domain"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type AlertRepository struct {
	collection *mongo.Collection
}

func NewAlertRepository(db *mongo.Database) domain.AlertRepository {
	return &AlertRepository{
		collection: db.Collection("alerts"),
	}
}

func (r *AlertRepository) Create(ctx context.Context, alert *domain.Alert) error {
	_, err := r.collection.InsertOne(ctx, alert)
	return err
}

func (r *AlertRepository) GetByID(ctx context.Context, id string) (*domain.Alert, error) {
	var alert domain.Alert
	filter := bson.M{"_id": id}
	err := r.collection.FindOne(ctx, filter).Decode(&alert)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("alert not found")
		}
		return nil, err
	}
	return &alert, nil
}

func (r *AlertRepository) GetActiveByUserID(ctx context.Context, userID string) ([]*domain.Alert, error) {
	var alerts []*domain.Alert
	// Assuming "Resolved" is the end state. Active could correspond to anything else.
	// But let's just filter by UserID for now as per interface name, implies "Active".
	// The interface says "GetActive..." so we should probably filter by Status != Resolved.
	filter := bson.M{
		"user_id": userID,
		"status":  bson.M{"$ne": "Resolved"},
	}
	cursor, err := r.collection.Find(ctx, filter)
	if err != nil {
		return nil, err
	}
	if err = cursor.All(ctx, &alerts); err != nil {
		return nil, err
	}
	return alerts, nil
}

func (r *AlertRepository) UpdateStatus(ctx context.Context, id string, status string) error {
	filter := bson.M{"_id": id}
	update := bson.M{"$set": bson.M{"status": status}}
	_, err := r.collection.UpdateOne(ctx, filter, update)
	return err
}

func (r *AlertRepository) FetchNearby(ctx context.Context, loc domain.Location, radius float64) ([]*domain.Alert, error) {
	// Radius is in meters usually.
	// 1 degree lat ~= 111km. 1km ~= 0.009 degrees.
	// 1m ~= 0.000009 degrees.
	// radius (degrees) ~= radius(m) / 111000.
	// This is a rough approximation.

	// Assuming radius is passed in Meters.
	rDeg := radius / 111000.0

	filter := bson.M{
		"location.latitude": bson.M{
			"$gte": loc.Latitude - rDeg,
			"$lte": loc.Latitude + rDeg,
		},
		"location.longitude": bson.M{
			"$gte": loc.Longitude - rDeg, // Note: this fails at dateline
			"$lte": loc.Longitude + rDeg,
		},
	}

	cursor, err := r.collection.Find(ctx, filter)
	if err != nil {
		return nil, err
	}

	var alerts []*domain.Alert
	if err = cursor.All(ctx, &alerts); err != nil {
		return nil, err
	}
	return alerts, nil
}

func (r *AlertRepository) GetAll(ctx context.Context) ([]*domain.Alert, error) {
	var alerts []*domain.Alert
	opts := options.Find().SetSort(bson.D{{Key: "timestamp", Value: -1}})
	cursor, err := r.collection.Find(ctx, bson.M{}, opts)
	if err != nil {
		return nil, err
	}
	if err = cursor.All(ctx, &alerts); err != nil {
		return nil, err
	}
	return alerts, nil
}

func (r *AlertRepository) Delete(ctx context.Context, id string) error {
	_, err := r.collection.DeleteOne(ctx, bson.M{"_id": id})
	return err
}

func (r *AlertRepository) EnsureTTLIndex(ctx context.Context) error {
	// Create TTL index to expire documents 3 days (259200 seconds) after 'timestamp'
	model := mongo.IndexModel{
		Keys: bson.M{"timestamp": 1},
		Options: options.Index().SetExpireAfterSeconds(259200),
	}
	_, err := r.collection.Indexes().CreateOne(ctx, model)
	return err
}
