# SafeCampus

SafeCampus is a comprehensive cross-platform solution designed to enhance campus safety and student well-being. It consists of a Flutter-based mobile application and a Go-based backend API, both following Clean Architecture principles for maintainability and scalability.

---

## Table of Contents
- [Features](#features)
- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Backend Setup (Go)](#backend-setup-go)
  - [Mobile App Setup (Flutter)](#mobile-app-setup-flutter)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## Features

### Mobile App (Flutter)
- **User Authentication**: Secure registration and login.
- **Real-Time Alerts**: Receive campus safety notifications and emergency alerts.
- **Mental Health Support**: Access resources and chat with counselors.
- **Safety Timer**: Set a timer for safe walks; notifies contacts if you don't check in.
- **Incident Reporting**: Report safety or mental health incidents directly from the app.
- **Campus Information**: View campus zones, articles, and resources.
- **Chat**: Communicate with support staff or peers.

### Backend API (Go)
- **RESTful API**: Handles all app data and business logic.
- **MongoDB Integration**: Stores user data, reports, alerts, and more.
- **JWT Authentication**: Secures API endpoints.
- **Email Service**: Sends notifications and alerts.
- **Modular Clean Architecture**: Organized by domain, delivery, infrastructure, repositories, and use cases.

---

## Architecture Overview

- **Mobile (Flutter)**: Implements Clean Architecture with clear separation between core, features, and presentation layers. Supports Android, iOS, web, macOS, Windows, and Linux.
- **Backend (Go)**: Follows Clean Architecture, separating business logic, data access, and delivery mechanisms. Uses MongoDB for persistence and JWT for authentication.

---

## Project Structure

```
SafeCampus/
├── backend/         # Go backend API
│   ├── cmd/         # Entry points for API and seeders
│   ├── Delivery/    # Handlers, middleware, routers
│   ├── Domain/      # Core domain models
│   ├── Infrastructure/ # Services (email, JWT, DB)
│   ├── Repositories/    # Data access logic
│   └── Usecases/    # Business logic
├── mobile/          # Flutter mobile app
│   ├── lib/         # Dart source code
│   ├── android/     # Android-specific files
│   ├── ios/         # iOS-specific files
│   ├── assets/      # Images, icons
│   └── test/        # Unit/widget tests
└── README.md        # Project documentation
```

---

## Getting Started

### Prerequisites
- [Flutter](https://flutter.dev/docs/get-started/install)
- [Go](https://golang.org/doc/install)
- [MongoDB](https://www.mongodb.com/try/download/community)
- Docker (optional, for backend)

### Backend Setup (Go)
1. Navigate to `backend/`:
   ```sh
   cd backend
   ```
2. Install dependencies:
   ```sh
   go mod tidy
   ```
3. Configure environment variables (see `.env.example` if available).
4. Run the API server:
   ```sh
   go run cmd/api/main.go
   ```
5. (Optional) Seed the database:
   ```sh
   go run cmd/seed/main.go
   ```
6. (Optional) Run with Docker:
   ```sh
   docker build -t safecampus-backend .
   docker run -p 8080:8080 safecampus-backend
   ```

### Mobile App Setup (Flutter)
1. Navigate to `mobile/`:
   ```sh
   cd mobile
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Run the app:
   ```sh
   flutter run
   ```

---

## Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## License
This project is licensed under the MIT License.

---

## Contact
For questions or support, please contact the project owner or open an issue.
