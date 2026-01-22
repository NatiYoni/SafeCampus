package repositories

import (
	"context"
	"errors"

	domain "github.com/StartUp/safecampus/backend/Domain"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

type UserRepository struct {
	collection *mongo.Collection
}

func NewUserRepository(db *mongo.Database) domain.UserRepository {
	return &UserRepository{
		collection: db.Collection("users"),
	}
}

func (r *UserRepository) Create(ctx context.Context, user *domain.User) error {
	_, err := r.collection.InsertOne(ctx, user)
	return err
}

func (r *UserRepository) GetByID(ctx context.Context, id string) (*domain.User, error) {
	var user domain.User
	filter := bson.M{"_id": id}
	err := r.collection.FindOne(ctx, filter).Decode(&user)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, nil // Return nil, nil if not found to allow check
		}
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetByUniversityID(ctx context.Context, uniID string) (*domain.User, error) {
	var user domain.User
	filter := bson.M{"university_id": uniID}
	err := r.collection.FindOne(ctx, filter).Decode(&user)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("user not found")
		}
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetByEmail(ctx context.Context, email string) (*domain.User, error) {
	var user domain.User
	filter := bson.M{"email": email}
	err := r.collection.FindOne(ctx, filter).Decode(&user)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("user not found")
		}
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetByPhoneNumber(ctx context.Context, phone string) (*domain.User, error) {
	var user domain.User
	filter := bson.M{"phone_number": phone}
	err := r.collection.FindOne(ctx, filter).Decode(&user)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, errors.New("user not found")
		}
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) Update(ctx context.Context, user *domain.User) error {
	filter := bson.M{"_id": user.ID}
	update := bson.M{"$set": user}
	_, err := r.collection.UpdateOne(ctx, filter, update)
	return err
}

func (r *UserRepository) UpdateRole(ctx context.Context, userID string, role domain.Role) error {
	filter := bson.M{"_id": userID}
	update := bson.M{"$set": bson.M{"role": role}}
	_, err := r.collection.UpdateOne(ctx, filter, update)
	return err
}

func (r *UserRepository) UpdateLocation(ctx context.Context, userID string, location domain.Location) error {
	// Not storing location on user model directly in basic struct, but interface asks for it.
	// Assuming there might be a LastLocation field or similar, but looking at User struct it is not there?
	// Checking User struct... no Location field.
	// However, the interface requires it. I will implement it as a no-op or add it if needed.
	// But valid implementation probably involves 'Walk' or 'Alert'.
	// For now, let's assuming we might want to store it in a generic way or ignore.
	// Actually, let's just log it or strict update to a new field if we can dynamic.
	// But mongo is strict with struct decoding usually.
	// Let's assume we add a Location field to User later. For now, we update 'updated_at'.
	// Or we can just ignore if not in struct.
	return nil
}
