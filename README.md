# Pure - Auth Only

A minimal authentication-only app built with Express/TypeScript backend and Flutter frontend. This serves as the clean starting point for building the Pure dating app from scratch.

## Features

- **Mock Authentication** - Login/register with phone or email
- **JWT Token** - Secure token-based authentication
- **PostgreSQL** - User data storage
- **Redis** - Session management (ready for future use)
- **Flutter Frontend** - Login screen with auth state management

## Getting Started

### Prerequisites
- Node.js (v18 or later)
- Flutter SDK (3.0 or later)
- Docker & Docker Compose (for database services)

### Database Setup

```bash
# Start PostgreSQL and Redis services
docker-compose up -d
```

### Backend Setup

```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

The backend API will be available at `http://localhost:3000`.

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/health` | GET | Health check |
| `/api/auth/login` | POST | Login or register |

**Login Request:**
```json
{
  "phone": "+1234567890",
  "email": "user@example.com"
}
```

**Login Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "jwt-token-here",
    "user": {
      "id": "uuid",
      "phone": "+1234567890",
      "email": "user@example.com",
      "is_verified": false,
      "created_at": "2024-01-01T00:00:00.000Z"
    }
  }
}
```

### Frontend Setup

```bash
cd frontend
flutter pub get
flutter run
```

## Project Structure

```
├── backend/
│   ├── src/
│   │   ├── server.ts           # Express server
│   │   ├── config/
│   │   │   └── database.ts     # PostgreSQL & Redis config
│   │   ├── middleware/
│   │   │   └── auth.ts         # JWT auth middleware
│   │   ├── models/
│   │   │   └── user.ts         # User model
│   │   └── routes/
│   │       └── auth.ts         # Auth routes
│   ├── package.json
│   └── tsconfig.json
├── frontend/
│   ├── lib/
│   │   ├── main.dart           # App entry + auth wrapper
│   │   ├── config.dart         # API configuration
│   │   ├── screens/
│   │   │   └── login_screen.dart
│   │   ├── services/
│   │   │   └── auth_service.dart
│   │   ├── widgets/
│   │   └── theme/
│   └── pubspec.yaml
├── docker-compose.yml
└── README.md
```

## Environment Variables

```bash
PORT=3000
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=vibecheck
POSTGRES_PASSWORD=vibecheck_dev
POSTGRES_DB=vibecheck
REDIS_HOST=localhost
REDIS_PORT=6379
JWT_SECRET=your-super-secret-jwt-key-change-in-production
```
