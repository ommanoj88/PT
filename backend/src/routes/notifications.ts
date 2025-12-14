import { Router, Response } from 'express';
import { AuthRequest, authenticateToken } from '../middleware/auth';
import { pool } from '../config/database';

const router = Router();

/**
 * GET /api/notifications
 * Get all notifications for the current user
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

    const result = await pool.query(
      `SELECT * FROM notifications 
       WHERE user_id = $1 
       ORDER BY created_at DESC 
       LIMIT 50`,
      [userId],
    );

    res.status(200).json({
      success: true,
      data: {
        notifications: result.rows.map((n) => ({
          id: n.id,
          type: n.type,
          title: n.title,
          body: n.body,
          data: n.data,
          is_read: n.is_read,
          created_at: n.created_at,
        })),
      },
    });
  } catch (error) {
    console.error('Get notifications error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

/**
 * POST /api/notifications/:id/read
 * Mark a notification as read
 */
router.post(
  '/:id/read',
  authenticateToken,
  async (req: AuthRequest, res: Response): Promise<void> => {
    try {
      const userId = req.userId;
      const { id } = req.params;

      if (!userId) {
        res.status(401).json({
          success: false,
          error: 'User not authenticated',
        });
        return;
      }

      await pool.query('UPDATE notifications SET is_read = TRUE WHERE id = $1 AND user_id = $2', [
        id,
        userId,
      ]);

      res.status(200).json({
        success: true,
        message: 'Notification marked as read',
      });
    } catch (error) {
      console.error('Mark notification read error:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
      });
    }
  },
);

/**
 * POST /api/notifications/read-all
 * Mark all notifications as read
 */
router.post(
  '/read-all',
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

      await pool.query('UPDATE notifications SET is_read = TRUE WHERE user_id = $1', [userId]);

      res.status(200).json({
        success: true,
        message: 'All notifications marked as read',
      });
    } catch (error) {
      console.error('Mark all notifications read error:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
      });
    }
  },
);

// Helper function to create notification (exported for use in other routes)
export async function createNotification(
  userId: string,
  type: string,
  title: string,
  body?: string,
  data?: object,
): Promise<void> {
  try {
    await pool.query(
      'INSERT INTO notifications (user_id, type, title, body, data) VALUES ($1, $2, $3, $4, $5)',
      [userId, type, title, body || null, data ? JSON.stringify(data) : null],
    );
  } catch (error) {
    console.error('Create notification error:', error);
  }
}

export default router;
