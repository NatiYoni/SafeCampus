package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	domain "github.com/StartUp/safecampus/backend/Domain"
	infrastructure "github.com/StartUp/safecampus/backend/Infrastructure"
	"github.com/google/uuid"
	"github.com/joho/godotenv"
	"go.mongodb.org/mongo-driver/bson"
	"golang.org/x/crypto/bcrypt"
)

func main() {
	// Load .env
	_ = godotenv.Load()

	mongoURI := os.Getenv("MONGO_URI")
	if mongoURI == "" {
		mongoURI = "mongodb://localhost:27017"
	}

	client, err := infrastructure.NewMongoClient(mongoURI)
	if err != nil {
		log.Fatalf("Failed to connect to MongoDB: %v", err)
	}
	defer client.Disconnect(context.Background())

	db := client.Database("safecampus")
	userColl := db.Collection("users")

	email := "admin@safecampus.com"
	password := "admin123"

	// Check if exists
	var existing domain.User
	err = userColl.FindOne(context.TODO(), bson.M{"email": email}).Decode(&existing)
	if err == nil {
		log.Printf("Admin user %s already exists.", email)
		return
	}

	hashed, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		log.Fatal(err)
	}

	adminUser := domain.User{
		ID:           uuid.New().String(),
		Email:        email,
		PasswordHash: string(hashed),
		FullName:     "System Administrator",
		Role:         domain.RoleSuperAdmin,
		IsVerified:   true, // Auto-verify
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	}

	_, err = userColl.InsertOne(context.TODO(), adminUser)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("------------------------------------------------")
	fmt.Println("Admin Account Created Successfully!")
	fmt.Printf("Email:    %s\n", email)
	fmt.Printf("Password: %s\n", password)
	fmt.Println("------------------------------------------------")
}
