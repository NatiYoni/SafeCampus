package main

import (
	"context"
	"crypto/rand"
	"encoding/hex"
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

func generateRandomString(length int) string {
	bytes := make([]byte, length/2)
	if _, err := rand.Read(bytes); err != nil {
		return "DefaultPass123"
	}
	return hex.EncodeToString(bytes)
}

func main() {
	// 1. Load Environment
	_ = godotenv.Load() // Loads .env from current directory

	mongoURI := os.Getenv("MONGO_URI")
	if mongoURI == "" {
		fmt.Println("Error: MONGO_URI environment variable is not set.")
		fmt.Println("Usage: MONGO_URI='mongodb+srv://...' go run cmd/create_admin/main.go")
		os.Exit(1)
	}

	// 2. Connect to DB
	fmt.Println("Connecting to MongoDB...")
	client, err := infrastructure.NewMongoClient(mongoURI)
	if err != nil {
		log.Fatalf("Failed to connect: %v", err)
	}
	defer client.Disconnect(context.Background())

	db := client.Database("safecampus")
	userColl := db.Collection("users")

	// 3. Define Admin Credentials
	// You can change these logic to valid random emails if needed
	email := "superadmin_" + generateRandomString(4) + "@safecampus.com"
	password := generateRandomString(12) // Strong random password

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		log.Fatal(err)
	}

	adminUser := domain.User{
		ID:           uuid.New().String(),
		Email:        email,
		PasswordHash: string(hashedPassword),
		FullName:     "Super Administrator",
		Role:         domain.RoleSuperAdmin,
		IsVerified:   true,
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	}

	// 4. Save to DB
	_, err = userColl.InsertOne(context.TODO(), adminUser)
	if err != nil {
		log.Fatalf("Failed to insert admin user: %v", err)
	}

	// 5. Output Credentials
	fmt.Println("\n================================================")
	fmt.Println("   SUPER ADMIN ACCOUNT CREATED SUCCESSFULLY")
	fmt.Println("================================================")
	fmt.Printf(" Email:    %s\n", email)
	fmt.Printf(" Password: %s\n", password)
	fmt.Println("------------------------------------------------")
	fmt.Println(" KEEP THESE CREDENTIALS SAFE!")
	fmt.Println(" Only this account can view full Admin Reports.")
	fmt.Println("================================================")
}
