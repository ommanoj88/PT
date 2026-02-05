import { pool } from '../config/database';

export interface User {
  id: string;
  phone: string | null;
  email: string | null;
  is_verified: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface CreateUserInput {
  phone?: string;
  email?: string;
}

export async function findUserByPhoneOrEmail(phone?: string, email?: string): Promise<User | null> {
  let query: string;
  let params: (string | undefined)[];

  if (phone && email) {
    query = 'SELECT * FROM users WHERE phone = $1 OR email = $2 LIMIT 1';
    params = [phone, email];
  } else if (phone) {
    query = 'SELECT * FROM users WHERE phone = $1 LIMIT 1';
    params = [phone];
  } else if (email) {
    query = 'SELECT * FROM users WHERE email = $1 LIMIT 1';
    params = [email];
  } else {
    return null;
  }

  const result = await pool.query(query, params);
  return result.rows[0] || null;
}

export async function createUser(input: CreateUserInput): Promise<User> {
  const { phone, email } = input;

  const query = `
    INSERT INTO users (phone, email)
    VALUES ($1, $2)
    RETURNING *
  `;

  const result = await pool.query(query, [phone || null, email || null]);
  return result.rows[0];
}

export async function findUserById(id: string): Promise<User | null> {
  const query = 'SELECT * FROM users WHERE id = $1';
  const result = await pool.query(query, [id]);
  return result.rows[0] || null;
}
