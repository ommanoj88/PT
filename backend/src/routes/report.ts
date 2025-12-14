import { Router, Response } from 'express';
import { AuthRequest, authenticateToken } from '../middleware/auth';
import { pool } from '../config/database';

const router = Router();

interface ReportRequest {
  reported_user_id: string;
  reason: string;
  description?: string;
}

/**
 * POST /api/report
 * Report a user
 */
router.post('/', authenticateToken, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    const { reported_user_id, reason, description }: ReportRequest = req.body;

    if (!userId) {
      res.status(401).json({
        success: false,
        error: 'User not authenticated',
      });
      return;
    }

    // Validate input
    if (!reported_user_id) {
      res.status(400).json({
        success: false,
        error: 'reported_user_id is required',
      });
      return;
    }

    if (!reason || reason.trim().length === 0) {
      res.status(400).json({
        success: false,
        error: 'reason is required',
      });
      return;
    }

    // Can't report yourself
    if (reported_user_id === userId) {
      res.status(400).json({
        success: false,
        error: 'Cannot report yourself',
      });
      return;
    }

    // Check if user exists
    const userResult = await pool.query('SELECT id FROM users WHERE id = $1', [reported_user_id]);
    if (userResult.rows.length === 0) {
      res.status(404).json({
        success: false,
        error: 'Reported user not found',
      });
      return;
    }

    // Check if already reported by this user
    const existingReport = await pool.query(
      'SELECT id FROM reports WHERE reporter_id = $1 AND reported_user_id = $2',
      [userId, reported_user_id],
    );

    if (existingReport.rows.length > 0) {
      res.status(400).json({
        success: false,
        error: 'You have already reported this user',
      });
      return;
    }

    // Create report
    await pool.query(
      'INSERT INTO reports (reporter_id, reported_user_id, reason, description) VALUES ($1, $2, $3, $4)',
      [userId, reported_user_id, reason.trim(), description?.trim() || null],
    );

    res.status(201).json({
      success: true,
      message: 'Report submitted successfully',
    });
  } catch (error) {
    console.error('Report user error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

/**
 * GET /api/report/blocked
 * Get list of users blocked by reporting
 */
router.get(
  '/blocked',
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

      // Get all users that this user has reported
      const result = await pool.query(
        `SELECT r.reported_user_id, u.name, r.created_at
       FROM reports r
       JOIN users u ON r.reported_user_id = u.id
       WHERE r.reporter_id = $1
       ORDER BY r.created_at DESC`,
        [userId],
      );

      res.status(200).json({
        success: true,
        data: {
          blocked_users: result.rows.map((row) => ({
            user_id: row.reported_user_id,
            name: row.name,
            blocked_at: row.created_at,
          })),
        },
      });
    } catch (error) {
      console.error('Get blocked users error:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
      });
    }
  },
);

export default router;
