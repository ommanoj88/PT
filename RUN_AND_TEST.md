# How to Run & Test VibeCheck MVP

This guide covers everything from environment setup to testing the full app flow.

---

## **Prerequisites**

### **For Windows PC:**
1. **Node.js** (v18+): Download from [nodejs.org](https://nodejs.org/)
2. **Flutter SDK** (v3.0+): Download from [flutter.dev](https://flutter.dev/docs/get-started/install/windows)
3. **Android Studio** (with Android SDK): Download from [developer.android.com](https://developer.android.com/studio)
4. **Docker Desktop**: Download from [docker.com](https://www.docker.com/products/docker-desktop)
5. **Git**: [git-scm.com](https://git-scm.com/)
6. **VSCode** (or any IDE): [code.visualstudio.com](https://code.visualstudio.com/)

### **Verify Installations:**
```bash
node --version   # Should be v18+
flutter --version
docker --version
git --version
```

---

## **Step 1: Clone & Setup the Repository**

```bash
# Navigate to your project folder
cd c:\Users\omman\Desktop\PT

# Pull latest changes
git pull origin main

# Check the folder structure
ls
# Should show: README.md, IMPLEMENTATION_PLAN.md, backend/, frontend/
```

---

## **Step 2: Start Backend Services (PostgreSQL + Redis)**

### **Option A: Using Docker Compose (Recommended)**

```bash
# From root of the project
docker-compose up -d

# Verify containers are running
docker ps
# You should see 'postgres' and 'redis' running
```

### **Option B: Manual Setup (If Docker fails)**
- **PostgreSQL:** Install and create a database named `vibecheck`.
- **Redis:** Install and run `redis-server`.

### **Test Database Connectivity:**
```bash
# From backend folder
npm run dev

# In another terminal, check if backend is alive
curl http://localhost:3000/api/health
# Should return: { "status": "ok" }
```

---

## **Step 3: Setup & Run Backend (Node.js)**

```bash
cd backend

# Install dependencies
npm install

# Create .env file
echo PORT=3000 > .env
echo DATABASE_URL=postgresql://user:password@localhost:5432/vibecheck >> .env
echo REDIS_URL=redis://localhost:6379 >> .env

# Run database migrations (when available in later PRs)
# npm run migrate

# Start the server
npm run dev

# Expected output:
# Server running on http://localhost:3000
```

---

## **Step 4: Setup Android Emulator**

### **Option A: Using Android Studio**
1. Open Android Studio.
2. **Device Manager** → **Create Virtual Device**.
3. Select **Pixel 6** (or any modern phone).
4. Choose **API 30** or higher.
5. Create the emulator.

### **Option B: Command Line**
```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_id>
```

### **Verify Emulator is Connected:**
```bash
flutter devices
# Should show your emulator as "connected"
```

---

## **Step 5: Setup & Run Frontend (Flutter)**

```bash
cd frontend

# Get Flutter dependencies
flutter pub get

# Run on the emulator
flutter run

# Once app is running, you should see a "Hello World" screen
# Press 'r' to hot reload, 'R' to restart
```

### **Troubleshooting:**
- **"Unable to connect to backend"?** 
  - Ensure backend is running: `curl http://localhost:3000/api/health`
  - Check that `Config.apiBaseUrl` is set to `http://10.0.2.2:3000` for Android Emulator.
  
- **Emulator is slow?**
  - Enable GPU acceleration in Android Studio or use a Genymotion emulator instead.

---

## **Step 6: Test the Full Flow (Manual Testing)**

### **Scenario: User Signup → Profile → Match → Chat**

#### **1. Login/Signup**
- **App Screen:** Login.
- **Action:** Enter Phone Number (e.g., "9876543210").
- **Expected:** "Get Started" button navigates to Profile Creation.

#### **2. Create Profile**
- **Screen 1:** Gender selection. Choose "Male".
- **Screen 2:** Looking For. Choose "Women".
- **Screen 3:** Bio. Enter "Into tech, hiking".
- **Screen 4:** Upload 3 photos (from gallery).
- **Screen 5:** Select Kinks. Choose "NSA, FWB".
- **Expected:** Save button -> Redirect to Home/Feed.

#### **3. Discover & Match**
- **Home Screen:** Display a user card (from DB or mock data).
- **Action:** Click "Green Check" (Like).
- **Expected:** If other user already liked you -> Match notification.
- **Alternative:** Click "Red X" (Pass) -> Show next user.

#### **4. Chat with Match**
- **Navigate to:** Matches/Chats tab.
- **Action:** Click on a match.
- **Expected:** Open chat room.
- **Send Message:** Type "Hey!" and send.
- **Expected:** Message appears in chat (real-time via WebSocket).

#### **5. Mock Payment**
- **Navigate to:** Wallet/Credits screen.
- **View Balance:** Should show current credits.
- **Buy Credits:** Click "100 Sparks" package.
- **Expected:** Processing spinner -> Success dialog -> Balance updated.

#### **6. Gated Feature (Pay to Chat)**
- **Scenario:** You (Male) match with a Female. She hasn't texted yet.
- **Action:** Try to send a message.
- **Expected:** Popup: "Unlock Chat (10 Credits)" -> Click -> Deduct from balance -> Message sent.

#### **7. Vanishing Chat**
- **Set Timer:** Select "24h" for chat timer.
- **Send Message:** Type and send.
- **Wait/Mock:** In DB, mark as `viewed_at`.
- **Expected (After 24h in production, immediately in tests):** Message disappears from chat.

---

## **Step 7: Automated Testing (When Ready)**

### **Backend Unit Tests:**
```bash
cd backend
npm run test
```

### **Frontend Widget Tests:**
```bash
cd frontend
flutter test
```

---

## **Step 8: Debug & Logs**

### **View Backend Logs:**
```bash
# If running in foreground, logs appear in terminal
# If running in Docker:
docker logs -f <container_id>
```

### **View Frontend Logs:**
```bash
# Flutter console logs appear during `flutter run`
# Tap the home icon in the emulator to see debug output
```

### **Check Database (PostgreSQL):**
```bash
# Connect to PostgreSQL (if installed locally)
psql -U user -d vibecheck

# Common queries:
SELECT * FROM users;
SELECT * FROM interactions;
SELECT * FROM messages;
```

---

## **Step 9: API Testing with Postman/Curl**

### **Example: Mock Login**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone": "9876543210"}'

# Expected Response:
# { "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...", "userId": 1 }
```

### **Example: Get Own Profile**
```bash
curl -X GET http://localhost:3000/api/profile \
  -H "Authorization: Bearer <token_from_above>"

# Expected Response:
# { "id": 1, "phone": "9876543210", "gender": "male", "bio": "Into tech" }
```

---

## **Step 10: Reset Everything (Fresh Start)**

```bash
# Stop all Docker containers
docker-compose down

# Remove databases (WARNING: Data loss)
docker volume prune

# Clear Flutter cache
flutter clean

# Start fresh
docker-compose up -d
cd backend && npm run dev
cd ../frontend && flutter run
```

---

## **Common Issues & Fixes**

| Issue | Solution |
|-------|----------|
| **"Cannot find emulator"** | Run `flutter emulators --launch <id>` first. |
| **"Connection refused on localhost"** | Check if backend is running: `curl http://localhost:3000/api/health` |
| **"Android Emulator won't connect to backend"** | Change `localhost` to `10.0.2.2` in Flutter Config. |
| **"PostgreSQL connection error"** | Verify DB URL in `.env`. Ensure Docker container is running. |
| **"Hot reload not working"** | Try `flutter run -d <device_id>` and then press 'R' (restart). |
| **"Image picker not working on emulator"** | Grant camera/gallery permissions manually in Settings. |

---

## **Next Steps After PR Completion**

Once the coding agent completes a PR:
1. Pull latest code: `git pull origin main`
2. Run `flutter pub get` (if dependencies changed).
3. Run the app: `flutter run`
4. Test the new feature manually using the scenarios above.
5. Report any issues or bugs.
