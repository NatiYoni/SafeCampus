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
)

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

	// 2. Initialize Repositories
	userRepo := repositories.NewUserRepository(db)
	invitationRepo := repositories.NewInvitationRepository(db)
	alertRepo := repositories.NewAlertRepository(db)
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

	// Seed Super Admin
	seedCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	// Use environment variables or hardcoded fallback
	adminEmail := os.Getenv("ADMIN_EMAIL")
	if adminEmail == "" {
		adminEmail = "admin@safecampus.edu"
	}
	adminPass := os.Getenv("ADMIN_PASS")
	if adminPass == "" {
		adminPass = "AdminSecret123!"
	}

	if err := userUsecase.EnsureSuperAdmin(seedCtx, adminEmail, adminPass); err != nil {
		log.Printf("Warning: Failed to ensure super admin: %v", err)
	} else {
		log.Println("Super Admin check completed.")
	}

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
	r := routers.SetupRouter(userHandler, alertHandler, reportHandler, chatHandler, zoneHandler, walkHandler, timerHandler, mentalHandler)

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
