# Implementation Plan: 30 PRs for "VibeCheck" MVP

This document outlines the 30 Pull Requests (PRs) required to build the "VibeCheck" MVP. Each PR is scoped to be handled by a coding agent.

**General Rules for Coding Agent:**
*   **Stack:** Flutter (Frontend), Node.js + Express (Backend), PostgreSQL (DB), Redis (Cache/Session).
*   **Mocking:** Auth and Payments are MOCKED. No real SMS/Gateway integration.
*   **Legal:** No "Swipe" terminology in UI/Code. Use "Vibe Check" (Buttons) or "Scroll".
*   **Completion:** Mark tasks as completed only when code is committed and basic tests pass.

---

## **Phase 1: Infrastructure & Setup (PRs 1-3)**

### **PR 1: Repository Initialization & Backend Scaffold**
*   **Scope:** Initialize Git repo. Create `backend/` folder. Setup Node.js, Express, TypeScript, ESLint, Prettier.
*   **Tasks:**
    *   `npm init` in `backend/`.
    *   Install `express`, `cors`, `dotenv`, `helmet`.
    *   Create `server.ts` with a health check endpoint `/api/health`.
    *   Setup `tsconfig.json`.

### **PR 2: Frontend Scaffold (Flutter)**
*   **Scope:** Create `frontend/` folder. Initialize Flutter project.
*   **Tasks:**
    *   `flutter create .` in `frontend/`.
    *   Setup folder structure: `lib/screens`, `lib/widgets`, `lib/services`, `lib/models`.
    *   Add dependencies: `provider` (state), `http`, `shared_preferences`.
    *   **Config:** Create a `Config` class to handle API Base URL.
        *   *Note:* Use `http://10.0.2.2:3000` for Android Emulator.
        *   *Note:* Use `http://localhost:3000` for iOS Simulator.
    *   Create a basic "Hello World" screen to verify setup.

### **PR 3: Database & Docker Setup**
*   **Scope:** Setup PostgreSQL and Redis using Docker Compose.
*   **Tasks:**
    *   Create `docker-compose.yml` at root.
    *   Define `postgres` service (User/Pass/DB from `.env`).
    *   Define `redis` service.
    *   Ensure backend can connect to both.

---

## **Phase 2: Mock Authentication (PRs 4-6)**

### **PR 4: Backend - Mock Auth API**
*   **Scope:** Create User Schema and Auth Endpoints.
*   **Tasks:**
    *   Design `User` table (id, phone, email, is_verified, created_at).
    *   Create endpoint `POST /api/auth/login`: Accepts phone/email.
    *   Logic: If user exists, return token. If not, create user -> return token.
    *   **Mock:** No OTP. Just trust the input.

### **PR 5: Frontend - Login Screen**
*   **Scope:** UI for Login.
*   **Tasks:**
    *   Create `LoginScreen`.
    *   Input fields: Phone Number, Email.
    *   "Get Started" button.
    *   Call `POST /api/auth/login` on button press.
    *   Save token to `SharedPreferences`.

### **PR 6: Auth Integration & Session Management**
*   **Scope:** Connect Frontend to Backend Auth.
*   **Tasks:**
    *   Create `AuthService` in Flutter.
    *   Handle "Logged In" state (Redirect to Home if token exists).
    *   Add "Logout" button in a temporary drawer.

---

## **Phase 3: User Profile Management (PRs 7-10)**

### **PR 7: Backend - Profile CRUD**
*   **Scope:** API to manage user details.
*   **Tasks:**
    *   Update `User` table: Add `gender`, `looking_for`, `bio`, `birthdate`.
    *   Create `PUT /api/profile`: Update profile fields.
    *   Create `GET /api/profile`: Get own profile.

### **PR 8: Frontend - Profile Creation Flow (Part 1)**
*   **Scope:** Basic Info Screens.
*   **Tasks:**
    *   Screen 1: Name & Gender (Male/Female/Non-Binary).
    *   Screen 2: "Looking For" (Men/Women/Couples).
    *   Screen 3: Bio (Max 200 chars).

### **PR 9: Frontend - Photo Upload (Mock)**
*   **Sc**Permissions:** Update `AndroidManifest.xml` (Android) and `Info.plist` (iOS) for Camera/Gallery access.
    *   ope:** UI to pick photos.
*   **Tasks:**
    *   Use `image_picker` package.
    *   Allow selecting up to 3 photos.
    *   **Mock:** Convert image to Base64 string and send to backend (for MVP simplicity) OR just store local path if backend storage isn't ready (Prefer Base64 for full flow).

### **PR 10: Kinks & Tags System**
*   **Scope:** Tag selection UI and Backend storage.
*   **Tasks:**
    *   Backend: `Tags` table or JSONB column in User.
    *   Frontend: "Select Your Vibe" screen. Chips for *Dom, Sub, NSA, FWB, etc.*.
    *   Save tags to profile.

---

## **Phase 4: Discovery & Matching (PRs 11-15)**

### **PR 11: Backend - Discovery Algorithm**
*   **Scope:** API to fetch potential matches.
*   **Tasks:**
    *   `GET /api/feed`: Return users matching `looking_for` criteria.
    *   Exclude users already liked/passed.
    *   **Mock Location:** Just return all users for now (ignore 5km radius for initial PR).

### **PR 12: Frontend - The "Card Stack" (Vertical Scroll)**
*   **Scope:** The main feed UI.
*   **Tasks:**
    *   Implement a Vertical Scroll View (Instagram Reels style) or a Card Stack.
    *   **Crucial:** NO SWIPE GESTURES.
    *   Display User Photo, Name, Age, Tags.

### **PR 13: Interaction UI - "Vibe Check" Buttons**
*   **Scope:** Like/Pass Action Buttons.
*   **Tasks:**
    *   Add floating buttons: "Green Check" (Like) and "Red X" (Pass).
    *   Wire buttons to API calls.

### **PR 14: Backend - Like/Pass Logic**
*   **Scope:** Handle interactions.
*   **Tasks:**
    *   Create `Interaction` table (from_user, to_user, action: 'like'|'pass').
    *   `POST /api/interact`: Record action.
    *   **Match Logic:** Check if `to_user` already liked `from_user`. If yes -> Create `Match`.

### **PR 15: "Roll the Dice" Feature**
*   **Scope:** Random Match Feature.
*   **Tasks:**
    *   Backend: `GET /api/dice`: Return 1 random user.
    *   Frontend: "Dice" button on Home.
    *   Animation: Simple rotation/shake.
    *   Show the random profile.

---

## **Phase 5: Chat System (PRs 16-20)**

### **PR 16: Backend - WebSocket Setup**
*   **Scope:** Real-time infrastructure.
*   **Tasks:**
    *   Install `socket.io`.
    *   Setup Socket server attached to Express.
    *   Events: `connection`, `join_room`, `send_message`.

### **PR 17: Frontend - Chat List UI**
*   **Scope:** List of matches.
*   **Tasks:**
    *   `MatchesScreen`: List of users you matched with.
    *   Show "New Matches" vs "Active Chats".

### **PR 18: Frontend - Chat Room UI**
*   **Scope:** Messaging Interface.
*   **Tasks:**
    *   Bubble UI (Left/Right).
    *   Input field.
    *   Send button.
    *   Connect to Socket room (room_id = match_id).

### **PR 19: Backend - Message Persistence & History**
*   **Scope:** Saving chats.
*   **Tasks:**
    *   `Message` table (match_id, sender_id, content, created_at, viewed_at).
    *   Save messages to DB on `send_message` event.
    *   `GET /api/chat/:matchId`: Load history.

### **PR 20: Vanishing Logic (The "Pure" Feature)**
*   **Scope:** Auto-delete messages.
*   **Tasks:**
    *   Backend: Cron job or Redis expiry.
    *   Logic: If `viewed_at` is set, delete message after 24h.
    *   Frontend: Visual timer (optional for this PR, but backend logic must exist).

---

## **Phase 6: Economy & Mock Payments (PRs 21-24)**

### **PR 21: Backend - Credit System**
*   **Scope:** Wallet logic.
*   **Tasks:**
    *   Add `credits` column to `User` table. Default = 0.
    *   `POST /api/wallet/add`: Mock endpoint to add credits.

### **PR 22: Frontend - Wallet Screen**
*   **Scope:** UI to see balance and buy options.
*   **Tasks:**
    *   Display current "Sparks/Credits".
    *   List packages (e.g., "100 Sparks - ₹1000").

### **PR 23: Mock Payment Gateway**
*   **Scope:** The "Buy" interaction.
*   **Tasks:**
    *   On clicking a package -> Show "Processing..." spinner.
    *   Wait 2 seconds.
    *   Show "Success!" dialog.
    *   Call `POST /api/wallet/add` to update balance.

### **PR 24: Gating Logic (Pay to Chat)**
*   **Scope:** Enforce credit costs.
*   **Tasks:**
    *   Backend: Check balance before allowing specific actions (e.g., Male messaging first).
    *   Frontend: Show "Unlock Chat (10 Credits)" popup if balance is low or required.

---

## **Phase 7: Notifications & Settings (PRs 25-26)**

### **PR 25: Notification Center**
*   **Scope:** In-app alerts.
*   **Tasks:**
    *   `Notifications` table.
    *   UI: Tab for "Activity" (New Likes, Dice Rolls).

### **PR 26: Settings & Account Management**
*   **Scope:** User control.
*   **Tasks:**
    *   Edit Profile (revisit PR 7).
    *   **Delete Account:** Crucial for privacy. Hard delete from DB.

---

## **Phase 8: Polish & Testing (PRs 27-30)**

### **PR 27: Trust & Safety - Reporting**
*   **Scope:** Report User functionality.
*   **Tasks:**
    *   "Report" button on profile.
    *   Backend: `Reports` table.
    *   Auto-block logic (Mock: If reported, hide user locally).

### **PR 28: UI Polish - "Nightlife" Theme**
*   **Scope:** Styling.
*   **Tasks:**
    *   Apply Dark Mode (Neon Purple/Blue).
    *   Ensure fonts are readable.
    *   Consistent button styles.

### **PR 29: End-to-End Testing (Manual Fixes)**
*   **Scope:** Walkthrough.
*   **Tasks:**
    *   Verify: Login -> Create Profile -> Match -> Chat -> Pay -> Chat Vanish.
    *   Fix any broken links in the flow.

### **PR 30: Final Cleanup & Documentation**
*   **Scope:** Ready for handoff.
*   **Tasks:**
    *   Remove unused code.
    *   Update `README.md` with "How to Run" instructions.
    *   Ensure `docker-compose up` works for a fresh start.
