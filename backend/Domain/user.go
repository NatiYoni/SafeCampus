package domain

import (
	"time"
)

type Role string

const (
	RoleStudent    Role = "student"
	RoleAdmin      Role = "admin"
	RoleSuperAdmin Role = "super_admin"
)

// User represents a registered user of the Safe Campus app.
type User struct {
	ID           string    `json:"id" bson:"_id"`
	Email        string    `json:"email" bson:"email"`
	PasswordHash string    `json:"-" bson:"password_hash"`
	FullName     string    `json:"full_name" bson:"full_name"`
	PhoneNumber  string    `json:"phone_number" bson:"phone_number"`
	UniversityID string    `json:"university_id" bson:"university_id"`
	Role         Role      `json:"role" bson:"role"` // Role-based access control
	Profile      Profile   `json:"profile" bson:"profile"`
	Contacts     []Contact `json:"contacts" bson:"contacts"`
	DeviceToken  string    `json:"device_token" bson:"device_token"` // For Push Notifications

	// Authentication Fields (New)
	IsVerified           bool      `json:"is_verified" bson:"is_verified"`
	VerificationCode     string    `json:"-" bson:"verification_code"`
	VerificationCodeExp  time.Time `json:"-" bson:"verification_code_exp"`
	VerificationAttempts int       `json:"-" bson:"verification_attempts"`
	LastVerificationSent time.Time `json:"-" bson:"last_verification_sent"`
	RefreshToken         string    `json:"-" bson:"refresh_token"`

	CreatedAt time.Time `json:"created_at" bson:"created_at"`

	UpdatedAt    time.Time `json:"updated_at" bson:"updated_at"`
}

// Profile contains critical medical and personal information for emergencies.
type Profile struct {
	BloodType         string   `json:"blood_type" bson:"blood_type"`
	Allergies         []string `json:"allergies" bson:"allergies"`
	MedicalConditions []string `json:"medical_conditions" bson:"medical_conditions"`
	Medications       []string `json:"medications" bson:"medications"`
}

// Contact represents an emergency contact (Guardian).
type Contact struct {
	Name        string `json:"name" bson:"name"`
	PhoneNumber string `json:"phone_number" bson:"phone_number"`
	Relation    string `json:"relation" bson:"relation"`
}
