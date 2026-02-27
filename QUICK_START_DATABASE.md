# Quick Start Guide - Database and Application Setup

This guide explains how to quickly set up and run the VibeCheck application with the database.

## Two-Script Workflow

The project now has two scripts for database and application management:

### 1. Database Configuration Script (Python)
**File:** `backend/db_setup.py`  
**Purpose:** Initial database setup and user seeding

### 2. Application Runner (Node.js)
**File:** `backend/package.json` (scripts: `dev`, `start`)  
**Purpose:** Run the backend API server

## Quick Setup Steps

### Step 1: Start Database Services

```bash
# Start PostgreSQL and Redis using Docker
docker compose up -d

# Verify services are running
docker compose ps
```

Expected output:
```
NAME                 SERVICE    STATUS
vibecheck-postgres   postgres   Up (healthy)
vibecheck-redis      redis      Up (healthy)
```

### Step 2: Initialize Database (Python Script)

```bash
# Navigate to backend
cd backend

# Install Python dependencies (first time only)
pip install -r requirements.txt

# Run database setup script
python3 db_setup.py
```

This will:
- ✓ Create the `vibecheck` database (if not exists)
- ✓ Create all tables (users, interactions, matches, messages, notifications, reports)
- ✓ Create database indexes
- ✓ Seed 20 initial users with profiles and hashed passwords

**Output:**
```
============================================================
VibeCheck Database Setup Script
============================================================

✓ Database already exists: vibecheck
✓ Connected to PostgreSQL database: vibecheck
...
✓ Seeded users successfully. Total users: 20
============================================================
✓ Database setup completed successfully!
============================================================

Default password for all seeded users: DevTestPass2024!SecureDefault
```

### Step 3: Run the Application (Node.js)

```bash
# Still in backend directory
# Install Node.js dependencies (first time only)
npm install

# Copy environment configuration (first time only)
cp .env.example .env

# Start the backend server
npm run dev
```

**Output:**
```
PostgreSQL connected successfully
Redis connected successfully
Database tables initialized successfully
Server is running on port 3000
```

The backend API is now running at `http://localhost:3000`

## Test the Setup

### Test 1: Health Check
```bash
curl http://localhost:3000/api/health
```

Expected response:
```json
{
  "status": "ok",
  "message": "VibeCheck API is running",
  "timestamp": "2025-12-19T09:48:31.468Z"
}
```

### Test 2: Login with Seeded User
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"9876543210","email":"priya.sharma@email.com"}'
```

Expected response:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "...",
      "phone": "9876543210",
      "email": "priya.sharma@email.com",
      "is_verified": true
    }
  }
}
```

## Seeded Users Reference

The `db_setup.py` script seeds 20 users with the following credentials:

| Name | Phone | Email | Password | Credits |
|------|-------|-------|----------|---------|
| Priya Sharma | 9876543210 | priya.sharma@email.com | DevTestPass2024!SecureDefault | 100 |
| Rahul Verma | 9876543211 | rahul.verma@email.com | DevTestPass2024!SecureDefault | 150 |
| Ananya Singh | 9876543212 | ananya.singh@email.com | DevTestPass2024!SecureDefault | 80 |
| ... | ... | ... | DevTestPass2024!SecureDefault | ... |

**Full list:** See [DB_SETUP_GUIDE.md](backend/DB_SETUP_GUIDE.md) for all 20 users.

## Common Workflows

### First Time Setup
```bash
# 1. Start databases
docker compose up -d

# 2. Setup database and seed users (Python)
cd backend
pip install -r requirements.txt
python3 db_setup.py

# 3. Run application (Node.js)
npm install
cp .env.example .env
npm run dev
```

### Daily Development
```bash
# Start databases (if not running)
docker compose up -d

# Run application
cd backend
npm run dev
```

### Reset Database
```bash
# Stop application (Ctrl+C)

# Drop and recreate database
docker compose down -v  # Removes volumes
docker compose up -d

# Re-run setup script
cd backend
python3 db_setup.py

# Restart application
npm run dev
```

## Troubleshooting

### Problem: "Connection refused" when running db_setup.py
**Solution:** Ensure PostgreSQL is running
```bash
docker compose ps
docker compose up -d
```

### Problem: "Password authentication failed"
**Solution:** Ensure .env file has correct password
```bash
# Check .env file
cat backend/.env

# Should have:
POSTGRES_PASSWORD=Shobharain11@
```

### Problem: Backend can't connect to database
**Solution:** Restart the backend server
```bash
# Stop: Ctrl+C
# Start: npm run dev
```

### Problem: Port 3000 already in use
**Solution:** Kill existing process or change port
```bash
# Find process
lsof -i :3000

# Kill process
kill -9 <PID>

# Or change port in .env
PORT=3001
```

## Environment Configuration

Both scripts read from the same environment variables:

```bash
# Database
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=vibecheck
POSTGRES_PASSWORD=Shobharain11@
POSTGRES_DB=vibecheck

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# Application
PORT=3000
JWT_SECRET=your-super-secret-jwt-key-change-in-production
```

## Production Deployment

For production:

1. **Update passwords** in docker-compose.yml and .env
2. **Change JWT_SECRET** to a secure random string
3. **Use environment variables** instead of .env file
4. **Build production bundle:**
   ```bash
   cd backend
   npm run build
   npm start
   ```

## Additional Resources

- [Database Setup Guide](backend/DB_SETUP_GUIDE.md) - Detailed Python script documentation
- [API Documentation](docs/API.md) - Complete API reference
- [README](README.md) - Full project documentation
- [Implementation Plan](IMPLEMENTATION_PLAN.md) - Development roadmap

## Summary

✅ **Two scripts, one workflow:**
1. `python3 db_setup.py` - Configure database and seed users
2. `npm run dev` - Run the application

✅ **20 pre-configured users** ready for testing with password: `DevTestPass2024!SecureDefault`

✅ **Full API backend** running on port 3000

You're ready to develop! 🚀
