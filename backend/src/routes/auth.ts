import { Router, Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { findUserByPhoneOrEmail, createUser } from '../models/user';

const router = Router();

const JWT_SECRET = process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production';
const JWT_EXPIRES_IN = '7d';

interface LoginRequest {
  phone?: string;
  email?: string;
}

/**
 * POST /api/auth/login
 * Mock authentication - creates user if not exists, returns JWT token
 */
router.post('/login', async (req: Request, res: Response): Promise<void> => {
  try {
    const { phone, email }: LoginRequest = req.body;

    // Validate input - at least one of phone or email is required
    if (!phone && !email) {
      res.status(400).json({
        success: false,
        error: 'Phone number or email is required',
      });
      return;
    }

    // Find existing user or create new one
    let user = await findUserByPhoneOrEmail(phone, email);

    if (!user) {
      // Create new user (mock auth - no OTP verification)
      user = await createUser({ phone, email });
      console.log('New user created:', user.id);
    } else {
      console.log('Existing user logged in:', user.id);
    }

    // Generate JWT token
    const token = jwt.sign(
      {
        userId: user.id,
        phone: user.phone,
        email: user.email,
      },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN },
    );

    res.status(200).json({
      success: true,
      message: user ? 'Login successful' : 'Account created successfully',
      data: {
        token,
        user: {
          id: user.id,
          phone: user.phone,
          email: user.email,
          is_verified: user.is_verified,
          created_at: user.created_at,
        },
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

export default router;
