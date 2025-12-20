#!/usr/bin/env python3
"""
VibeCheck - Database Setup & Seeding Script
Creates tables and seeds 20 users if not already seeded
"""

import psycopg2
from psycopg2 import sql
import sys

# ============================================
# DATABASE CONFIGURATION - UPDATE PASSWORD HERE
# ============================================
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'vibecheck',
    'user': 'vibecheck',
    'password': 'password123'  # <-- UPDATE YOUR PASSWORD HERE
}

# ANSI color codes
class Colors:
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    RESET = '\033[0m'

def print_success(msg):
    print(f"{Colors.GREEN}✓ {msg}{Colors.RESET}")

def print_error(msg):
    print(f"{Colors.RED}✗ {msg}{Colors.RESET}")

def print_info(msg):
    print(f"{Colors.CYAN}→ {msg}{Colors.RESET}")

def print_warning(msg):
    print(f"{Colors.YELLOW}⚠ {msg}{Colors.RESET}")

def get_connection():
    """Establish database connection"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except psycopg2.Error as e:
        print_error(f"Failed to connect to database: {e}")
        sys.exit(1)

def create_tables(conn):
    """Create all database tables"""
    print_info("Creating database tables...")
    
    create_tables_sql = """
    -- Enable UUID extension
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

    -- Users table
    CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );

    -- Interactions table
    CREATE TABLE IF NOT EXISTS interactions (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        from_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        to_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        action VARCHAR(10) CHECK (action IN ('like', 'pass')),
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(from_user_id, to_user_id)
    );

    -- Matches table
    CREATE TABLE IF NOT EXISTS matches (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        user1_id UUID REFERENCES users(id) ON DELETE CASCADE,
        user2_id UUID REFERENCES users(id) ON DELETE CASCADE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user1_id, user2_id)
    );

    -- Messages table
    CREATE TABLE IF NOT EXISTS messages (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
        sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
        content TEXT NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        viewed_at TIMESTAMP WITH TIME ZONE,
        expires_at TIMESTAMP WITH TIME ZONE
    );

    -- Notifications table
    CREATE TABLE IF NOT EXISTS notifications (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        type VARCHAR(50) NOT NULL,
        title VARCHAR(200) NOT NULL,
        body TEXT,
        data JSONB,
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );

    -- Reports table
    CREATE TABLE IF NOT EXISTS reports (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        reporter_id UUID REFERENCES users(id) ON DELETE CASCADE,
        reported_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        reason TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );

    -- Indexes for performance
    CREATE INDEX IF NOT EXISTS idx_interactions_from_user ON interactions(from_user_id);
    CREATE INDEX IF NOT EXISTS idx_interactions_to_user ON interactions(to_user_id);
    CREATE INDEX IF NOT EXISTS idx_matches_user1 ON matches(user1_id);
    CREATE INDEX IF NOT EXISTS idx_matches_user2 ON matches(user2_id);
    CREATE INDEX IF NOT EXISTS idx_messages_match ON messages(match_id);
    CREATE INDEX IF NOT EXISTS idx_messages_created ON messages(created_at);
    CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
    CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(created_at);
    CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
    CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
    """
    
    try:
        cursor = conn.cursor()
        cursor.execute(create_tables_sql)
        conn.commit()
        print_success("All tables created successfully!")
    except psycopg2.Error as e:
        conn.rollback()
        print_error(f"Failed to create tables: {e}")
        sys.exit(1)

def check_if_seeded(conn):
    """Check if users are already seeded"""
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM users")
        count = cursor.fetchone()[0]
        return count > 0
    except psycopg2.Error:
        return False

def seed_users(conn):
    """Seed 20 test users"""
    print_info("Seeding 20 users...")
    
    # Placeholder image (1x1 pixel base64)
    placeholder_photo = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='
    
    users = [
        # Original 10 users
        ('9876543210', 'priya.sharma@email.com', 'Priya Sharma', 'female', 'male', 
         'Coffee addict ☕ | Travel enthusiast 🌍 | Bookworm 📚', '1995-03-15',
         ['coffee', 'travel', 'books', 'foodie'], 100),
        
        ('9876543211', 'rahul.verma@email.com', 'Rahul Verma', 'male', 'female',
         'Fitness freak 💪 | Tech geek 💻 | Foodie 🍕', '1993-07-20',
         ['fitness', 'tech', 'food', 'gaming'], 150),
        
        ('9876543212', 'ananya.singh@email.com', 'Ananya Singh', 'female', 'male',
         'Artist 🎨 | Dog lover 🐕 | Adventure seeker 🏔️', '1996-11-08',
         ['art', 'dogs', 'adventure', 'hiking'], 80),
        
        ('9876543213', 'arjun.patel@email.com', 'Arjun Patel', 'male', 'female',
         'Entrepreneur | Music lover 🎵 | Motorcycle enthusiast 🏍️', '1992-05-12',
         ['music', 'bikes', 'business', 'travel'], 200),
        
        ('9876543214', 'sneha.reddy@email.com', 'Sneha Reddy', 'female', 'male',
         'Yoga instructor 🧘 | Nature lover 🌿 | Minimalist', '1997-09-25',
         ['yoga', 'nature', 'wellness', 'meditation'], 120),
        
        ('9876543215', 'vikram.kumar@email.com', 'Vikram Kumar', 'male', 'female',
         'Software engineer 👨‍💻 | Gamer 🎮 | Anime fan', '1994-01-30',
         ['coding', 'gaming', 'anime', 'tech'], 90),
        
        ('9876543216', 'ishita.joshi@email.com', 'Ishita Joshi', 'female', 'male',
         'Fashion blogger 👗 | Wine enthusiast 🍷 | Beach bum 🏖️', '1995-06-18',
         ['fashion', 'wine', 'beach', 'shopping'], 110),
        
        ('9876543217', 'rohan.mehta@email.com', 'Rohan Mehta', 'male', 'female',
         'Photographer 📸 | Traveler ✈️ | Craft beer lover 🍺', '1991-12-05',
         ['photography', 'travel', 'beer', 'adventure'], 180),
        
        ('9876543218', 'kavya.nair@email.com', 'Kavya Nair', 'female', 'male',
         'Dentist 🦷 | Dancer 💃 | Foodie with a sweet tooth 🍰', '1996-04-22',
         ['dance', 'food', 'desserts', 'music'], 95),
        
        ('9876543219', 'aditya.chopra@email.com', 'Aditya Chopra', 'male', 'female',
         'Investment banker 💼 | Runner 🏃 | Whiskey connoisseur 🥃', '1990-08-14',
         ['finance', 'running', 'whiskey', 'fitness'], 250),
        
        # 10 Additional users
        ('9876543220', 'meera.iyer@email.com', 'Meera Iyer', 'female', 'male',
         'Classical dancer 💃 | Chef 👩‍🍳 | Book club member 📖', '1994-02-28',
         ['dance', 'cooking', 'reading', 'culture'], 130),
        
        ('9876543221', 'karan.malhotra@email.com', 'Karan Malhotra', 'male', 'female',
         'Startup founder 🚀 | Cricket lover 🏏 | Coffee snob ☕', '1991-09-10',
         ['startups', 'cricket', 'coffee', 'networking'], 175),
        
        ('9876543222', 'divya.gupta@email.com', 'Divya Gupta', 'female', 'male',
         'Architect 🏛️ | Interior design enthusiast 🎨 | Plant mom 🌱', '1995-07-03',
         ['architecture', 'design', 'plants', 'art'], 105),
        
        ('9876543223', 'siddharth.rao@email.com', 'Siddharth Rao', 'male', 'female',
         'Doctor 🩺 | Marathon runner 🏃 | Podcast addict 🎧', '1989-11-15',
         ['medicine', 'running', 'podcasts', 'health'], 220),
        
        ('9876543224', 'nisha.krishnan@email.com', 'Nisha Krishnan', 'female', 'male',
         'Data scientist 📊 | Cat mom 🐱 | Netflix binger 📺', '1996-05-20',
         ['data', 'cats', 'movies', 'tech'], 85),
        
        ('9876543225', 'amit.sharma@email.com', 'Amit Sharma', 'male', 'female',
         'Chef 👨‍🍳 | Food blogger 🍜 | Travel foodie 🌏', '1993-03-08',
         ['cooking', 'food', 'travel', 'blogging'], 160),
        
        ('9876543226', 'pooja.desai@email.com', 'Pooja Desai', 'female', 'male',
         'Lawyer ⚖️ | Debater 🎤 | Wine connoisseur 🍷', '1992-08-25',
         ['law', 'debate', 'wine', 'reading'], 145),
        
        ('9876543227', 'rajesh.menon@email.com', 'Rajesh Menon', 'male', 'female',
         'Film director 🎬 | Storyteller 📝 | Music producer 🎶', '1988-12-01',
         ['films', 'stories', 'music', 'art'], 190),
        
        ('9876543228', 'shreya.banerjee@email.com', 'Shreya Banerjee', 'female', 'male',
         'Teacher 👩‍🏫 | Singer 🎤 | Nature photographer 📷', '1997-01-14',
         ['teaching', 'singing', 'photography', 'nature'], 75),
        
        ('9876543229', 'varun.kapoor@email.com', 'Varun Kapoor', 'male', 'female',
         'Pilot ✈️ | Adventure junkie 🪂 | Guitar player 🎸', '1990-06-30',
         ['flying', 'adventure', 'music', 'travel'], 280),
    ]
    
    insert_sql = """
    INSERT INTO users (phone, email, name, gender, looking_for, bio, birthdate, photos, tags, credits, is_verified)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, true)
    ON CONFLICT (phone) DO NOTHING
    """
    
    try:
        cursor = conn.cursor()
        inserted_count = 0
        
        for user in users:
            phone, email, name, gender, looking_for, bio, birthdate, tags, credits = user
            cursor.execute(insert_sql, (
                phone, email, name, gender, looking_for, bio, birthdate,
                [placeholder_photo], tags, credits
            ))
            if cursor.rowcount > 0:
                inserted_count += 1
        
        conn.commit()
        print_success(f"Seeded {inserted_count} new users (skipped {len(users) - inserted_count} existing)")
        
    except psycopg2.Error as e:
        conn.rollback()
        print_error(f"Failed to seed users: {e}")
        sys.exit(1)

def display_users(conn):
    """Display all seeded users"""
    print_info("\nSeeded Users:")
    print("-" * 70)
    
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT phone, name, gender, credits 
            FROM users 
            ORDER BY name
        """)
        
        users = cursor.fetchall()
        for phone, name, gender, credits in users:
            print(f"  {phone} - {name} ({gender}, {credits} credits)")
        
        print("-" * 70)
        print_success(f"Total users in database: {len(users)}")
        
    except psycopg2.Error as e:
        print_error(f"Failed to fetch users: {e}")

def main():
    print(f"\n{Colors.CYAN}{'='*50}")
    print("  VibeCheck Database Setup & Seeding")
    print(f"{'='*50}{Colors.RESET}\n")
    
    # Connect to database
    print_info(f"Connecting to PostgreSQL at {DB_CONFIG['host']}:{DB_CONFIG['port']}...")
    conn = get_connection()
    print_success("Connected to database!")
    
    # Create tables
    create_tables(conn)
    
    # Check if already seeded
    if check_if_seeded(conn):
        print_warning("Database already has users. Checking for new users to add...")
    
    # Seed users (will skip existing ones)
    seed_users(conn)
    
    # Display all users
    display_users(conn)
    
    # Close connection
    conn.close()
    print_success("\nDatabase setup complete!")

if __name__ == "__main__":
    main()
