# VibeCheck API Documentation

This document provides comprehensive documentation for the VibeCheck API.

## Base URL

- **Development:** `http://localhost:3000`
- **Android Emulator:** `http://10.0.2.2:3000`
- **iOS Simulator:** `http://localhost:3000`

## Authentication

All protected endpoints require a JWT token in the Authorization header:

```
Authorization: Bearer <jwt_token>
```

The token is obtained from the `/api/auth/login` endpoint and expires in 7 days.

---

## Endpoints

### Health Check

#### GET `/api/health`

Check if the API is running.

**Response:**
```json
{
  "status": "ok",
  "message": "VibeCheck API is running",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

---

### Authentication

#### POST `/api/auth/login`

Mock authentication - creates user if not exists, returns JWT token.

**Rate Limit:** 10 requests per 15 minutes

**Request Body:**
```json
{
  "phone": "+1234567890",
  "email": "user@example.com"
}
```

*Note: At least one of `phone` or `email` is required.*

**Response (200 OK):**
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

**Error Response (400 Bad Request):**
```json
{
  "success": false,
  "error": "Phone number or email is required"
}
```

---

### Profile Management

#### GET `/api/profile`

Get the current user's profile.

**Authentication:** Required

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "phone": "+1234567890",
    "email": "user@example.com",
    "name": "John Doe",
    "gender": "male",
    "looking_for": "women",
    "bio": "Adventure seeker",
    "birthdate": "1990-01-01",
    "photos": ["base64-encoded-photo"],
    "tags": ["adventurous", "foodie"],
    "credits": 100,
    "is_verified": false,
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

#### PUT `/api/profile`

Update the current user's profile.

**Authentication:** Required

**Request Body:**
```json
{
  "name": "John Doe",
  "gender": "male",
  "looking_for": "women",
  "bio": "Adventure seeker",
  "birthdate": "1990-01-01",
  "photos": ["base64-encoded-photo"],
  "tags": ["adventurous", "foodie"]
}
```

**Field Validations:**
- `gender`: Must be one of: `male`, `female`, `non-binary`
- `looking_for`: Must be one of: `men`, `women`, `couples`
- `bio`: Maximum 200 characters
- `photos`: Maximum 3 photos

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "id": "uuid",
    "name": "John Doe",
    "gender": "male",
    "looking_for": "women",
    "bio": "Adventure seeker",
    "birthdate": "1990-01-01",
    "photos": ["base64-encoded-photo"],
    "tags": ["adventurous", "foodie"],
    "credits": 100,
    "is_verified": false
  }
}
```

---

### Discovery Feed

#### GET `/api/feed`

Get potential matches based on user preferences.

**Authentication:** Required

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "uuid",
        "name": "Jane Doe",
        "gender": "female",
        "bio": "Coffee lover",
        "age": 25,
        "photos": ["base64-encoded-photo"],
        "tags": ["coffee", "books"],
        "is_verified": true
      }
    ]
  }
}
```

**Filtering Logic:**
- Returns users matching the `looking_for` preference
- Excludes users already liked/passed
- Excludes the current user
- Returns up to 20 users

---

### Interactions

#### POST `/api/interact`

Record a like or pass action on another user.

**Authentication:** Required

**Rate Limit:** 30 requests per minute

**Request Body:**
```json
{
  "to_user_id": "uuid",
  "action": "like"
}
```

*`action` must be either `like` or `pass`*

**Response (200 OK):**
```json
{
  "success": true,
  "message": "It's a match!",
  "data": {
    "is_match": true
  }
}
```

**Match Logic:**
- When user A likes user B, and user B has already liked user A, a match is created
- The response indicates whether a match occurred

#### GET `/api/interact/matches`

Get all matches for the current user.

**Authentication:** Required

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "matches": [
      {
        "match_id": "uuid",
        "matched_at": "2024-01-01T00:00:00.000Z",
        "user": {
          "id": "uuid",
          "name": "Jane Doe",
          "photos": ["base64-encoded-photo"],
          "bio": "Coffee lover"
        }
      }
    ]
  }
}
```

---

### Roll the Dice

#### GET `/api/dice`

Get a random user for the "Roll the Dice" feature.

**Authentication:** Required

**Rate Limit:** 30 requests per minute

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "name": "Random User",
      "gender": "female",
      "bio": "Looking for fun",
      "age": 28,
      "photos": ["base64-encoded-photo"],
      "tags": ["travel", "music"],
      "is_verified": true
    }
  }
}
```

**Response (404 Not Found):**
```json
{
  "success": false,
  "error": "No users found"
}
```

---

### Wallet & Credits

#### GET `/api/wallet`

Get current credit balance.

**Authentication:** Required

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "credits": 100
  }
}
```

#### POST `/api/wallet/add`

Add credits to wallet (mock purchase).

**Authentication:** Required

**Request Body:**
```json
{
  "amount": 100
}
```

**Validations:**
- `amount` must be a positive number
- Maximum 1000 credits per transaction

**Response (200 OK):**
```json
{
  "success": true,
  "message": "100 credits added successfully",
  "data": {
    "credits": 200
  }
}
```

#### POST `/api/wallet/spend`

Spend credits for actions.

**Authentication:** Required

**Request Body:**
```json
{
  "amount": 10
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "10 credits spent",
  "data": {
    "credits": 90
  }
}
```

**Error Response (400 Bad Request):**
```json
{
  "success": false,
  "error": "Insufficient credits"
}
```

---

### Chat

#### GET `/api/chat/:matchId`

Get chat history for a match.

**Authentication:** Required

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "messages": [
      {
        "id": "uuid",
        "sender_id": "uuid",
        "sender_name": "John",
        "content": "Hello!",
        "created_at": "2024-01-01T00:00:00.000Z",
        "viewed_at": "2024-01-01T00:01:00.000Z",
        "is_mine": true
      }
    ]
  }
}
```

*Note: Messages are automatically marked as viewed when retrieved.*

#### POST `/api/chat/:matchId`

Send a message in a chat.

**Authentication:** Required

**Request Body:**
```json
{
  "content": "Hello!"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Message sent",
  "data": {
    "id": "uuid",
    "sender_id": "uuid",
    "content": "Hello!",
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

---

### Notifications

#### GET `/api/notifications`

Get all notifications for the current user.

**Authentication:** Required

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "uuid",
        "type": "match",
        "title": "New Match!",
        "body": "You matched with Jane",
        "data": { "match_id": "uuid" },
        "is_read": false,
        "created_at": "2024-01-01T00:00:00.000Z"
      }
    ]
  }
}
```

*Note: Returns up to 50 most recent notifications.*

#### POST `/api/notifications/:id/read`

Mark a notification as read.

**Authentication:** Required

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Notification marked as read"
}
```

#### POST `/api/notifications/read-all`

Mark all notifications as read.

**Authentication:** Required

**Response (200 OK):**
```json
{
  "success": true,
  "message": "All notifications marked as read"
}
```

---

### Reporting & Trust/Safety

#### POST `/api/report`

Report a user.

**Authentication:** Required

**Request Body:**
```json
{
  "reported_user_id": "uuid",
  "reason": "Inappropriate behavior",
  "description": "Optional detailed description"
}
```

**Validations:**
- Cannot report yourself
- Cannot report the same user twice
- `reason` is required

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Report submitted successfully"
}
```

#### GET `/api/report/blocked`

Get list of users blocked by reporting.

**Authentication:** Required

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "blocked_users": [
      {
        "user_id": "uuid",
        "name": "Blocked User",
        "blocked_at": "2024-01-01T00:00:00.000Z"
      }
    ]
  }
}
```

---

## Error Responses

All endpoints return consistent error responses:

**Authentication Error (401 Unauthorized):**
```json
{
  "success": false,
  "error": "User not authenticated"
}
```

**Validation Error (400 Bad Request):**
```json
{
  "success": false,
  "error": "Specific error message"
}
```

**Not Found (404):**
```json
{
  "success": false,
  "error": "Resource not found"
}
```

**Rate Limit Exceeded (429 Too Many Requests):**
```json
{
  "success": false,
  "error": "Too many requests, please try again later"
}
```

**Server Error (500 Internal Server Error):**
```json
{
  "success": false,
  "error": "Internal server error"
}
```

---

## Rate Limiting

The API implements rate limiting to prevent abuse:

| Endpoint Type | Limit | Window |
|---------------|-------|--------|
| General | 100 requests | 15 minutes |
| Authentication | 10 requests | 15 minutes |
| Interactions (Like/Pass/Dice) | 30 requests | 1 minute |

---

## Database Schema

### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  phone VARCHAR(20) UNIQUE,
  email VARCHAR(255) UNIQUE,
  name VARCHAR(100),
  gender VARCHAR(20),
  looking_for VARCHAR(20),
  bio VARCHAR(200),
  birthdate DATE,
  photos TEXT[],
  tags TEXT[],
  credits INTEGER DEFAULT 0,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
);
```

### Interactions Table
```sql
CREATE TABLE interactions (
  id UUID PRIMARY KEY,
  from_user_id UUID REFERENCES users(id),
  to_user_id UUID REFERENCES users(id),
  action VARCHAR(10) CHECK (action IN ('like', 'pass')),
  created_at TIMESTAMP WITH TIME ZONE,
  UNIQUE(from_user_id, to_user_id)
);
```

### Matches Table
```sql
CREATE TABLE matches (
  id UUID PRIMARY KEY,
  user1_id UUID REFERENCES users(id),
  user2_id UUID REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE,
  UNIQUE(user1_id, user2_id)
);
```

### Messages Table
```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY,
  match_id UUID REFERENCES matches(id),
  sender_id UUID REFERENCES users(id),
  content TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  viewed_at TIMESTAMP WITH TIME ZONE
);
```

### Notifications Table
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  type VARCHAR(50),
  title VARCHAR(200),
  body TEXT,
  data JSONB,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE
);
```

### Reports Table
```sql
CREATE TABLE reports (
  id UUID PRIMARY KEY,
  reporter_id UUID REFERENCES users(id),
  reported_user_id UUID REFERENCES users(id),
  reason VARCHAR(200),
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE
);
```
