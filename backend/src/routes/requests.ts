import { Router, Response } from 'express';
import { AuthRequest, authenticateToken } from '../middleware/auth';
import { pool } from '../config/database';

const router = Router();

/**
 * POST /api/requests
 * Send a chat request to another user (Pure-style direct request)
 */
router.post('/', authenticateToken, async (req: AuthRequest, res: Response): Promise<void> => {
  const client = await pool.connect();
  try {
    const userId = req.userId;
    const { to_user_id, message } = req.body;

    if (!userId) {
      res.status(401).json({
        success: false,
        error: 'User not authenticated',
      });
      return;
    }

    if (!to_user_id) {
      res.status(400).json({
        success: false,
        error: 'to_user_id is required',
      });
      return;
    }

    // Check if recipient exists and is live
    const recipientResult = await client.query(
      'SELECT id, name, is_live, live_until FROM users WHERE id = $1',
      [to_user_id],
    );

    if (recipientResult.rows.length === 0) {
      res.status(404).json({
        success: false,
        error: 'User not found',
      });
      return;
    }

    const recipient = recipientResult.rows[0];
    if (!recipient.is_live || new Date(recipient.live_until) < new Date()) {
      res.status(400).json({
        success: false,
        error: 'User is no longer available',
      });
      return;
    }

    await client.query('BEGIN');

    // Check if request already exists
    const existingRequest = await client.query(
      'SELECT * FROM chat_requests WHERE from_user_id = $1 AND to_user_id = $2 AND status = $3',
      [userId, to_user_id, 'pending'],
    );

    if (existingRequest.rows.length > 0) {
      await client.query('ROLLBACK');
      res.status(400).json({
        success: false,
        error: 'Request already sent',
      });
      return;
    }

    // Create the chat request
    const result = await client.query(
      `INSERT INTO chat_requests (from_user_id, to_user_id, message, expires_at) 
       VALUES ($1, $2, $3, CURRENT_TIMESTAMP + INTERVAL '1 hour')
       ON CONFLICT (from_user_id, to_user_id) 
       DO UPDATE SET message = $3, status = 'pending', created_at = CURRENT_TIMESTAMP, expires_at = CURRENT_TIMESTAMP + INTERVAL '1 hour', responded_at = NULL
       RETURNING *`,
      [userId, to_user_id, message || null],
    );

    await client.query('COMMIT');

    res.status(201).json({
      success: true,
      message: 'Chat request sent!',
      data: {
        request: result.rows[0],
      },
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Send request error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  } finally {
    client.release();
  }
});

/**
 * GET /api/requests
 * Get all incoming chat requests (Pure-style)
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

    // Get pending requests that haven't expired
    const result = await pool.query(
      `SELECT 
        cr.id,
        cr.from_user_id,
        cr.message,
        cr.status,
        cr.created_at,
        cr.expires_at,
        u.name as from_user_name,
        u.photos as from_user_photos,
        u.bio as from_user_bio,
        u.gender as from_user_gender,
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.birthdate)) as from_user_age,
        EXTRACT(EPOCH FROM (cr.expires_at - CURRENT_TIMESTAMP)) / 60 as minutes_remaining
      FROM chat_requests cr
      JOIN users u ON cr.from_user_id = u.id
      WHERE cr.to_user_id = $1 
        AND cr.status = 'pending'
        AND cr.expires_at > CURRENT_TIMESTAMP
      ORDER BY cr.created_at DESC`,
      [userId],
    );

    res.status(200).json({
      success: true,
      data: {
        requests: result.rows.map((row) => ({
          id: row.id,
          from_user: {
            id: row.from_user_id,
            name: row.from_user_name,
            photos: row.from_user_photos || [],
            bio: row.from_user_bio,
            gender: row.from_user_gender,
            age: row.from_user_age ? parseInt(row.from_user_age) : null,
          },
          message: row.message,
          status: row.status,
          created_at: row.created_at,
          expires_at: row.expires_at,
          minutes_remaining: row.minutes_remaining ? Math.round(row.minutes_remaining) : null,
        })),
      },
    });
  } catch (error) {
    console.error('Get requests error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

/**
 * GET /api/requests/sent
 * Get all sent chat requests
 */
router.get('/sent', authenticateToken, async (req: AuthRequest, res: Response): Promise<void> => {
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
      `SELECT 
        cr.id,
        cr.to_user_id,
        cr.message,
        cr.status,
        cr.created_at,
        cr.expires_at,
        cr.responded_at,
        u.name as to_user_name,
        u.photos as to_user_photos,
        EXTRACT(EPOCH FROM (cr.expires_at - CURRENT_TIMESTAMP)) / 60 as minutes_remaining
      FROM chat_requests cr
      JOIN users u ON cr.to_user_id = u.id
      WHERE cr.from_user_id = $1 
        AND cr.created_at > CURRENT_TIMESTAMP - INTERVAL '24 hours'
      ORDER BY cr.created_at DESC`,
      [userId],
    );

    res.status(200).json({
      success: true,
      data: {
        requests: result.rows.map((row) => ({
          id: row.id,
          to_user: {
            id: row.to_user_id,
            name: row.to_user_name,
            photos: row.to_user_photos || [],
          },
          message: row.message,
          status: row.status,
          created_at: row.created_at,
          expires_at: row.expires_at,
          responded_at: row.responded_at,
          minutes_remaining: row.minutes_remaining ? Math.round(row.minutes_remaining) : null,
        })),
      },
    });
  } catch (error) {
    console.error('Get sent requests error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

/**
 * POST /api/requests/:requestId/accept
 * Accept a chat request (creates a match)
 */
router.post(
  '/:requestId/accept',
  authenticateToken,
  async (req: AuthRequest, res: Response): Promise<void> => {
    const client = await pool.connect();
    try {
      const userId = req.userId;
      const { requestId } = req.params;

      if (!userId) {
        res.status(401).json({
          success: false,
          error: 'User not authenticated',
        });
        return;
      }

      await client.query('BEGIN');

      // Get the request
      const requestResult = await client.query(
        'SELECT * FROM chat_requests WHERE id = $1 AND to_user_id = $2 AND status = $3',
        [requestId, userId, 'pending'],
      );

      if (requestResult.rows.length === 0) {
        await client.query('ROLLBACK');
        res.status(404).json({
          success: false,
          error: 'Request not found or already handled',
        });
        return;
      }

      const request = requestResult.rows[0];

      // Check if request has expired
      if (new Date(request.expires_at) < new Date()) {
        await client.query('ROLLBACK');
        res.status(400).json({
          success: false,
          error: 'Request has expired',
        });
        return;
      }

      // Update request status
      await client.query(
        'UPDATE chat_requests SET status = $1, responded_at = CURRENT_TIMESTAMP WHERE id = $2',
        ['accepted', requestId],
      );

      // Create a match
      const [user1, user2] =
        userId < request.from_user_id
          ? [userId, request.from_user_id]
          : [request.from_user_id, userId];

      const matchResult = await client.query(
        'INSERT INTO matches (user1_id, user2_id) VALUES ($1, $2) ON CONFLICT DO NOTHING RETURNING *',
        [user1, user2],
      );

      await client.query('COMMIT');

      res.status(200).json({
        success: true,
        message: 'Request accepted! You can now chat.',
        data: {
          match_id: matchResult.rows[0]?.id,
        },
      });
    } catch (error) {
      await client.query('ROLLBACK');
      console.error('Accept request error:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
      });
    } finally {
      client.release();
    }
  },
);

/**
 * POST /api/requests/:requestId/reject
 * Reject a chat request
 */
router.post(
  '/:requestId/reject',
  authenticateToken,
  async (req: AuthRequest, res: Response): Promise<void> => {
    try {
      const userId = req.userId;
      const { requestId } = req.params;

      if (!userId) {
        res.status(401).json({
          success: false,
          error: 'User not authenticated',
        });
        return;
      }

      const result = await pool.query(
        'UPDATE chat_requests SET status = $1, responded_at = CURRENT_TIMESTAMP WHERE id = $2 AND to_user_id = $3 AND status = $4 RETURNING *',
        ['rejected', requestId, userId, 'pending'],
      );

      if (result.rows.length === 0) {
        res.status(404).json({
          success: false,
          error: 'Request not found or already handled',
        });
        return;
      }

      res.status(200).json({
        success: true,
        message: 'Request rejected',
      });
    } catch (error) {
      console.error('Reject request error:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
      });
    }
  },
);

export default router;
