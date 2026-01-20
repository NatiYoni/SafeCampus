package domain

import "time"

// Invitation represents an admin invitation.
type Invitation struct {
	ID        string    `bson:"_id"`
	Email     string    `bson:"email"`      // Who is invited
	Token     string    `bson:"token"`      // Secure random string (hashed)
	Role      Role      `bson:"role"`       // Role to assign (usually admin)
	ExpiresAt time.Time `bson:"expires_at"`
	CreatedBy string    `bson:"created_by"` // Admin ID who sent it
	Used      bool      `bson:"used"`
}
