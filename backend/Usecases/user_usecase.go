package usecases

import (
	"context"
	"errors"
	"fmt"
	"math/rand"
	"time"

	domain "github.com/StartUp/safecampus/backend/Domain"
	infrastructure "github.com/StartUp/safecampus/backend/Infrastructure"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"golang.org/x/crypto/bcrypt"
)

// UserUsecase defines the business logic for user management.
type UserUsecase interface {
	Register(ctx context.Context, user *domain.User, password string) error
	VerifyEmail(ctx context.Context, email, code string) error
	Login(ctx context.Context, email, password string) (string, string, *domain.User, error) // Returns accessToken, refreshToken, user, error
	ResendVerification(ctx context.Context, email string) error
	RefreshToken(ctx context.Context, refreshToken string) (string, error) // Returns new accessToken
	GetProfile(ctx context.Context, id string) (*domain.User, error)
	UpdateProfile(ctx context.Context, user *domain.User) error
	AddEmergencyContact(ctx context.Context, userID string, contact domain.Contact) error

	// Admin / RBAC
	PromoteUser(ctx context.Context, adminID, targetEmail string) error
	InviteAdmin(ctx context.Context, adminID, email string) (string, error)
	RegisterAdmin(ctx context.Context, token, email, password, fullName string) error
	EnsureSuperAdmin(ctx context.Context, email, password string) error
}

type userUsecase struct {
	userRepo       domain.UserRepository
	invitationRepo domain.InvitationRepository
	emailService   *infrastructure.EmailService
	jwtService     *infrastructure.JWTService
	contextTimeout time.Duration
}

// NewUserUsecase creates a new instance of UserUsecase.
func NewUserUsecase(userRepo domain.UserRepository, invitationRepo domain.InvitationRepository, emailService *infrastructure.EmailService, jwtService *infrastructure.JWTService, timeout time.Duration) UserUsecase {
	return &userUsecase{
		userRepo:       userRepo,
		invitationRepo: invitationRepo,
		emailService:   emailService,
		jwtService:     jwtService,
		contextTimeout: timeout,
	}
}

func (u *userUsecase) Register(ctx context.Context, user *domain.User, password string) error {
	ctx, cancel := context.WithTimeout(ctx, u.contextTimeout)
	defer cancel()

	// 1. Force Role to Student for public registration
	user.Role = domain.RoleStudent

	// 2. Check if user exists
	existingUser, _ := u.userRepo.GetByEmail(ctx, user.Email)
	if existingUser != nil {
		if existingUser.IsVerified {
			return errors.New("email already registered")
		}
		// If user exists but NOT verified, we overwrite/update the existing entry
		// so the user can "try again" without getting blocked.
		user.ID = existingUser.ID // Keep the same ID
		user.CreatedAt = existingUser.CreatedAt
		user.UpdatedAt = time.Now()
		// Determine flow to update below
	} else {
		// New User ID if strictly new
		user.ID = primitive.NewObjectID().Hex()
		user.CreatedAt = time.Now()
		user.UpdatedAt = time.Now()
	}

	// 2. Hash Password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	user.PasswordHash = string(hashedPassword)
	user.IsVerified = false

	// 3. Generate Verification Code
	code := fmt.Sprintf("%06d", rand.Intn(1000000))

	// Hash the code
	hashCode, _ := bcrypt.GenerateFromPassword([]byte(code), bcrypt.MinCost)
	user.VerificationCode = string(hashCode)
	user.VerificationCodeExp = time.Now().Add(15 * time.Minute)
	user.VerificationAttempts = 0

	// 4. Create or Update User
	if existingUser != nil {
		err = u.userRepo.Update(ctx, user)
	} else {
		err = u.userRepo.Create(ctx, user)
	}

	if err != nil {
		return err
	}

	// 5. Send Email
	go func() {
		err := u.emailService.SendVerificationEmail(user.Email, code)
		if err != nil {
			fmt.Printf("Error sending email to %s: %v\n", user.Email, err)
		} else {
			fmt.Printf("Verification email sent to %s\n", user.Email)
		}
	}() // Run in background

	return nil
}

func (u *userUsecase) VerifyEmail(ctx context.Context, email, code string) error {
	ctx, cancel := context.WithTimeout(ctx, u.contextTimeout)
	defer cancel()

	user, err := u.userRepo.GetByEmail(ctx, email)
	if err != nil {
		return errors.New("user not found")
	}

	if user.IsVerified {
		return errors.New("user already verified")
	}

	if time.Now().After(user.VerificationCodeExp) {
		return errors.New("verification code expired")
	}

	if user.VerificationAttempts >= 5 {
		return errors.New("too many failed attempts, please request a new code")
	}

	// Check Code
	err = bcrypt.CompareHashAndPassword([]byte(user.VerificationCode), []byte(code))
	if err != nil {
		user.VerificationAttempts++
		u.userRepo.Update(ctx, user)
		return errors.New("invalid verification code")
	}

	// Success
	user.IsVerified = true
	user.VerificationCode = ""
	user.VerificationAttempts = 0
	return u.userRepo.Update(ctx, user)
}

func (u *userUsecase) ResendVerification(ctx context.Context, email string) error {
	ctx, cancel := context.WithTimeout(ctx, u.contextTimeout)
	defer cancel()

	user, err := u.userRepo.GetByEmail(ctx, email)
	if err != nil {
		return errors.New("user not found")
	}

	if user.IsVerified {
		return errors.New("user already verified")
	}

	// Rate Limit: 5 minutes
	if time.Since(user.LastVerificationSent) < 5*time.Minute {
		return errors.New("please wait 5 minutes before reasoning")
	}

	// Generate New Code
	code := fmt.Sprintf("%06d", rand.Intn(1000000))
	hashCode, _ := bcrypt.GenerateFromPassword([]byte(code), bcrypt.MinCost)

	user.VerificationCode = string(hashCode)
	user.VerificationCodeExp = time.Now().Add(15 * time.Minute)
	user.LastVerificationSent = time.Now()
	user.VerificationAttempts = 0

	err = u.userRepo.Update(ctx, user)
	if err != nil {
		return err
	}

	go func() {
		err := u.emailService.SendVerificationEmail(user.Email, code)
		if err != nil {
			fmt.Printf("Error sending resend-verification email to %s: %v\n", user.Email, err)
		} else {
			fmt.Printf("Resend-verification email successfully sent to %s\n", user.Email)
		}
	}()

	return nil
}

func (u *userUsecase) Login(ctx context.Context, email, password string) (string, string, *domain.User, error) {
	ctx, cancel := context.WithTimeout(ctx, u.contextTimeout)
	defer cancel()

	user, err := u.userRepo.GetByEmail(ctx, email)
	if err != nil {
		return "", "", nil, errors.New("invalid credentials")
	}

	// Check Password
	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password))
	if err != nil {
		return "", "", nil, errors.New("invalid credentials")
	}

	// Check Verification
	if !user.IsVerified {
		return "", "", nil, errors.New("email not verified")
	}

	// Generate Tokens
	oid, _ := primitive.ObjectIDFromHex(user.ID)
	// Use the user's actual role
	role := string(user.Role)
	if role == "" {
		role = "student"
	}
	accessToken, refreshToken, err := u.jwtService.GenerateTokens(oid, user.Email, role)
	if err != nil {
		return "", "", nil, err
	}

	// Store Hashed Refresh Token
	hashRefresh, _ := bcrypt.GenerateFromPassword([]byte(refreshToken), bcrypt.DefaultCost)
	user.RefreshToken = string(hashRefresh)
	u.userRepo.Update(ctx, user)

	return accessToken, refreshToken, user, nil
}

func (u *userUsecase) RefreshToken(ctx context.Context, refreshToken string) (string, error) {
	ctx, cancel := context.WithTimeout(ctx, u.contextTimeout)
	defer cancel()

	// 1. Validate Token Structure & Expiry
	claims, err := u.jwtService.ValidateRefreshToken(refreshToken)
	if err != nil {
		return "", err
	}

	// 2. Fetch User & Validate Stored Token Hash
	user, err := u.userRepo.GetByID(ctx, claims.UserID)
	if err != nil {
		return "", errors.New("user not found")
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.RefreshToken), []byte(refreshToken))
	if err != nil {
		return "", errors.New("invalid refresh token (revoked or replaced)")
	}

	// 3. Issue New Access Token
	oid, _ := primitive.ObjectIDFromHex(user.ID)
	// We only return access token here for simplicity or we can update refresh too.
	// But interface says (string, error).
	newAccessToken, _, err := u.jwtService.GenerateTokens(oid, user.Email, "user")
	// Ideally we should rotate refresh token too, but keeping it simple as interface returns 1 string.
	// We'll reuse the existing refresh token flow on client side until it expires (7 days).
	// If we wanted rotation, we'd need to update the interface to return (string, string, error).

	return newAccessToken, nil
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

// --- Admin Logic ---

func (u *userUsecase) PromoteUser(ctx context.Context, adminID, targetEmail string) error {
	ctx, cancel := context.WithTimeout(ctx, u.contextTimeout)
	defer cancel()

	// Verify Admin
	admin, err := u.userRepo.GetByID(ctx, adminID)
	// Strict: Only SuperAdmin can invite/promote other admins
	if err != nil || admin.Role != domain.RoleSuperAdmin {
		return errors.New("unauthorized: only super admin can perform this action")
	}

	targetUser, err := u.userRepo.GetByEmail(ctx, targetEmail)
	if err != nil {
		return errors.New("user not found")
	}

	return u.userRepo.UpdateRole(ctx, targetUser.ID, domain.RoleAdmin)
}

func (u *userUsecase) InviteAdmin(ctx context.Context, adminID, email string) (string, error) {
	ctx, cancel := context.WithTimeout(ctx, u.contextTimeout)
	defer cancel()

	// Verify Admin
	admin, err := u.userRepo.GetByID(ctx, adminID)
	// Strict: Only SuperAdmin can invite/promote other admins
	if err != nil || admin.Role != domain.RoleSuperAdmin {
		return "", errors.New("unauthorized: only super admin can perform this action")
	}

	// Generate Token
	token := primitive.NewObjectID().Hex() // Simple token for now

	invitation := &domain.Invitation{
		ID:        primitive.NewObjectID().Hex(),
		Email:     email,
		Token:     token,
		Role:      domain.RoleAdmin,
		ExpiresAt: time.Now().Add(48 * time.Hour),
		CreatedBy: adminID,
		Used:      false,
	}

	err = u.invitationRepo.Create(ctx, invitation)
	if err != nil {
		return "", err
	}
	return token, nil
}

func (u *userUsecase) RegisterAdmin(ctx context.Context, token, email, password, fullName string) error {
	ctx, cancel := context.WithTimeout(ctx, u.contextTimeout)
	defer cancel()

	// Verify Invitation
	invite, err := u.invitationRepo.GetByToken(ctx, token)
	if err != nil {
		return err
	}

	if invite.Email != email {
		return errors.New("email does not match invitation")
	}

	// Create User
	user := &domain.User{
		ID:         primitive.NewObjectID().Hex(),
		Email:      email,
		FullName:   fullName,
		Role:       domain.RoleAdmin,
		IsVerified: true, // Admin invites are trusted
		CreatedAt:  time.Now(),
		UpdatedAt:  time.Now(),
	}

	// Hash Password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	user.PasswordHash = string(hashedPassword)

	err = u.userRepo.Create(ctx, user)
	if err != nil {
		return err
	}

	// Mark Invite Used
	return u.invitationRepo.MarkAsUsed(ctx, invite.ID)
}

func (u *userUsecase) EnsureSuperAdmin(ctx context.Context, email, password string) error {
	ctx, cancel := context.WithTimeout(ctx, u.contextTimeout)
	defer cancel()

	_, err := u.userRepo.GetByEmail(ctx, email)
	if err == nil {
		return nil
	}

	// Create Super Admin
	user := &domain.User{
		ID:         primitive.NewObjectID().Hex(),
		Email:      email,
		FullName:   "Super Admin",
		Role:       domain.RoleSuperAdmin,
		IsVerified: true,
		CreatedAt:  time.Now(),
		UpdatedAt:  time.Now(),
	}

	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	user.PasswordHash = string(hashedPassword)

	return u.userRepo.Create(ctx, user)
}
