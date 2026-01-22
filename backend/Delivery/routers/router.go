package routers

import (
	"github.com/StartUp/safecampus/backend/Delivery/handlers"
	"github.com/StartUp/safecampus/backend/Delivery/middleware"
	infrastructure "github.com/StartUp/safecampus/backend/Infrastructure"
	"github.com/gin-gonic/gin"
)

func SetupRouter(
	userHandler *handlers.UserHandler,
	alertHandler *handlers.AlertHandler,
	reportHandler *handlers.ReportHandler,
	chatHandler *handlers.ChatHandler,
	zoneHandler *handlers.ZoneHandler,
	walkHandler *handlers.WalkHandler,
	timerHandler *handlers.SafetyTimerHandler,
	mentalHandler *handlers.MentalHealthHandler,
	campusHandler *handlers.CampusHandler,
	articleHandler *handlers.ArticleHandler,
	jwtService *infrastructure.JWTService,
) *gin.Engine {
	r := gin.Default()

	// Public routes
	r.POST("/register", userHandler.Register)
	r.POST("/verify-email", userHandler.VerifyEmail)
	r.POST("/resend-verification", userHandler.ResendVerification)
	r.POST("/login", userHandler.Login)
	r.POST("/refresh-token", userHandler.RefreshToken)

	// Admin routes
	admin := r.Group("/admin")

	// Public Admin Routes (e.g. consuming an invite)
	admin.POST("/register", userHandler.RegisterAdmin)

	// Protected Admin Routes
	adminProtected := admin.Group("/")
	adminProtected.Use(middleware.AuthMiddleware(jwtService))
	{
		adminProtected.POST("/invite", userHandler.InviteAdmin)
		adminProtected.POST("/promote", userHandler.PromoteUser)
		adminProtected.POST("/articles", articleHandler.CreateArticle) // New Article Route
		adminProtected.GET("/users/search", userHandler.FindUserByUniID)
	}

	// Protected routes (Add middleware later)
	api := r.Group("/api")
	api.Use(middleware.AuthMiddleware(jwtService))
	{
		// User Profile routes
		api.GET("/profile/:id", userHandler.GetProfile) // ID param is optional if we trust token but handler uses Param
		api.PUT("/profile", userHandler.UpdateProfile)
		api.POST("/profile/change-password", userHandler.ChangePassword)

		// Articles (Public/Student view)
		api.GET("/articles", articleHandler.GetArticles)

		// Alert / SOS routes
		api.POST("/alerts/sos", alertHandler.TriggerSOS)
		api.GET("/alerts/sos", alertHandler.GetAllAlerts)
		api.GET("/alerts/my-active", alertHandler.GetMyActiveAlert)
		api.PUT("/alerts/:id/resolve", alertHandler.ResolveAlert)

		// Report routes
		api.POST("/reports", reportHandler.SubmitReport)
		api.GET("/reports", reportHandler.GetReports)
		api.PUT("/reports/:id/resolve", reportHandler.ResolveReport)

		// Chat routes
		api.POST("/chats/messages", chatHandler.SendMessage)
		api.GET("/chats/:reportId/messages", chatHandler.GetHistory)

		// Zone Check (Simulating Geofence background check)
		api.POST("/zone/check", zoneHandler.CheckZone)
		api.GET("/zones", zoneHandler.GetAllZones)

		// Walk routes
		api.POST("/walks/start", walkHandler.StartWalk)
		api.POST("/walks/:id/location", walkHandler.UpdateLocation)
		api.POST("/walks/:id/end", walkHandler.EndWalk)
		api.GET("/walks/active", walkHandler.GetAllActiveWalks)

		// Safety Timer routes
		api.POST("/timers", timerHandler.SetTimer)
		api.POST("/timers/:id/cancel", timerHandler.CancelTimer)

		// Mental Health routes
		api.GET("/mental-health", mentalHandler.GetResources)
		api.POST("/mental-health/chat", mentalHandler.ChatWithCompanion)

		// Campus Radar routes
		api.POST("/campus/heartbeat", campusHandler.Heartbeat)
		api.GET("/campus/status", campusHandler.GetCampusStatus)
	}

	return r
}
