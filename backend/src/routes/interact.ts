import { Router, Response } from 'express';
import { AuthRequest, authenticateToken } from '../middleware/auth';
import { pool } from '../config/database';

const router = Router();

interface InteractionRequest {
  to_user_id: string;
  action: 'like' | 'pass';
}

/**
 * POST /api/interact
 * Record a like or pass action
 * Check for mutual matches
 */
router.post('/', authenticateToken, async (req: AuthRequest, res: Response): Promise<void> => {
  const client = await pool.connect();
  try {
    const userId = req.userId;
    const { to_user_id, action }: InteractionRequest = req.body;

    if (!userId) {
      res.status(401).json({
        success: false,
        error: 'User not authenticated',
      });
      return;
    }

    // Validate input
    if (!to_user_id) {
      res.status(400).json({
        success: false,
        error: 'to_user_id is required',
      });
      return;
    }

    if (!action || !['like', 'pass'].includes(action)) {
      res.status(400).json({
        success: false,
        error: 'action must be either "like" or "pass"',
      });
      return;
    }

    // Use transaction to prevent race conditions
    await client.query('BEGIN');

    // Check if interaction already exists
    const existingInteraction = await client.query(
      'SELECT * FROM interactions WHERE from_user_id = $1 AND to_user_id = $2',
      [userId, to_user_id],
    );

    if (existingInteraction.rows.length > 0) {
      await client.query('ROLLBACK');
      res.status(400).json({
        success: false,
        error: 'Interaction already recorded',
      });
      return;
    }

    // Record the interaction
    await client.query(
      'INSERT INTO interactions (from_user_id, to_user_id, action) VALUES ($1, $2, $3)',
      [userId, to_user_id, action],
    );

    let isMatch = false;

    // Check for mutual match if action is 'like'
    if (action === 'like') {
      const mutualLike = await client.query(
        "SELECT * FROM interactions WHERE from_user_id = $1 AND to_user_id = $2 AND action = 'like'",
        [to_user_id, userId],
      );

      if (mutualLike.rows.length > 0) {
        // Create a match with ON CONFLICT to handle race conditions
        // Use consistent ordering of user IDs to prevent duplicates
        const [user1, user2] = userId < to_user_id ? [userId, to_user_id] : [to_user_id, userId];
        await client.query(
          'INSERT INTO matches (user1_id, user2_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
          [user1, user2],
        );
        isMatch = true;
      }
    }

    await client.query('COMMIT');

    res.status(200).json({
      success: true,
      message: action === 'like' ? (isMatch ? "It's a match!" : 'Like recorded') : 'Pass recorded',
      data: {
        is_match: isMatch,
      },
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Interaction error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  } finally {
    client.release();
  }
});

/**
 * GET /api/interact/matches
 * Get all matches for the current user
 */
router.get(
  '/matches',
  authenticateToken,
  async (req: AuthRequest, res: Response): Promise<void> => {
    try {
      const userId = req.userId;

      if (!userId) {
        res.status(401).json({
          success: false,
          error: 'User not authenticated',
        });
        return;
      }

      const query = `
      SELECT 
        m.id as match_id,
        m.created_at as matched_at,
        u.id as user_id,
        u.name,
        u.photos,
        u.bio
      FROM matches m
      JOIN users u ON (
        (m.user1_id = $1 AND m.user2_id = u.id) OR
        (m.user2_id = $1 AND m.user1_id = u.id)
      )
      ORDER BY m.created_at DESC
    `;

      const result = await pool.query(query, [userId]);

      res.status(200).json({
        success: true,
        data: {
          matches: result.rows.map((row) => ({
            match_id: row.match_id,
            matched_at: row.matched_at,
            user: {
              id: row.user_id,
              name: row.name,
              photos: row.photos || [],
              bio: row.bio,
            },
          })),
        },
      });
    } catch (error) {
      console.error('Get matches error:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
      });
    }
  },
);

export default router;
