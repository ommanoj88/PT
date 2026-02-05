# Pure — Flutter Frontend

Auth-only Flutter client for the Pure dating app. Provides login via phone/email and JWT-based session management.

## Running

```bash
flutter pub get
flutter run
```

## Key Files

- `lib/main.dart` — App entry point and auth state wrapper
- `lib/screens/login_screen.dart` — Phone/email login UI
- `lib/services/auth_service.dart` — HTTP calls to backend auth API, token persistence
- `lib/config.dart` — Backend URL configuration
