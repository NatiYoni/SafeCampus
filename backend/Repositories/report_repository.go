package repositories

import (
	"context"
	"errors"

	domain "github.com/StartUp/safecampus/backend/Domain"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

type ReportRepository struct {
	collection *mongo.Collection
}

func NewReportRepository(db *mongo.Database) domain.ReportRepository {
	return &ReportRepository{
		collection: db.Collection("reports"),
	}
}

func (r *ReportRepository) Create(ctx context.Context, report *domain.Report) error {
	_, err := r.collection.InsertOne(ctx, report)
	return err
}

func (r *ReportRepository) GetByID(ctx context.Context, id string) (*domain.Report, error) {
	var report domain.Report
	filter := bson.M{"_id": id}
	err := r.collection.FindOne(ctx, filter).Decode(&report)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("report not found")
		}
		return nil, err
	}
	return &report, nil
}

func (r *ReportRepository) FetchAll(ctx context.Context, filterMap map[string]interface{}) ([]*domain.Report, error) {
	var reports []*domain.Report
	// Convert generic map to bson.M if needed, or pass directly if strictly compatible.
	// Typically we want to build a bson.M from the input.
	query := bson.M{}
	for k, v := range filterMap {
		query[k] = v
	}

	cursor, err := r.collection.Find(ctx, query)
	if err != nil {
		return nil, err
	}
	if err = cursor.All(ctx, &reports); err != nil {
		return nil, err
	}
	return reports, nil
}
