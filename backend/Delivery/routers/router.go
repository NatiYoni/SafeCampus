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
) *gin.Engine {
	r := gin.Default()

	// Public routes
	r.POST("/register", userHandler.Register)
	r.POST("/login", userHandler.Login)

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
		api.POST("/chat", chatHandler.SendMessage)
		api.GET("/chat/:reportId", chatHandler.GetHistory)

		// Zone Check (Simulating Geofence background check)
		api.POST("/zone/check", zoneHandler.CheckZone)
	}

	return r
}
