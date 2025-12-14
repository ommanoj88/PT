import { pool } from '../config/database';

export interface User {
  id: string;
  phone: string | null;
  email: string | null;
  name: string | null;
  gender: string | null;
  looking_for: string | null;
  bio: string | null;
  birthdate: Date | null;
  photos: string[] | null;
  tags: string[] | null;
  credits: number;
  is_verified: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface CreateUserInput {
  phone?: string;
  email?: string;
}

export interface UpdateProfileInput {
  name?: string;
  gender?: string;
  looking_for?: string;
  bio?: string;
  birthdate?: string;
  photos?: string[];
  tags?: string[];
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

export async function updateUserProfile(
  id: string,
  input: UpdateProfileInput,
): Promise<User | null> {
  const updates: string[] = [];
  const values: (string | string[] | null)[] = [];
  let paramIndex = 1;

  if (input.name !== undefined) {
    updates.push(`name = $${paramIndex++}`);
    values.push(input.name);
  }
  if (input.gender !== undefined) {
    updates.push(`gender = $${paramIndex++}`);
    values.push(input.gender);
  }
  if (input.looking_for !== undefined) {
    updates.push(`looking_for = $${paramIndex++}`);
    values.push(input.looking_for);
  }
  if (input.bio !== undefined) {
    updates.push(`bio = $${paramIndex++}`);
    values.push(input.bio);
  }
  if (input.birthdate !== undefined) {
    updates.push(`birthdate = $${paramIndex++}`);
    values.push(input.birthdate);
  }
  if (input.photos !== undefined) {
    updates.push(`photos = $${paramIndex++}`);
    values.push(input.photos);
  }
  if (input.tags !== undefined) {
    updates.push(`tags = $${paramIndex++}`);
    values.push(input.tags);
  }

  if (updates.length === 0) {
    return findUserById(id);
  }

  updates.push(`updated_at = CURRENT_TIMESTAMP`);
  values.push(id);

  const query = `
    UPDATE users
    SET ${updates.join(', ')}
    WHERE id = $${paramIndex}
    RETURNING *
  `;

  const result = await pool.query(query, values);
  return result.rows[0] || null;
}

export async function updateUserCredits(id: string, credits: number): Promise<User | null> {
  const query = `
    UPDATE users
    SET credits = credits + $1, updated_at = CURRENT_TIMESTAMP
    WHERE id = $2
    RETURNING *
  `;

  const result = await pool.query(query, [credits, id]);
  return result.rows[0] || null;
}
