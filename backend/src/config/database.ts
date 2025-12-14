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
      is_verified BOOLEAN DEFAULT FALSE,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
  `;

  try {
    await pool.query(createUsersTable);
    console.log('Database tables initialized successfully');
  } catch (error) {
    console.error('Error initializing database tables:', error);
    throw error;
  }
}
