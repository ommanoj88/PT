import { Router, Response } from 'express';
import { AuthRequest, authenticateToken } from '../middleware/auth';
import { pool } from '../config/database';

const router = Router();

/**
 * GET /api/dice
 * Return 1 random user for the "Roll the Dice" feature
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

    // Get a random user that matches criteria
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
      ORDER BY RANDOM()
      LIMIT 1
    `;

    const result = await pool.query(query, [userId]);

    if (result.rows.length === 0) {
      res.status(404).json({
        success: false,
        error: 'No users found',
      });
      return;
    }

    const user = result.rows[0];

    res.status(200).json({
      success: true,
      data: {
        user: {
          id: user.id,
          name: user.name,
          gender: user.gender,
          bio: user.bio,
          age: user.age ? parseInt(user.age) : null,
          photos: user.photos || [],
          tags: user.tags || [],
          is_verified: user.is_verified,
        },
      },
    });
  } catch (error) {
    console.error('Dice roll error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

export default router;
