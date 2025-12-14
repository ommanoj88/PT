import express, { Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import { testDatabaseConnections, initializeDatabase } from './config/database';
import authRoutes from './routes/auth';
import profileRoutes from './routes/profile';
import feedRoutes from './routes/feed';
import interactRoutes from './routes/interact';
import diceRoutes from './routes/dice';
import walletRoutes from './routes/wallet';
import chatRoutes from './routes/chat';
import notificationRoutes from './routes/notifications';
import reportRoutes from './routes/report';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '10mb' })); // Increased limit for base64 photos

// Health check endpoint
app.get('/api/health', (_req: Request, res: Response) => {
  res.status(200).json({
    status: 'ok',
    message: 'VibeCheck API is running',
    timestamp: new Date().toISOString(),
  });
});

// Auth routes
app.use('/api/auth', authRoutes);

// Profile routes
app.use('/api/profile', profileRoutes);

// Feed routes (Discovery)
app.use('/api/feed', feedRoutes);

// Interaction routes (Like/Pass)
app.use('/api/interact', interactRoutes);

// Dice routes (Roll the Dice)
app.use('/api/dice', diceRoutes);

// Wallet routes (Credits)
app.use('/api/wallet', walletRoutes);

// Chat routes
app.use('/api/chat', chatRoutes);

// Notification routes
app.use('/api/notifications', notificationRoutes);

// Report routes (Trust & Safety)
app.use('/api/report', reportRoutes);

// Initialize database and start server
async function startServer(): Promise<void> {
  try {
    // Test database connections
    await testDatabaseConnections();

    // Initialize database tables
    await initializeDatabase();

    // Start server
    app.listen(PORT, () => {
      console.log(`Server is running on port ${PORT}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    // Start server anyway for development (database might not be running)
    console.log('Starting server without database connection...');
    app.listen(PORT, () => {
      console.log(`Server is running on port ${PORT} (without database)`);
    });
  }
}

startServer();

export default app;
