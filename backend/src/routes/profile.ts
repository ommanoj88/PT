import { Router, Response } from 'express';
import { AuthRequest, authenticateToken } from '../middleware/auth';
import { findUserById, updateUserProfile, UpdateProfileInput } from '../models/user';

const router = Router();

/**
 * GET /api/profile
 * Get own profile
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
        id: user.id,
        phone: user.phone,
        email: user.email,
        name: user.name,
        gender: user.gender,
        looking_for: user.looking_for,
        bio: user.bio,
        birthdate: user.birthdate,
        photos: user.photos,
        tags: user.tags,
        credits: user.credits,
        is_verified: user.is_verified,
        created_at: user.created_at,
      },
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

/**
 * PUT /api/profile
 * Update own profile
 */
router.put('/', authenticateToken, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;

    if (!userId) {
      res.status(401).json({
        success: false,
        error: 'User not authenticated',
      });
      return;
    }

    const { name, gender, looking_for, bio, birthdate, photos, tags }: UpdateProfileInput =
      req.body;

    // Validate gender if provided
    const validGenders = ['male', 'female', 'non-binary'];
    if (gender && !validGenders.includes(gender.toLowerCase())) {
      res.status(400).json({
        success: false,
        error: 'Invalid gender. Must be one of: male, female, non-binary',
      });
      return;
    }

    // Validate looking_for if provided
    const validLookingFor = ['men', 'women', 'couples'];
    if (looking_for && !validLookingFor.includes(looking_for.toLowerCase())) {
      res.status(400).json({
        success: false,
        error: 'Invalid looking_for. Must be one of: men, women, couples',
      });
      return;
    }

    // Validate bio length if provided
    if (bio && bio.length > 200) {
      res.status(400).json({
        success: false,
        error: 'Bio must be 200 characters or less',
      });
      return;
    }

    // Validate photos count if provided
    if (photos && photos.length > 3) {
      res.status(400).json({
        success: false,
        error: 'Maximum 3 photos allowed',
      });
      return;
    }

    const updateInput: UpdateProfileInput = {};
    if (name !== undefined) updateInput.name = name;
    if (gender !== undefined) updateInput.gender = gender.toLowerCase();
    if (looking_for !== undefined) updateInput.looking_for = looking_for.toLowerCase();
    if (bio !== undefined) updateInput.bio = bio;
    if (birthdate !== undefined) updateInput.birthdate = birthdate;
    if (photos !== undefined) updateInput.photos = photos;
    if (tags !== undefined) updateInput.tags = tags;

    const updatedUser = await updateUserProfile(userId, updateInput);

    if (!updatedUser) {
      res.status(404).json({
        success: false,
        error: 'User not found',
      });
      return;
    }

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        id: updatedUser.id,
        name: updatedUser.name,
        gender: updatedUser.gender,
        looking_for: updatedUser.looking_for,
        bio: updatedUser.bio,
        birthdate: updatedUser.birthdate,
        photos: updatedUser.photos,
        tags: updatedUser.tags,
        credits: updatedUser.credits,
        is_verified: updatedUser.is_verified,
      },
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

export default router;
