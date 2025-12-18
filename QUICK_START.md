# Quick Start - VibeCheck App

## Current Status:
✅ Backend code is ready  
✅ Frontend code is ready  
❌ Docker Desktop not running (Database/Redis unavailable)  
❌ Flutter SDK not installed

---

## What You Need to Install:

### 1. **Install Docker Desktop** (For Database)
- Download: https://www.docker.com/products/docker-desktop
- Install and start Docker Desktop
- Then run: `docker-compose up -d`

### 2. **Install Flutter** (For Mobile App)
- Download: https://flutter.dev/docs/get-started/install/windows
- Extract to `C:\flutter`
- Add to PATH: `C:\flutter\bin`
- Verify: `flutter --version`

---

## Once Installed, Run This:

```bash
# Terminal 1: Start Database
docker-compose up -d

# Terminal 2: Start Backend
cd backend
npm run dev

# Terminal 3: Run Flutter App
cd frontend
flutter pub get
flutter emulators --launch <emulator_id>  # Launch Android emulator
flutter run
```

---

## If You Want to Skip Installation:

### Option A: Use Backend API Only (Test with Postman)
The backend can run without database in mock mode. Test endpoints:
- `POST http://localhost:3000/api/auth/login` - Mock login
- `GET http://localhost:3000/api/health` - Health check

### Option B: Deploy to Cloud (Render/Railway/Heroku)
Push the code to GitHub and deploy backend + frontend separately.

---

## Need Help?
Refer to `RUN_AND_TEST.md` for detailed instructions.
