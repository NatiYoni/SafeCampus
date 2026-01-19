# Safe Campus

Safe Campus is a mobile application designed to ensure safety on campus. 
It consists of a mobile app built with Flutter and a backend built with Go, both following Clean Architecture principles.

## Project Structure

### Mobile (Flutter)
Located in `mobile/`.
Follows Clean Architecture with the following structure:
- `lib/core`: Core functionality common to multiple features.
- `lib/features`: Feature-specific code (Data, Domain, Presentation).

### Backend (Go)
Located in `backend/`.
Follows Clean Architecture with the following structure:
- `cmd/`: Main entry point for the application.
- `config/`: Configuration manager.
- `Delivery/`: Transport layer (HTTP handlers, routers).
- `Domain/`: Core business entities.
- `Infrastructure/`: External services (database connections, third-party APIs).
- `Repositories/`: Data access layer.
- `Usecases/`: Application business logic.
- `docs/`: API documentation and other docs.
