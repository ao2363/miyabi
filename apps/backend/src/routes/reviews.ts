import express, { Response } from 'express';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = express.Router();
const reviews: any[] = [];

// GET /api/restaurants/:restaurantId/reviews
router.get('/restaurant/:restaurantId', async (req, res: Response) => {
  const restaurantReviews = reviews.filter(r => r.restaurantId === req.params.restaurantId);
  res.json({ data: restaurantReviews, total: restaurantReviews.length });
});

// GET /api/reviews/:id
router.get('/:id', async (req, res: Response) => {
  const review = reviews.find(r => r.id === req.params.id);
  if (!review) return res.status(404).json({ error: 'Review not found' });
  res.json(review);
});

// POST /api/restaurants/:restaurantId/reviews
router.post('/restaurant/:restaurantId', authenticateToken, async (req: AuthRequest, res: Response) => {
  const { rating, title, content, visitDate } = req.body;

  if (!rating || !title || !content) {
    return res.status(400).json({ error: 'Required fields missing' });
  }

  // Check duplicate
  const existing = reviews.find(r =>
    r.userId === req.user?.id && r.restaurantId === req.params.restaurantId
  );
  if (existing) {
    return res.status(409).json({ error: 'Already reviewed' });
  }

  const review = {
    id: `review-${Date.now()}`,
    userId: req.user?.id,
    restaurantId: req.params.restaurantId,
    rating,
    title,
    content,
    visitDate,
    createdAt: new Date().toISOString()
  };

  reviews.push(review);
  res.status(201).json(review);
});

// PUT /api/reviews/:id
router.put('/:id', authenticateToken, async (req: AuthRequest, res: Response) => {
  const index = reviews.findIndex(r => r.id === req.params.id && r.userId === req.user?.id);
  if (index === -1) return res.status(404).json({ error: 'Review not found' });

  reviews[index] = { ...reviews[index], ...req.body, updatedAt: new Date().toISOString() };
  res.json(reviews[index]);
});

// DELETE /api/reviews/:id
router.delete('/:id', authenticateToken, async (req: AuthRequest, res: Response) => {
  const index = reviews.findIndex(r => r.id === req.params.id && r.userId === req.user?.id);
  if (index === -1) return res.status(404).json({ error: 'Review not found' });

  reviews.splice(index, 1);
  res.json({ message: 'Review deleted' });
});

// POST /api/reviews/:id/like
router.post('/:id/like', authenticateToken, async (req: AuthRequest, res: Response) => {
  res.json({ message: 'Liked' });
});

export default router;
