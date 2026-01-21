package main

import (
	"context"
	"log"
	"os"
	"time"

	"github.com/StartUp/safecampus/backend/Delivery/handlers"
	"github.com/StartUp/safecampus/backend/Delivery/routers"
	domain "github.com/StartUp/safecampus/backend/Domain"
	infrastructure "github.com/StartUp/safecampus/backend/Infrastructure"
	repositories "github.com/StartUp/safecampus/backend/Repositories"
	usecases "github.com/StartUp/safecampus/backend/Usecases"
	"github.com/google/uuid"
	"github.com/joho/godotenv"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"golang.org/x/crypto/bcrypt"
)

func seedAdminUser(db *mongo.Database) {
	email := "admin@safecampus.com"
	password := "admin123"

	collection := db.Collection("users")

	// Check if admin exists
	var existing domain.User
	err := collection.FindOne(context.TODO(), bson.M{"email": email}).Decode(&existing)
	if err == nil {
		log.Println("✅ Admin account already exists.")
		return
	}

	// Create Admin
	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)

	admin := domain.User{
		ID:           uuid.New().String(),
		Email:        email,
		PasswordHash: string(hashedPassword),
		FullName:     "System Administrator",
		Role:         domain.RoleSuperAdmin,
		IsVerified:   true,
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	}

	_, err = collection.InsertOne(context.TODO(), admin)
	if err != nil {
		log.Printf("❌ Failed to seed admin: %v\n", err)
	} else {
		log.Println("🚀 Admin account created successfully!")
		log.Printf("📧 Email: %s\n", email)
		log.Printf("🔑 Password: %s\n", password)
	}
}

func main() {
	// Load .env file if it exists (for local development)
	_ = godotenv.Load()

	// 1. Database Connection
	mongoURI := os.Getenv("MONGO_URI")
	if mongoURI == "" {
		// Fallback for local testing if env is not provided.
		// For Render, you MUST set MONGO_URI in the interface.
		mongoURI = "mongodb://localhost:27017"
		log.Println("MONGO_URI not set, using default: " + mongoURI)
	}

	client, err := infrastructure.NewMongoClient(mongoURI)
	if err != nil {
		log.Fatalf("Failed to connect to MongoDB: %v", err)
	}

	// Use the "safecampus" database
	db := client.Database("safecampus")

	// 1.5 Seed Admin User (Added)
	seedAdminUser(db)

	// 2. Initialize Repositories
	userRepo := repositories.NewUserRepository(db)
	invitationRepo := repositories.NewInvitationRepository(db)
	alertRepo := repositories.NewAlertRepository(db)

	// Ensure TTL Index for Alerts
	if r, ok := alertRepo.(*repositories.AlertRepository); ok {
		go func() {
			if err := r.EnsureTTLIndex(context.Background()); err != nil {
				log.Printf("Failed to create TTL index: %v", err)
			}
		}()
	}

	reportRepo := repositories.NewReportRepository(db)
	chatRepo := repositories.NewChatRepository(db)
	zoneRepo := repositories.NewZoneRepository(db)
	walkRepo := repositories.NewWalkRepository(db)
	timerRepo := repositories.NewSafetyTimerRepository(db)
	mentalRepo := repositories.NewMentalHealthRepository(db)

	// 2.5 Initialize Infrastructure Services
	emailService := infrastructure.NewEmailService()
	jwtService := infrastructure.NewJWTService()

	// 3. Initialize Usecases
	timeout := time.Second * 10

	userUsecase := usecases.NewUserUsecase(userRepo, invitationRepo, emailService, jwtService, timeout)

	alertUsecase := usecases.NewAlertUsecase(alertRepo, userRepo, timeout)
	reportUsecase := usecases.NewReportUsecase(reportRepo, timeout)
	chatUsecase := usecases.NewChatUsecase(chatRepo, timeout)
	zoneUsecase := usecases.NewZoneUsecase(zoneRepo, timeout)
	walkUsecase := usecases.NewWalkUseCase(walkRepo)
	timerUsecase := usecases.NewSafetyTimerUsecase(timerRepo, timeout)
	mentalUsecase := usecases.NewMentalHealthUsecase(mentalRepo, timeout)

	// 4. Initialize Handlers
	userHandler := handlers.NewUserHandler(userUsecase)
	alertHandler := handlers.NewAlertHandler(alertUsecase)
	reportHandler := handlers.NewReportHandler(reportUsecase)
	chatHandler := handlers.NewChatHandler(chatUsecase)
	zoneHandler := handlers.NewZoneHandler(zoneUsecase)
	walkHandler := handlers.NewWalkHandler(walkUsecase)
	timerHandler := handlers.NewSafetyTimerHandler(timerUsecase)
	mentalHandler := handlers.NewMentalHealthHandler(mentalUsecase)

	// 5. Setup Router
	r := routers.SetupRouter(userHandler, alertHandler, reportHandler, chatHandler, zoneHandler, walkHandler, timerHandler, mentalHandler, jwtService)

	// 6. Run Server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Println("SafeCampus Backend running on port " + port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("Failed to run server: %v", err)
	}
}
