package main

import (
	"context"
	"log"
	"os"
	"time"

	"github.com/StartUp/safecampus/backend/Delivery/handlers"
	"github.com/StartUp/safecampus/backend/Delivery/routers"
	infrastructure "github.com/StartUp/safecampus/backend/Infrastructure"
	repositories "github.com/StartUp/safecampus/backend/Repositories"
	usecases "github.com/StartUp/safecampus/backend/Usecases"
	"github.com/joho/godotenv"
	"go.mongodb.org/mongo-driver/mongo"
)

func seedAdminUser(db *mongo.Database) {
	// Functionality removed for security
	return
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

	// 1.5 Seed Admin User (Removed)
	// seedAdminUser(db)

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
	campusRepo := repositories.NewCampusRepository(db) // Added CampusRepo
	timerRepo := repositories.NewSafetyTimerRepository(db)
	mentalRepo := repositories.NewMentalHealthRepository(db)

	// 2.5 Initialize Infrastructure Services
	emailService := infrastructure.NewEmailService()
	jwtService := infrastructure.NewJWTService()

	// 3. Initialize Usecases
	timeout := time.Second * 10

	userUsecase := usecases.NewUserUsecase(userRepo, invitationRepo, emailService, jwtService, timeout)

	alertUsecase := usecases.NewAlertUsecase(alertRepo, userRepo, timeout)
	reportUsecase := usecases.NewReportUsecase(reportRepo, userRepo, timeout)
	chatUsecase := usecases.NewChatUsecase(chatRepo, timeout)
	zoneUsecase := usecases.NewZoneUsecase(zoneRepo, timeout)
	walkUsecase := usecases.NewWalkUseCase(walkRepo)
	campusUsecase := usecases.NewCampusUseCase(campusRepo) // Added CampusUseCase, no timeout passed in constructor logic provided earlier
	timerUsecase := usecases.NewSafetyTimerUsecase(timerRepo, timeout)
	mentalUsecase := usecases.NewMentalHealthUsecase(mentalRepo, timeout)

	// 4. Initialize Handlers
	userHandler := handlers.NewUserHandler(userUsecase)
	alertHandler := handlers.NewAlertHandler(alertUsecase)
	reportHandler := handlers.NewReportHandler(reportUsecase)
	chatHandler := handlers.NewChatHandler(chatUsecase)
	zoneHandler := handlers.NewZoneHandler(zoneUsecase)
	walkHandler := handlers.NewWalkHandler(walkUsecase)
	campusHandler := handlers.NewCampusHandler(campusUsecase) // Added CampusHandler
	timerHandler := handlers.NewSafetyTimerHandler(timerUsecase)
	mentalHandler := handlers.NewMentalHealthHandler(mentalUsecase)

	// 5. Setup Router
	r := routers.SetupRouter(userHandler, alertHandler, reportHandler, chatHandler, zoneHandler, walkHandler, timerHandler, mentalHandler, campusHandler, jwtService)

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
