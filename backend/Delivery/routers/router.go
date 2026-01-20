package routers

import (
	"github.com/StartUp/safecampus/backend/Delivery/handlers"
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
) *gin.Engine {
	r := gin.Default()

	// Public routes
	r.POST("/register", userHandler.Register)
	r.POST("/verify-email", userHandler.VerifyEmail)
	r.POST("/resend-verification", userHandler.ResendVerification)
	r.POST("/login", userHandler.Login)
	r.POST("/refresh-token", userHandler.RefreshToken)

	// Protected routes (Add middleware later)
	api := r.Group("/api")
	{
		// Alert / SOS routes
		api.POST("/alerts/sos", alertHandler.TriggerSOS)
		api.PUT("/alerts/:id/resolve", alertHandler.ResolveAlert)

		// Report routes
		api.POST("/reports", reportHandler.SubmitReport)
		api.GET("/reports", reportHandler.GetReports)

		// Chat routes
		api.POST("/chats/messages", chatHandler.SendMessage)
		api.GET("/chats/:reportId/messages", chatHandler.GetHistory)

		// Zone Check (Simulating Geofence background check)
		api.POST("/zone/check", zoneHandler.CheckZone)

		// Walk routes
		api.POST("/walks/start", walkHandler.StartWalk)
		api.POST("/walks/:id/location", walkHandler.UpdateLocation)
		api.POST("/walks/:id/end", walkHandler.EndWalk)

		// Safety Timer routes
		api.POST("/timers", timerHandler.SetTimer)
		api.POST("/timers/:id/cancel", timerHandler.CancelTimer)
	}

	return r
}
