import express, { Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import rateLimit from 'express-rate-limit';
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
import requestRoutes from './routes/requests';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Rate limiting configuration
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: { success: false, error: 'Too many requests, please try again later' },
  standardHeaders: true,
  legacyHeaders: false,
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // Limit each IP to 10 auth requests per windowMs
  message: { success: false, error: 'Too many authentication attempts, please try again later' },
  standardHeaders: true,
  legacyHeaders: false,
});

const interactLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 30, // Limit each IP to 30 interactions per minute
  message: { success: false, error: 'Too many interactions, please slow down' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Middleware
app.use(helmet());
// Allow CORS from any localhost origin (Flutter uses random ports)
app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or curl)
    if (!origin) return callback(null, true);
    
    // Allow any localhost origin
    if (origin.startsWith('http://localhost:') || origin.startsWith('http://127.0.0.1:')) {
      return callback(null, true);
    }
    
    // Block all other origins
    callback(new Error('Not allowed by CORS'));
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json({ limit: '10mb' })); // Increased limit for base64 photos
app.use(generalLimiter); // Apply general rate limiting to all routes

// Health check endpoint
app.get('/api/health', (_req: Request, res: Response) => {
  res.status(200).json({
    status: 'ok',
    message: 'VibeCheck API is running',
    timestamp: new Date().toISOString(),
  });
});

// Auth routes (with stricter rate limiting)
app.use('/api/auth', authLimiter, authRoutes);

// Profile routes
app.use('/api/profile', profileRoutes);

// Feed routes (Discovery)
app.use('/api/feed', feedRoutes);

// Interaction routes (Like/Pass) - with interaction-specific rate limiting
app.use('/api/interact', interactLimiter, interactRoutes);

// Dice routes (Roll the Dice) - with interaction-specific rate limiting
app.use('/api/dice', interactLimiter, diceRoutes);

// Wallet routes (Credits)
app.use('/api/wallet', walletRoutes);

// Chat routes
app.use('/api/chat', chatRoutes);

// Notification routes
app.use('/api/notifications', notificationRoutes);

// Report routes (Trust & Safety)
app.use('/api/report', reportRoutes);

// Chat Requests routes (Pure-style direct request model)
app.use('/api/requests', interactLimiter, requestRoutes);

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
