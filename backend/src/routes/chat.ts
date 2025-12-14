import { Router, Response } from 'express';
import { AuthRequest, authenticateToken } from '../middleware/auth';
import { pool } from '../config/database';

const router = Router();

interface SendMessageRequest {
  content: string;
}

/**
 * GET /api/chat/:matchId
 * Load chat history for a match
 */
router.get(
  '/:matchId',
  authenticateToken,
  async (req: AuthRequest, res: Response): Promise<void> => {
    try {
      const userId = req.userId;
      const { matchId } = req.params;

      if (!userId) {
        res.status(401).json({
          success: false,
          error: 'User not authenticated',
        });
        return;
      }

      // Verify user is part of this match
      const matchResult = await pool.query(
        'SELECT * FROM matches WHERE id = $1 AND (user1_id = $2 OR user2_id = $2)',
        [matchId, userId],
      );

      if (matchResult.rows.length === 0) {
        res.status(404).json({
          success: false,
          error: 'Match not found or access denied',
        });
        return;
      }

      // Get messages
      const messagesResult = await pool.query(
        `SELECT 
        m.id,
        m.sender_id,
        m.content,
        m.created_at,
        m.viewed_at,
        u.name as sender_name
      FROM messages m
      JOIN users u ON m.sender_id = u.id
      WHERE m.match_id = $1
      ORDER BY m.created_at ASC`,
        [matchId],
      );

      // Mark messages as viewed
      await pool.query(
        'UPDATE messages SET viewed_at = CURRENT_TIMESTAMP WHERE match_id = $1 AND sender_id != $2 AND viewed_at IS NULL',
        [matchId, userId],
      );

      res.status(200).json({
        success: true,
        data: {
          messages: messagesResult.rows.map((msg) => ({
            id: msg.id,
            sender_id: msg.sender_id,
            sender_name: msg.sender_name,
            content: msg.content,
            created_at: msg.created_at,
            viewed_at: msg.viewed_at,
            is_mine: msg.sender_id === userId,
          })),
        },
      });
    } catch (error) {
      console.error('Get chat history error:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
      });
    }
  },
);

/**
 * POST /api/chat/:matchId
 * Send a message in a chat
 */
router.post(
  '/:matchId',
  authenticateToken,
  async (req: AuthRequest, res: Response): Promise<void> => {
    try {
      const userId = req.userId;
      const { matchId } = req.params;
      const { content }: SendMessageRequest = req.body;

      if (!userId) {
        res.status(401).json({
          success: false,
          error: 'User not authenticated',
        });
        return;
      }

      if (!content || content.trim().length === 0) {
        res.status(400).json({
          success: false,
          error: 'Message content is required',
        });
        return;
      }

      // Verify user is part of this match
      const matchResult = await pool.query(
        'SELECT * FROM matches WHERE id = $1 AND (user1_id = $2 OR user2_id = $2)',
        [matchId, userId],
      );

      if (matchResult.rows.length === 0) {
        res.status(404).json({
          success: false,
          error: 'Match not found or access denied',
        });
        return;
      }

      // Insert message
      const result = await pool.query(
        'INSERT INTO messages (match_id, sender_id, content) VALUES ($1, $2, $3) RETURNING *',
        [matchId, userId, content.trim()],
      );

      const message = result.rows[0];

      res.status(201).json({
        success: true,
        message: 'Message sent',
        data: {
          id: message.id,
          sender_id: message.sender_id,
          content: message.content,
          created_at: message.created_at,
        },
      });
    } catch (error) {
      console.error('Send message error:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
      });
    }
  },
);

export default router;
