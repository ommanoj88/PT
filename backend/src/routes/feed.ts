import { Router, Response } from 'express';
import { AuthRequest, authenticateToken } from '../middleware/auth';
import { pool } from '../config/database';

const router = Router();

/**
 * GET /api/feed
 * Get potential matches based on looking_for criteria
 * Excludes users already liked/passed
 */
router.get('/', authenticateToken, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;

    if (!userId) {
      res.status(401).json({
        success: false,
        error: 'User not authenticated',
      });
      return;
    }

    // Get current user's preferences
    const userResult = await pool.query('SELECT * FROM users WHERE id = $1', [userId]);
    const currentUser = userResult.rows[0];

    if (!currentUser) {
      res.status(404).json({
        success: false,
        error: 'User not found',
      });
      return;
    }

    // Map looking_for to gender filter
    let genderFilter = '';
    if (currentUser.looking_for === 'men') {
      genderFilter = "AND gender = 'male'";
    } else if (currentUser.looking_for === 'women') {
      genderFilter = "AND gender = 'female'";
    }
    // 'couples' or null - return all

    // Get users that match criteria, excluding:
    // 1. Current user
    // 2. Users already interacted with (liked/passed)
    const query = `
      SELECT 
        u.id,
        u.name,
        u.gender,
        u.bio,
        u.birthdate,
        u.photos,
        u.tags,
        u.is_verified,
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.birthdate)) as age
      FROM users u
      WHERE u.id != $1
        AND u.name IS NOT NULL
        ${genderFilter}
        AND u.id NOT IN (
          SELECT to_user_id FROM interactions WHERE from_user_id = $1
        )
      ORDER BY u.created_at DESC
      LIMIT 20
    `;

    const result = await pool.query(query, [userId]);

    res.status(200).json({
      success: true,
      data: {
        users: result.rows.map((user) => ({
          id: user.id,
          name: user.name,
          gender: user.gender,
          bio: user.bio,
          age: user.age ? parseInt(user.age) : null,
          photos: user.photos || [],
          tags: user.tags || [],
          is_verified: user.is_verified,
        })),
      },
    });
  } catch (error) {
    console.error('Feed error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

export default router;
