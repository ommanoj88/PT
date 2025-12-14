import { Router, Response } from 'express';
import { AuthRequest, authenticateToken } from '../middleware/auth';
import { findUserById, updateUserCredits } from '../models/user';

const router = Router();

interface AddCreditsRequest {
  amount: number;
}

/**
 * GET /api/wallet
 * Get current credit balance
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

    const user = await findUserById(userId);

    if (!user) {
      res.status(404).json({
        success: false,
        error: 'User not found',
      });
      return;
    }

    res.status(200).json({
      success: true,
      data: {
        credits: user.credits,
      },
    });
  } catch (error) {
    console.error('Get wallet error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

/**
 * POST /api/wallet/add
 * Mock endpoint to add credits (simulated purchase)
 */
router.post('/add', authenticateToken, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    const { amount }: AddCreditsRequest = req.body;

    if (!userId) {
      res.status(401).json({
        success: false,
        error: 'User not authenticated',
      });
      return;
    }

    // Validate amount
    if (!amount || typeof amount !== 'number' || amount <= 0) {
      res.status(400).json({
        success: false,
        error: 'Amount must be a positive number',
      });
      return;
    }

    // Cap maximum credits that can be added at once
    if (amount > 1000) {
      res.status(400).json({
        success: false,
        error: 'Maximum 1000 credits can be added at once',
      });
      return;
    }

    const updatedUser = await updateUserCredits(userId, amount);

    if (!updatedUser) {
      res.status(404).json({
        success: false,
        error: 'User not found',
      });
      return;
    }

    res.status(200).json({
      success: true,
      message: `${amount} credits added successfully`,
      data: {
        credits: updatedUser.credits,
      },
    });
  } catch (error) {
    console.error('Add credits error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

/**
 * POST /api/wallet/spend
 * Spend credits for actions
 */
router.post('/spend', authenticateToken, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    const { amount }: AddCreditsRequest = req.body;

    if (!userId) {
      res.status(401).json({
        success: false,
        error: 'User not authenticated',
      });
      return;
    }

    // Validate amount
    if (!amount || typeof amount !== 'number' || amount <= 0) {
      res.status(400).json({
        success: false,
        error: 'Amount must be a positive number',
      });
      return;
    }

    const user = await findUserById(userId);

    if (!user) {
      res.status(404).json({
        success: false,
        error: 'User not found',
      });
      return;
    }

    if (user.credits < amount) {
      res.status(400).json({
        success: false,
        error: 'Insufficient credits',
      });
      return;
    }

    const updatedUser = await updateUserCredits(userId, -amount);

    res.status(200).json({
      success: true,
      message: `${amount} credits spent`,
      data: {
        credits: updatedUser?.credits ?? 0,
      },
    });
  } catch (error) {
    console.error('Spend credits error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

export default router;
