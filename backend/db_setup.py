#!/usr/bin/env python3
"""
Database Setup Script for VibeCheck Dating App
This script initializes the PostgreSQL database, creates tables, and seeds initial users.
"""

import os
import sys
import psycopg2
from psycopg2 import sql
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import bcrypt
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Database configuration from environment variables
DB_CONFIG = {
    'host': os.getenv('POSTGRES_HOST', 'localhost'),
    'port': int(os.getenv('POSTGRES_PORT', '5432')),
    'user': os.getenv('POSTGRES_USER', 'vibecheck'),
    'password': os.getenv('POSTGRES_PASSWORD'),  # Required, no fallback
    'database': os.getenv('POSTGRES_DB', 'vibecheck')
}


def get_db_connection():
    """Establish connection to PostgreSQL database"""
    if not DB_CONFIG['password']:
        print("✗ Error: POSTGRES_PASSWORD environment variable is required")
        print("  Please set it in your .env file or environment")
        sys.exit(1)
    
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print(f"✓ Connected to PostgreSQL database: {DB_CONFIG['database']}")
        return conn
    except psycopg2.Error as e:
        print(f"✗ Error connecting to database: {e}")
        sys.exit(1)


def create_database_if_not_exists():
    """Create the database if it doesn't exist"""
    try:
        # Connect to default 'postgres' database to create our database
        conn = psycopg2.connect(
            host=DB_CONFIG['host'],
            port=DB_CONFIG['port'],
            user=DB_CONFIG['user'],
            password=DB_CONFIG['password'],
            database='postgres'
        )
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cursor = conn.cursor()
        
        # Check if database exists
        cursor.execute(
            "SELECT 1 FROM pg_database WHERE datname = %s",
            (DB_CONFIG['database'],)
        )
        exists = cursor.fetchone()
        
        if not exists:
            cursor.execute(
                sql.SQL("CREATE DATABASE {}").format(
                    sql.Identifier(DB_CONFIG['database'])
                )
            )
            print(f"✓ Created database: {DB_CONFIG['database']}")
        else:
            print(f"✓ Database already exists: {DB_CONFIG['database']}")
        
        cursor.close()
        conn.close()
    except psycopg2.Error as e:
        print(f"✗ Error creating database: {e}")
        sys.exit(1)


def create_tables(conn):
    """Create all required database tables"""
    cursor = conn.cursor()
    
    try:
        # Enable UUID extension
        cursor.execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";")
        print("✓ Enabled uuid-ossp extension")
        
        # Users table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS users (
                id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                phone VARCHAR(20) UNIQUE,
                email VARCHAR(255) UNIQUE,
                password_hash VARCHAR(255),
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
        """)
        print("✓ Created/verified users table")
        
        # Interactions table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS interactions (
                id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                from_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
                to_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
                action VARCHAR(10) CHECK (action IN ('like', 'pass')),
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(from_user_id, to_user_id)
            );
        """)
        print("✓ Created/verified interactions table")
        
        # Matches table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS matches (
                id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                user1_id UUID REFERENCES users(id) ON DELETE CASCADE,
                user2_id UUID REFERENCES users(id) ON DELETE CASCADE,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(user1_id, user2_id)
            );
        """)
        print("✓ Created/verified matches table")
        
        # Messages table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS messages (
                id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
                sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
                content TEXT NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                viewed_at TIMESTAMP WITH TIME ZONE,
                expires_at TIMESTAMP WITH TIME ZONE
            );
        """)
        print("✓ Created/verified messages table")
        
        # Notifications table
        cursor.execute("""
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
        """)
        print("✓ Created/verified notifications table")
        
        # Reports table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS reports (
                id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                reporter_id UUID REFERENCES users(id) ON DELETE CASCADE,
                reported_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
                reason TEXT,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            );
        """)
        print("✓ Created/verified reports table")
        
        conn.commit()
        print("✓ All tables created successfully")
        
    except psycopg2.Error as e:
        conn.rollback()
        print(f"✗ Error creating tables: {e}")
        sys.exit(1)
    finally:
        cursor.close()


def create_indexes(conn):
    """Create indexes for performance optimization"""
    cursor = conn.cursor()
    
    try:
        indexes = [
            "CREATE INDEX IF NOT EXISTS idx_interactions_from_user ON interactions(from_user_id);",
            "CREATE INDEX IF NOT EXISTS idx_interactions_to_user ON interactions(to_user_id);",
            "CREATE INDEX IF NOT EXISTS idx_matches_user1 ON matches(user1_id);",
            "CREATE INDEX IF NOT EXISTS idx_matches_user2 ON matches(user2_id);",
            "CREATE INDEX IF NOT EXISTS idx_messages_match ON messages(match_id);",
            "CREATE INDEX IF NOT EXISTS idx_messages_created ON messages(created_at);",
            "CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);",
            "CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(created_at);",
            "CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);",
            "CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);"
        ]
        
        for index_query in indexes:
            cursor.execute(index_query)
        
        conn.commit()
        print("✓ Created database indexes")
        
    except psycopg2.Error as e:
        conn.rollback()
        print(f"✗ Error creating indexes: {e}")
        sys.exit(1)
    finally:
        cursor.close()


def hash_password(password):
    """Hash a password using bcrypt"""
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')


def seed_initial_users(conn):
    """Seed initial 20 users if not already seeded"""
    cursor = conn.cursor()
    
    try:
        # Check if users already exist
        cursor.execute("SELECT COUNT(*) FROM users;")
        user_count = cursor.fetchone()[0]
        
        if user_count >= 20:
            print(f"✓ Database already has {user_count} users. Skipping seeding.")
            return
        
        print(f"✓ Current user count: {user_count}. Seeding 20 initial users...")
        
        # Default password for all seed users (for development/testing only)
        # In production, users would set their own passwords during registration
        # Using a strong default password that should be changed immediately
        default_password = hash_password("DevTestPass2024!SecureDefault")
        
        # 20 initial users with complete profiles
        users = [
            ('9876543210', 'priya.sharma@email.com', default_password, 'Priya Sharma', 'female', 'male', 
             'Coffee addict ☕ | Travel enthusiast 🌍 | Bookworm 📚', '1995-03-15', 
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['coffee', 'travel', 'books', 'foodie'], 100, True),
            
            ('9876543211', 'rahul.verma@email.com', default_password, 'Rahul Verma', 'male', 'female',
             'Fitness freak 💪 | Tech geek 💻 | Foodie 🍕', '1993-07-20',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['fitness', 'tech', 'food', 'gaming'], 150, True),
            
            ('9876543212', 'ananya.singh@email.com', default_password, 'Ananya Singh', 'female', 'male',
             'Artist 🎨 | Dog lover 🐕 | Adventure seeker 🏔️', '1996-11-08',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['art', 'dogs', 'adventure', 'hiking'], 80, True),
            
            ('9876543213', 'arjun.patel@email.com', default_password, 'Arjun Patel', 'male', 'female',
             'Entrepreneur | Music lover 🎵 | Motorcycle enthusiast 🏍️', '1992-05-12',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['music', 'bikes', 'business', 'travel'], 200, True),
            
            ('9876543214', 'sneha.reddy@email.com', default_password, 'Sneha Reddy', 'female', 'male',
             'Yoga instructor 🧘 | Nature lover 🌿 | Minimalist', '1997-09-25',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['yoga', 'nature', 'wellness', 'meditation'], 120, True),
            
            ('9876543215', 'vikram.kumar@email.com', default_password, 'Vikram Kumar', 'male', 'female',
             'Software engineer 👨‍💻 | Gamer 🎮 | Anime fan', '1994-01-30',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['coding', 'gaming', 'anime', 'tech'], 90, True),
            
            ('9876543216', 'ishita.joshi@email.com', default_password, 'Ishita Joshi', 'female', 'male',
             'Fashion blogger 👗 | Wine enthusiast 🍷 | Beach bum 🏖️', '1995-06-18',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['fashion', 'wine', 'beach', 'shopping'], 110, True),
            
            ('9876543217', 'rohan.mehta@email.com', default_password, 'Rohan Mehta', 'male', 'female',
             'Photographer 📸 | Traveler ✈️ | Craft beer lover 🍺', '1991-12-05',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['photography', 'travel', 'beer', 'adventure'], 180, True),
            
            ('9876543218', 'kavya.nair@email.com', default_password, 'Kavya Nair', 'female', 'male',
             'Dentist 🦷 | Dancer 💃 | Foodie with a sweet tooth 🍰', '1996-04-22',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['dance', 'food', 'desserts', 'music'], 95, True),
            
            ('9876543219', 'aditya.chopra@email.com', default_password, 'Aditya Chopra', 'male', 'female',
             'Investment banker 💼 | Runner 🏃 | Whiskey connoisseur 🥃', '1990-08-14',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['finance', 'running', 'whiskey', 'fitness'], 250, True),
            
            ('9876543220', 'meera.krishnan@email.com', default_password, 'Meera Krishnan', 'female', 'male',
             'Classical dancer 💃 | Flexible in every way', '1998-02-14',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['dance', 'music', 'culture'], 85, True),
            
            ('9876543221', 'karan.malhotra@email.com', default_password, 'Karan Malhotra', 'male', 'female',
             'Gym trainer 🏋️ | Fitness enthusiast', '1991-06-22',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['gym', 'protein', 'health'], 175, True),
            
            ('9876543222', 'simran.kaur@email.com', default_password, 'Simran Kaur', 'female', 'male',
             'Air hostess ✈️ | Travel lover', '1995-09-10',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['travel', 'luxury', 'adventure'], 140, True),
            
            ('9876543223', 'dev.sharma@email.com', default_password, 'Dev Sharma', 'male', 'female',
             'Bartender 🍸 | Nightlife enthusiast', '1993-12-03',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['cocktails', 'nightlife', 'music'], 130, True),
            
            ('9876543224', 'pooja.agarwal@email.com', default_password, 'Pooja Agarwal', 'female', 'male',
             'Startup founder 💻 | Hustler', '1994-04-28',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['startup', 'hustle', 'tech'], 200, True),
            
            ('9876543225', 'nikhil.gupta@email.com', default_password, 'Nikhil Gupta', 'male', 'female',
             'Doctor 🩺 | Medical professional', '1989-07-15',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['medicine', 'golf', 'wine'], 220, True),
            
            ('9876543226', 'rhea.kapoor@email.com', default_password, 'Rhea Kapoor', 'female', 'male',
             'Model 📸 | Fashion enthusiast', '1997-11-20',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['modeling', 'fashion', 'luxury'], 160, True),
            
            ('9876543227', 'amit.saxena@email.com', default_password, 'Amit Saxena', 'male', 'female',
             'Chef 👨‍🍳 | Culinary expert', '1992-03-08',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['cooking', 'food', 'wine'], 145, True),
            
            ('9876543228', 'tanya.bhatia@email.com', default_password, 'Tanya Bhatia', 'female', 'male',
             'Lawyer ⚖️ | Legal professional', '1993-08-17',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['law', 'debate', 'reading'], 190, True),
            
            ('9876543229', 'rajat.singhania@email.com', default_password, 'Rajat Singhania', 'male', 'female',
             'Pilot ✈️ | Aviation expert', '1990-01-25',
             ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='],
             ['aviation', 'travel', 'adventure'], 230, True),
        ]
        
        insert_query = """
            INSERT INTO users (phone, email, password_hash, name, gender, looking_for, bio, 
                             birthdate, photos, tags, credits, is_verified)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (phone) DO NOTHING;
        """
        
        cursor.executemany(insert_query, users)
        conn.commit()
        
        # Verify seeding
        cursor.execute("SELECT COUNT(*) FROM users;")
        new_count = cursor.fetchone()[0]
        print(f"✓ Seeded users successfully. Total users: {new_count}")
        
        # Show sample of seeded users
        cursor.execute("SELECT id, name, phone, gender, credits FROM users ORDER BY name LIMIT 5;")
        sample_users = cursor.fetchall()
        print("\n✓ Sample of seeded users:")
        for user in sample_users:
            print(f"  - {user[1]} ({user[2]}) - {user[3]} - {user[4]} credits")
        
    except psycopg2.Error as e:
        conn.rollback()
        print(f"✗ Error seeding users: {e}")
        sys.exit(1)
    finally:
        cursor.close()


def main():
    """Main function to set up the database"""
    print("=" * 60)
    print("VibeCheck Database Setup Script")
    print("=" * 60)
    print()
    
    # Step 1: Create database if it doesn't exist
    create_database_if_not_exists()
    
    # Step 2: Connect to the database
    conn = get_db_connection()
    
    try:
        # Step 3: Create tables
        print("\nCreating database tables...")
        create_tables(conn)
        
        # Step 4: Create indexes
        print("\nCreating database indexes...")
        create_indexes(conn)
        
        # Step 5: Seed initial users
        print("\nSeeding initial users...")
        seed_initial_users(conn)
        
        print("\n" + "=" * 60)
        print("✓ Database setup completed successfully!")
        print("=" * 60)
        print("\n⚠️  SECURITY NOTICE:")
        print("Default password for all seeded users: DevTestPass2024!SecureDefault")
        print("This is for DEVELOPMENT/TESTING only.")
        print("Change passwords before deploying to production!\n")
        
    finally:
        conn.close()
        print("✓ Database connection closed")


if __name__ == "__main__":
    main()
