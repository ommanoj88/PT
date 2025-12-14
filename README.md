This is a comprehensive Product Roadmap and Feature Specification for your Bangalore-centric, hookup-focused dating application.

### **Strategic Advisory: Copyright & Market Fit**

**1. Avoiding Copyright Issues (The "Match Group" Danger Zone)**
To prevent lawsuits from giants like Match Group (Tinder, Hinge) or Bumble:
* **Do Not Use "Swipe" Terminology:** Match Group holds patents on the "swipe right/left" *gesture* combined with the *card stack* UI.
    * **Solution:** Use a **"Vibe Check" Button Interface** (Green Check / Red X buttons) or a **Vertical Scroll** (like Instagram Reels). Your "Roll the Dice" feature is a perfect unique differentiator to lean on.
* **Distinct Branding:** Avoid Bumble’s yellow/honeycomb aesthetic and Tinder’s flame/red aesthetic. Go for a sleek, "Nightlife" aesthetic (e.g., Neon Purple/Dark Blue) suitable for a hookup vibe.
* **Niche Positioning:** Your "Vanishing Profile" and "Credit-heavy" model resembles *Pure* but with *Bumble’s* female-first safety. Market this as **"The Privacy-First High-Intent App"**.

**2. The Bangalore Context ("The Silicon Valley of India")**
* **Traffic Logic:** In Bangalore, "Distance" is measured in *time*, not kilometers. A 10km match (Indiranagar to Whitefield) can take 1.5 hours. **Feature:** "Traffic-Adjusted Distance" or strict "5km Radius" filters are crucial.
* **Tech-Savvy Audience:** Users will expect UPI payment integration (PhonePe/GPay) for purchasing credits.
* **Privacy Paranoia:** Bangalore has a conservative underbelly. Users (especially in a hookup app) will value discretion highly (e.g., App Icon Camouflage).

---

### **Product Name Idea**
* **"VibeCheck"** or **"Pulse BLR"** (Keeping it urban and fast-paced).

---

### **1. Comprehensive Feature List (Based on your Rules)**

#### **A. User Profiles & Onboarding (The "Card")**
* **Mandatory Info Card:**
    * **Gender:** Male / Female / Non-Binary.
    * **Looking For:** Men / Women / Couples (Key for hookup flexibility).
    * **Status:** "Online" (Green dot) or "Last Seen" (Timestamp).
    * **Distance:** GPS-based (Precise to 500m).
* **Media:** Max 3 Photos (Encourages quick decisions, less "window shopping").
* **Description:** Max 200 Characters (Micro-blogging style, keeps it punchy).
* **The "Kink" Tag System:** Pre-defined tags (e.g., *Dom/Sub, Roleplay, NSA, ONS, FWB*). This filters intent immediately.

#### **B. The "Modes"**
* **Hook Up:** (Default & Only Mode). High-intent, fast-moving, geo-location based.
* *Note: "Look Up" mode has been deprecated for the MVP to focus on core hookup functionality.*

#### **C. The "Economy" (Credit System)**
* **Currency:** "Sparks" or "Credits".
* **Exchange Rate (Suggestion):** 1 Credit = ₹10 (Adjustable).
* **Mock Payment System:** For MVP, payments will be simulated (Click "Buy" -> Instant Success).
* **Pricing Table:**

| Action | Cost (Male / Non-Binary) | Cost (Female) | Notes |
| :--- | :--- | :--- | :--- |
| **Pass (X)** | Free | Free | Unlimited. |
| **Like (Heart)** | Free | Free | Unlimited. |
| **Mutual Match Chat** | **10 Credits** (To Unlock) | **Free** (First Text) | High friction for men ensures high intent. |
| **Direct Message (DM)** | **60 Credits** | **60 Credits** | Bypasses matching. "Super DM". |
| **Roll the Dice** | **30 Credits** | **Free** | Random match + Instant DM privilege. |
| **Boost (12 Hrs)** | 30 Credits | 30 Credits | |
| **Boost (24 Hrs)** | 50 Credits | 50 Credits | Scaled pricing. |
| **Boost (1 Week)** | 200 Credits | 200 Credits | High visibility. |
| **Unlimited Pass** | 250 Credits | 250 Credits | "Vip Access" for set duration (e.g., 1 month). |

#### **D. Matching & Communication Mechanics**
1.  **The "Female First" Logic:**
    * On a mutual match, the female is prompted to text first (Free).
    * If the male wants to reply or unlock the chat *before* she texts (or after she texts, depending on strictness), he pays **10 Credits**.
2.  **Vanishing Chats (The "Pure" influence):**
    * **Timer:** Users select vanishing time (Immediate, 12h, 24h).
    * **Logic:** Timer starts *after* the other user views the message.
    * **No Reply Expiry:** If User A sends a message and User B sees it but doesn't reply in 24h -> Chat Vanishes.
    * **Clean Up:** Server hard-deletes expired chats after 48h (Privacy compliance).
3.  **Notification Panel Logic:**
    * Incoming "Direct Messages" or "Dice Rolls" appear here.
    * If opened and not replied to -> Vanishes instantly or per timer.

#### **E. Trust & Safety (The "Iron Fist" Policy)**
* **Identity Mapping:** One Account = One Mobile Number/Email (Encrypted Hash).
* **The "Three Strike" Reporting System:**
    * **< 5 Reports:** Warning.
    * **5 Reports:** **Temporary Suspension**.
        * **Unlock:** Admin Review OR Pay **₹5,000 Penalty** (Revenue stream + Deterrent).
    * **Reported Again (After Unlock):** **Permanent Ban**.        *   **Compliance Warning:** The monetary penalty must be framed carefully (e.g., "Verification Fee") to avoid App Store rejection.        * **Device Ban:** Hash the Device ID / IMEI to prevent creating new accounts on the same phone.
        * **Credential Ban:** Mobile/Email permanently blacklisted.

---

### **2. Detailed Product Roadmap**

#### **Phase 1: The Foundation**
* **Goal:** MVP Launch in Bangalore (Indiranagar, Koramangala, HSR Layout).
* **Co**Mock Auth:** Simple Phone/Email entry -> Create DB Record -> Login. (No real OTP yet).
    * **Trust:** Selfie Verification (Blue Tick) - Crucial for trust.
    * Profile Creation (Gender, Kinks, Photos, Location).
    * Discovery Engine (The "Stack" - *Use vertical scroll*).
    * Basic Matching (Like/Pass).
    * Chat 1.0 (Text only, no media sharing yet for safety).
* **Bangalore Launch Strategy:** Invite-only beta in college zones and tech parks.

#### **Phase 2: The Economy & Gamification**
* **Goal:** Monetization.
* **Features:**
    * **Mock Payment Integration:** Simulate credit purchases (Click -> Success)
    * **Credit Wallet Integration:** Razorpay/Stripe integration for buying credits via UPI.
    * **Gating Logic:** Implement the "10 Credit" lock on chats for men.
    * **Roll The Dice:** Implement the randomization algorithm.
        * *Visuals:* A 3D dice roll animation.
    * **Direct Message:** "Slide into DMs" button (Charge 60 credits).

#### **Phase 3: The "Vanishing" & Retention **
* **Goal:** Engagement and Privacy.
* **Features:**
    * **Self-Destruct Timer:** Implement the "Viewed -> Timer Start -> Delete" logic.
    * **Notification Center:** A dedicated "Requests" tab where DMs sit until viewed.
    * **Boost Logic:** Algorithm tweak to prioritize boosted profiles in the queue.

#### **Phase 4: Safety & Compliance**
* **Goal:** Hardening the platform.
* **Features:**
    * **Report & Block Automation:**
        * Counter for reports.
        * Auto-trigger suspension at 5 reports.
        * Payment gateway for the "₹5,000 Penalty" (Label this as "Account Restoration Fee").
    * **Encryption:** End-to-end encryption on chats.
    * **Screen Shot Prevention:** Block screenshots in chat (Android `FLAG_SECURE`, iOS equivalent).

---

### **3. Technical Architecture (Simplified)**

* **Frontend:** Flutter (Cost-effective, works on iOS and Android).
* **Backend:** Node.js or Go (High concurrency).
    * **Real-time:** WebSockets (Socket.io or Gorilla WebSocket) for instant messaging.
* **Database:**
    * **PostgreSQL:** User data, Credits, Transactions.
    * **Redis:** "Last Seen", Geolocation caching (Fast), and *Vanishing Chat* temporary storage (Auto-expire keys).
* **Payment Gateway:** Razorpay (Best for India/Bangalore UPI support).

### **4. "User Experience" Note on the Penalty**
* **The ₹5,000 Penalty:** This is a very high friction feature.
    * *Risk:* Users might claim they were "mass reported" by bots.
    * *Mitigation:* The "First Unblock" should perhaps be appealable to a human moderator *before* asking for money, or the money is framed as a "Security Deposit" that is returned if they behave for 6 months. (Strictly asking for 5000 to unban might get the app flagged on Play Store/App Store as "Scammy"). **Proceed with caution here.**


Would you like me to detail the **Algorithm for "Roll the Dice"** (how it matches people) or draft the **Terms of Service** regarding the penalty clause?

---

## **Getting Started (Development)**

### **Prerequisites**
- Node.js (v18 or later)
- Flutter SDK (3.0 or later)
- Docker & Docker Compose (for database services)

### **Backend Setup**

```bash
# Navigate to backend folder
cd backend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Run in development mode
npm run dev

# Build for production
npm run build

# Run production build
npm start
```

The backend API will be available at `http://localhost:3000`.

**Health Check Endpoint:**
```
GET /api/health
```

### **Frontend Setup**

```bash
# Navigate to frontend folder
cd frontend

# Install Flutter dependencies
flutter pub get

# Run the app
flutter run
```

**API Configuration:**
- Android Emulator: Uses `http://10.0.2.2:3000`
- iOS Simulator: Uses `http://localhost:3000`

### **Project Structure**

```
├── backend/
│   ├── src/
│   │   └── server.ts       # Main Express server
│   ├── package.json
│   └── tsconfig.json
├── frontend/
│   ├── lib/
│   │   ├── main.dart       # App entry point
│   │   ├── config.dart     # API configuration
│   │   ├── screens/        # UI screens
│   │   ├── widgets/        # Reusable widgets
│   │   ├── services/       # API services
│   │   └── models/         # Data models
│   └── pubspec.yaml
├── IMPLEMENTATION_PLAN.md  # 30-PR implementation roadmap
└── README.md
```