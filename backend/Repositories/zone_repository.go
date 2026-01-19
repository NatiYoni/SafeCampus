package repositories

import (
	"context"

	domain "github.com/StartUp/safecampus/backend/Domain"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

type ZoneRepository struct {
	collection *mongo.Collection
}

func NewZoneRepository(db *mongo.Database) domain.ZoneRepository {
	return &ZoneRepository{
		collection: db.Collection("zones"),
	}
}

func (r *ZoneRepository) Create(ctx context.Context, zone *domain.Zone) error {
	_, err := r.collection.InsertOne(ctx, zone)
	return err
}

func (r *ZoneRepository) GetAll(ctx context.Context) ([]*domain.Zone, error) {
	var zones []*domain.Zone
	cursor, err := r.collection.Find(ctx, bson.M{})
	if err != nil {
		return nil, err
	}
	if err = cursor.All(ctx, &zones); err != nil {
		return nil, err
	}
	return zones, nil
}

func (r *ZoneRepository) CheckContainment(ctx context.Context, loc domain.Location) (*domain.Zone, error) {
	// 1. Fetch all zones
	zones, err := r.GetAll(ctx)
	if err != nil {
		return nil, err
	}

	// 2. Iterate and check point-in-polygon
	for _, zone := range zones {
		if isPointInPolygon(loc, zone.Coordinates) {
			return zone, nil
		}
	}

	return nil, nil
}

// Ray Casting algorithm
func isPointInPolygon(p domain.Location, polygon []domain.Location) bool {
	if len(polygon) < 3 {
		return false
	}
	inside := false
	j := len(polygon) - 1
	for i := 0; i < len(polygon); i++ {
		if (polygon[i].Latitude > p.Latitude) != (polygon[j].Latitude > p.Latitude) &&
			(p.Longitude < (polygon[j].Longitude-polygon[i].Longitude)*(p.Latitude-polygon[i].Latitude)/(polygon[j].Latitude-polygon[i].Latitude)+polygon[i].Longitude) {
			inside = !inside
		}
		j = i
	}
	return inside
}
