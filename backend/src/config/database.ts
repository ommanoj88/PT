import { Pool } from 'pg';
import Redis from 'ioredis';

// PostgreSQL connection pool
export const pool = new Pool({
  host: process.env.POSTGRES_HOST || 'localhost',
  port: parseInt(process.env.POSTGRES_PORT || '5432', 10),
  user: process.env.POSTGRES_USER || 'vibecheck',
  password: process.env.POSTGRES_PASSWORD || 'vibecheck_dev',
  database: process.env.POSTGRES_DB || 'vibecheck',
});

// Redis client
export const redis = new Redis({
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379', 10),
});

// Test database connections
export async function testDatabaseConnections(): Promise<void> {
  try {
    // Test PostgreSQL connection
    const pgClient = await pool.connect();
    console.log('PostgreSQL connected successfully');
    pgClient.release();

    // Test Redis connection
    await redis.ping();
    console.log('Redis connected successfully');
  } catch (error) {
    console.error('Database connection error:', error);
    throw error;
  }
}

// Initialize database tables
export async function initializeDatabase(): Promise<void> {
  const createUsersTable = `
    CREATE TABLE IF NOT EXISTS users (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
  `;

  const createInteractionsTable = `
    CREATE TABLE IF NOT EXISTS interactions (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      from_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      to_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      action VARCHAR(10) NOT NULL CHECK (action IN ('like', 'pass')),
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(from_user_id, to_user_id)
    );
  `;

  const createMatchesTable = `
    CREATE TABLE IF NOT EXISTS matches (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      user2_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(user1_id, user2_id)
    );
  `;

  const createMessagesTable = `
    CREATE TABLE IF NOT EXISTS messages (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
      sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      content TEXT NOT NULL,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      viewed_at TIMESTAMP WITH TIME ZONE
    );
  `;

  const createNotificationsTable = `
    CREATE TABLE IF NOT EXISTS notifications (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      type VARCHAR(50) NOT NULL,
      title VARCHAR(200) NOT NULL,
      body TEXT,
      data JSONB,
      is_read BOOLEAN DEFAULT FALSE,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
  `;

  const createReportsTable = `
    CREATE TABLE IF NOT EXISTS reports (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      reporter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      reported_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      reason VARCHAR(200) NOT NULL,
      description TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
  `;

  // Add new columns if they don't exist (for existing tables)
  const addColumnsIfNotExist = `
    DO $$ 
    BEGIN
      BEGIN ALTER TABLE users ADD COLUMN name VARCHAR(100); EXCEPTION WHEN duplicate_column THEN NULL; END;
      BEGIN ALTER TABLE users ADD COLUMN gender VARCHAR(20); EXCEPTION WHEN duplicate_column THEN NULL; END;
      BEGIN ALTER TABLE users ADD COLUMN looking_for VARCHAR(20); EXCEPTION WHEN duplicate_column THEN NULL; END;
      BEGIN ALTER TABLE users ADD COLUMN bio VARCHAR(200); EXCEPTION WHEN duplicate_column THEN NULL; END;
      BEGIN ALTER TABLE users ADD COLUMN birthdate DATE; EXCEPTION WHEN duplicate_column THEN NULL; END;
      BEGIN ALTER TABLE users ADD COLUMN photos TEXT[]; EXCEPTION WHEN duplicate_column THEN NULL; END;
      BEGIN ALTER TABLE users ADD COLUMN tags TEXT[]; EXCEPTION WHEN duplicate_column THEN NULL; END;
      BEGIN ALTER TABLE users ADD COLUMN credits INTEGER DEFAULT 0; EXCEPTION WHEN duplicate_column THEN NULL; END;
    END $$;
  `;

  try {
    await pool.query(createUsersTable);
    await pool.query(addColumnsIfNotExist);
    await pool.query(createInteractionsTable);
    await pool.query(createMatchesTable);
    await pool.query(createMessagesTable);
    await pool.query(createNotificationsTable);
    await pool.query(createReportsTable);
    console.log('Database tables initialized successfully');
  } catch (error) {
    console.error('Error initializing database tables:', error);
    throw error;
  }
}
