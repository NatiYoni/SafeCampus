package domain

type ResourceType string

const (
	ResourceTypeArticle ResourceType = "ARTICLE"
	ResourceTypeHotline ResourceType = "HOTLINE"
	ResourceTypeContact ResourceType = "CONTACT"
	ResourceTypeVideo   ResourceType = "VIDEO"
)

type MentalHealthResource struct {
	ID          string       `json:"id" bson:"_id"`
	Title       string       `json:"title" bson:"title"`
	Description string       `json:"description" bson:"description"`
	Type        ResourceType `json:"type" bson:"type"`
	ContentURL  string       `json:"content_url" bson:"content_url"` // URL to article, or phone number
	Thumbnail   string       `json:"thumbnail,omitempty" bson:"thumbnail,omitempty"`
}

type AIChatRequest struct {
	Message string          `json:"message"`
	History []AIChatMessage `json:"history,omitempty"`
}

type AIChatMessage struct {
	Role    string `json:"role"` // "user" or "model"
	Content string `json:"content"`
}

type AIChatResponse struct {
	Response string `json:"response"`
}

// MentalHealthRepository is defined in repositories.go
