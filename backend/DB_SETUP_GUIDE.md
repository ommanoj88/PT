# Database Setup Guide

## Python Database Setup Script

This guide explains how to use the Python database setup script for the VibeCheck application.

## Prerequisites

- Python 3.8 or higher
- PostgreSQL 12 or higher (running via Docker or locally)
- pip (Python package manager)

## Installation

1. **Install Python dependencies:**

```bash
cd backend
pip install -r requirements.txt
```

Or using a virtual environment (recommended):

```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

## Configuration

The script reads database configuration from environment variables. You can set them in two ways:

### Option 1: Using .env file (Recommended)

Create or update the `.env` file in the `backend` directory:

```bash
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=vibecheck
POSTGRES_PASSWORD=Shobharain11@
POSTGRES_DB=vibecheck
```

### Option 2: Export environment variables

```bash
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_USER=vibecheck
export POSTGRES_PASSWORD=Shobharain11@
export POSTGRES_DB=vibecheck
```

## Usage

### Running the Database Setup Script

The script performs the following operations:
1. Creates the database if it doesn't exist
2. Creates all required tables (users, interactions, matches, messages, notifications, reports)
3. Creates database indexes for performance
4. Seeds 20 initial users if not already present

```bash
cd backend
python3 db_setup.py
```

Or if using virtual environment:

```bash
cd backend
source venv/bin/activate
python3 db_setup.py
```

### Expected Output

```
============================================================
VibeCheck Database Setup Script
============================================================

✓ Database already exists: vibecheck
✓ Connected to PostgreSQL database: vibecheck

Creating database tables...
✓ Enabled uuid-ossp extension
✓ Created/verified users table
✓ Created/verified interactions table
✓ Created/verified matches table
✓ Created/verified messages table
✓ Created/verified notifications table
✓ Created/verified reports table
✓ All tables created successfully

Creating database indexes...
✓ Created database indexes

Seeding initial users...
✓ Current user count: 0. Seeding 20 initial users...
✓ Seeded users successfully. Total users: 20

✓ Sample of seeded users:
  - Aditya Chopra (9876543219) - male - 250 credits
  - Amit Saxena (9876543227) - male - 145 credits
  - Ananya Singh (9876543212) - female - 80 credits
  - Arjun Patel (9876543213) - male - 200 credits
  - Dev Sharma (9876543223) - male - 130 credits

============================================================
✓ Database setup completed successfully!
============================================================

Default password for all seeded users: password123
You can update passwords using the application.

✓ Database connection closed
```

## Seeded Users

The script seeds 20 initial users with the following details:

- **Phone numbers:** 9876543210 to 9876543229
- **Email format:** firstname.lastname@email.com
- **Default password:** `password123` (hashed using bcrypt)
- **Credits:** Varies from 80 to 250 credits per user
- **Verified status:** All users are pre-verified
- **Profiles:** Complete with name, gender, bio, photos, and tags

### Sample Users:

1. Priya Sharma (Female) - Coffee addict, travel enthusiast
2. Rahul Verma (Male) - Fitness freak, tech geek
3. Ananya Singh (Female) - Artist, dog lover
4. Arjun Patel (Male) - Entrepreneur, music lover
5. Sneha Reddy (Female) - Yoga instructor
... and 15 more diverse profiles

## Password Management

### Default Password
All seeded users have the default password: `password123`

### Updating Passwords

You can update user passwords in two ways:

1. **Using the application's API:**
   Use the profile update endpoint to change passwords

2. **Directly in the database (for testing):**
```python
import bcrypt

# Generate a new password hash
new_password = "mynewpassword"
salt = bcrypt.gensalt()
hashed = bcrypt.hashpw(new_password.encode('utf-8'), salt)

# Update in database (using psql or any PostgreSQL client)
# UPDATE users SET password_hash = 'hashed_value' WHERE email = 'user@email.com';
```

## Features

### Idempotent Operations
- The script is safe to run multiple times
- Tables are created only if they don't exist
- Users are seeded only if the database has fewer than 20 users
- Existing users are not overwritten (uses `ON CONFLICT DO NOTHING`)

### Password Security
- Passwords are hashed using bcrypt with salt
- Password hashes are stored securely in the `password_hash` column
- Never stores plain text passwords

## Integration with Existing Setup

This Python script complements the existing TypeScript/Node.js backend:

1. **Use Python script for initial setup:**
   ```bash
   python3 db_setup.py
   ```

2. **Then run the Node.js application:**
   ```bash
   npm run dev
   ```

Both scripts can coexist and work with the same PostgreSQL database.

## Troubleshooting

### Database Connection Issues

**Error:** `Error connecting to database: connection refused`

**Solution:**
1. Ensure PostgreSQL is running:
   ```bash
   docker-compose ps
   ```
2. Start PostgreSQL if needed:
   ```bash
   docker-compose up -d
   ```

### Permission Issues

**Error:** `permission denied for schema public`

**Solution:**
Ensure your database user has proper permissions:
```sql
GRANT ALL PRIVILEGES ON DATABASE vibecheck TO vibecheck;
GRANT ALL PRIVILEGES ON SCHEMA public TO vibecheck;
```

### Module Not Found

**Error:** `ModuleNotFoundError: No module named 'psycopg2'`

**Solution:**
Install the required dependencies:
```bash
pip install -r requirements.txt
```

## Database Schema

The script creates the following tables:

1. **users** - User profiles and authentication
2. **interactions** - Like/pass actions between users
3. **matches** - Mutual matches
4. **messages** - Chat messages
5. **notifications** - User notifications
6. **reports** - User reports for moderation

For detailed schema information, refer to `init-db.sql` or check the script's table creation queries.

## Running Both Scripts

You now have two options for database setup:

### Option 1: Python Script (New)
```bash
python3 db_setup.py
```
- **Pros:** Includes password hashing, better for production
- **Features:** User seeding with secure passwords

### Option 2: Node.js/TypeScript (Existing)
```bash
npm run dev
```
- **Pros:** Integrated with the application startup
- **Features:** Automatic table creation on server start

Choose based on your workflow preference. Both work with the same database schema.
