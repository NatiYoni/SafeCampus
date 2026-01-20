package repositories

import (
	"context"
	"errors"
	"time"

	domain "github.com/StartUp/safecampus/backend/Domain"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

type InvitationRepository struct {
	collection *mongo.Collection
}

func NewInvitationRepository(db *mongo.Database) domain.InvitationRepository {
	return &InvitationRepository{
		collection: db.Collection("invitations"),
	}
}

func (r *InvitationRepository) Create(ctx context.Context, invitation *domain.Invitation) error {
	_, err := r.collection.InsertOne(ctx, invitation)
	return err
}

func (r *InvitationRepository) GetByToken(ctx context.Context, token string) (*domain.Invitation, error) {
	var invitation domain.Invitation
	// In production, token should be hashed before querying.
	// For now, assuming direct token or hash passed in.
	filter := bson.M{"token": token, "used": false, "expires_at": bson.M{"$gt": time.Now()}}
	err := r.collection.FindOne(ctx, filter).Decode(&invitation)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("invalid or expired invitation")
		}
		return nil, err
	}
	return &invitation, nil
}

func (r *InvitationRepository) GetByEmail(ctx context.Context, email string) (*domain.Invitation, error) {
	var invitation domain.Invitation
	filter := bson.M{"email": email, "used": false, "expires_at": bson.M{"$gt": time.Now()}}
	err := r.collection.FindOne(ctx, filter).Decode(&invitation)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, nil // No active invitation
		}
		return nil, err
	}
	return &invitation, nil
}

func (r *InvitationRepository) MarkAsUsed(ctx context.Context, id string) error {
	filter := bson.M{"_id": id}
	update := bson.M{"$set": bson.M{"used": true}}
	_, err := r.collection.UpdateOne(ctx, filter, update)
	return err
}
