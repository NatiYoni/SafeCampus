package usecases

import (
	"context"
	"time"

	domain "github.com/StartUp/safecampus/backend/Domain"
)

// UserUsecase defines the business logic for user management.
type UserUsecase interface {
	Register(ctx context.Context, user *domain.User) error
	Login(ctx context.Context, email, password string) (string, *domain.User, error) // Returns token, user, error
	GetProfile(ctx context.Context, id string) (*domain.User, error)
	UpdateProfile(ctx context.Context, user *domain.User) error
	AddEmergencyContact(ctx context.Context, userID string, contact domain.Contact) error
}

type userUsecase struct {
	userRepo       domain.UserRepository
	contextTimeout time.Duration
}

// NewUserUsecase creates a new instance of UserUsecase.
func NewUserUsecase(userRepo domain.UserRepository, timeout time.Duration) UserUsecase {
	return &userUsecase{
		userRepo:       userRepo,
		contextTimeout: timeout,
	}
}

func (u *userUsecase) Register(ctx context.Context, user *domain.User) error {
	ctx, cancel := context.WithTimeout(ctx, u.contextTimeout)
	defer cancel()
	// TODO: Hash password before saving
	return u.userRepo.Create(ctx, user)
}

func (u *userUsecase) Login(ctx context.Context, email, password string) (string, *domain.User, error) {
	ctx, cancel := context.WithTimeout(ctx, u.contextTimeout)
	defer cancel()

	user, err := u.userRepo.GetByEmail(ctx, email)
	if err != nil {
		return "", nil, err
	}
	// TODO: Compare password hash, Generate JWT

	return "dummy-jwt-token", user, nil
}

func (u *userUsecase) GetProfile(ctx context.Context, id string) (*domain.User, error) {
	ctx, cancel := context.WithTimeout(ctx, u.contextTimeout)
	defer cancel()
	return u.userRepo.GetByID(ctx, id)
}

func (u *userUsecase) UpdateProfile(ctx context.Context, user *domain.User) error {
	ctx, cancel := context.WithTimeout(ctx, u.contextTimeout)
	defer cancel()
	return u.userRepo.Update(ctx, user)
}

func (u *userUsecase) AddEmergencyContact(ctx context.Context, userID string, contact domain.Contact) error {
	ctx, cancel := context.WithTimeout(ctx, u.contextTimeout)
	defer cancel()
	user, err := u.userRepo.GetByID(ctx, userID)
	if err != nil {
		return err
	}
	user.Contacts = append(user.Contacts, contact)
	return u.userRepo.Update(ctx, user)
}
