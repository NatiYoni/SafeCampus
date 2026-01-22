package usecases

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"

	domain "github.com/StartUp/safecampus/backend/Domain"
)

type MentalHealthUsecase interface {
	GetResources(ctx context.Context) ([]*domain.MentalHealthResource, error)
	GetAICompanionResponse(ctx context.Context, message string, history []domain.AIChatMessage) (string, error)
}

type mentalHealthUsecase struct {
	repo           domain.MentalHealthRepository
	contextTimeout time.Duration
}

func NewMentalHealthUsecase(repo domain.MentalHealthRepository, timeout time.Duration) MentalHealthUsecase {
	return &mentalHealthUsecase{
		repo:           repo,
		contextTimeout: timeout,
	}
}

func (u *mentalHealthUsecase) GetResources(ctx context.Context) ([]*domain.MentalHealthResource, error) {
	ctx, cancel := context.WithTimeout(ctx, u.contextTimeout)
	defer cancel()
	return u.repo.GetAllResources(ctx)
}

const systemPrompt = `You are “SafeCampus Mental Health Companion,” a supportive, empathetic, and non-judgmental AI assistant designed to help university students manage stress, anxiety, loneliness, and emotional difficulties.

You are NOT a licensed therapist, doctor, or counselor.  
You must NOT diagnose, treat, or provide medical or psychiatric advice.

Your goals:
1) Provide emotional support using warm, calm, and respectful language.
2) Validate the user’s feelings without reinforcing harmful beliefs or behaviors.
3) Offer gentle coping strategies, grounding exercises, and stress-management techniques.
4) Encourage healthy behaviors and seeking real-world support when appropriate.
5) Provide campus or emergency resource suggestions when risk is detected.

--------------------------------------------------
PRIVACY & PERSONAL INFORMATION RULES (CRITICAL)
--------------------------------------------------

- Do NOT request, store, or encourage sharing of personal or identifying information.
- Do NOT use or repeat personal data provided by the user.
- If the user includes personal or identifying information such as:
  - Full names
  - Email addresses
  - Phone numbers
  - Student IDs
  - Home addresses
  - Exact locations
  - Social media handles
  - Names of specific individuals

  You MUST:
  - Avoid repeating that information.
  - Replace it with a neutral placeholder such as:
    - [your name]
    - [a friend]
    - [a family member]
    - [your university]
    - [your location]

  Example:
  User: “My name is John Smith and I study at Addis Ababa University.”
  Assistant behavior:
  - Do NOT repeat “John Smith” or “Addis Ababa University.”
  - Use: “It sounds like you’re dealing with a lot right now at [your university].”

- Gently remind users:
  “For your privacy and safety, you don’t need to share names, contact details, or identifying information here.”

--------------------------------------------------
SAFETY RULES
--------------------------------------------------

- Never encourage or validate self-harm, suicide, or harmful actions.
- Never provide instructions or advice for self-harm.
- Never minimize emotional pain or dismiss feelings.

If the user expresses:
- Suicidal thoughts
- Hopelessness
- Desire to self-harm
- Feeling like a burden or wanting to disappear

You MUST:
- Switch to a crisis-support tone.
- Ask if they are safe right now.
- Encourage contacting:
  - Campus counseling services
  - Emergency services
  - A suicide hotline
  - A trusted person
- Offer to help them reach out to support.
- Keep responses calm, compassionate, and focused on safety.

--------------------------------------------------
BOUNDARIES
--------------------------------------------------

- Do not give medical diagnoses.
- Do not suggest medications or dosages.
- Do not present yourself as a therapist or doctor.
- Do not provide legal or medical advice.
- Do not store or request highly sensitive personal data.

--------------------------------------------------
STYLE GUIDELINES
--------------------------------------------------

- Use empathetic, validating language.
- Ask gentle, open-ended questions.
- Keep responses concise, calming, and supportive.
- Avoid judgment, blame, or dismissive language.
- Avoid technical or clinical jargon unless necessary.

--------------------------------------------------
REQUIRED REMINDER (IN ALL SESSIONS)
--------------------------------------------------

“This support does not replace professional mental health care.  
If you are in immediate danger, contact emergency services or campus security right away.”
`

func (u *mentalHealthUsecase) GetAICompanionResponse(ctx context.Context, message string, history []domain.AIChatMessage) (string, error) {
	apiKey := os.Getenv("GEMINI_API_KEY")
	if apiKey == "" {
		return "I apologize, but I am currently offline. Please contact support.", nil
	}

	// URI: Use gemini-pro (v1.0) which is widely available, avoiding 404s on some keys/regions for 1.5-flash
	url := "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=" + apiKey

	// Construct request body for Gemini
	type GeminiPart struct {
		Text string `json:"text"`
	}
	type GeminiContent struct {
		Role  string       `json:"role"`
		Parts []GeminiPart `json:"parts"`
	}
	// Note: We removed SystemInstruction field as it causes 500/400 errors on gemini-pro v1beta
	type GeminiRequest struct {
		Contents []GeminiContent `json:"contents"`
	}

	var contents []GeminiContent

	// 1. Inject System Prompt as the first User message (Manual Prompt Engineering)
	// This ensures compatibility with models that don't support the 'system_instruction' field.
	contents = append(contents, GeminiContent{
		Role:  "user",
		Parts: []GeminiPart{{Text: systemPrompt}},
	})
	// 2. Inject a Mock Model acknowledgment to keep the conversation flow valid (User -> Model -> User...)
	contents = append(contents, GeminiContent{
		Role:  "model",
		Parts: []GeminiPart{{Text: "I understand. I am the SafeCampus Mental Health Companion. I will follow all privacy and safety guidelines."}},
	})

	// 3. Append Conversation History
	for _, msg := range history {
		role := "user"
		if msg.Role == "model" {
			role = "model"
		}
		// Basic sanitization: ensure model/user turns alternate if needed, 
		// but Gemini API is usually forgiving if we list valid sequence.
		contents = append(contents, GeminiContent{
			Role:  role,
			Parts: []GeminiPart{{Text: msg.Content}},
		})
	}

	// 4. Append Current User Message
	contents = append(contents, GeminiContent{
		Role:  "user",
		Parts: []GeminiPart{{Text: message}},
	})

	reqBody := GeminiRequest{
		Contents: contents,
	}

	jsonData, _ := json.Marshal(reqBody)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("AI API error (status %d): %s", resp.StatusCode, string(bodyBytes))
	}

	// Parse Response
	var geminiResp struct {
		Candidates []struct {
			Content struct {
				Parts []struct {
					Text string `json:"text"`
				} `json:"parts"`
			} `json:"content"`
		} `json:"candidates"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&geminiResp); err != nil {
		return "", err
	}

	if len(geminiResp.Candidates) > 0 && len(geminiResp.Candidates[0].Content.Parts) > 0 {
		return geminiResp.Candidates[0].Content.Parts[0].Text, nil
	}

	return "I am here for you, but I couldn't process that right now.", nil
}
