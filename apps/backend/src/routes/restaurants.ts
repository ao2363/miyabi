import express, { Request, Response } from 'express';
import { authenticateToken, requireRole, AuthRequest } from '../middleware/auth';

const router = express.Router();

// Mock data
const restaurants: any[] = [
  {
    id: 'rest-1',
    name: '銀座 鮨処 雅',
    description: '伝統的な江戸前寿司',
    category: '寿司',
    address: '東京都中央区銀座4-1-1',
    rating: 4.8,
    priceRange: 'luxury',
    reviewCount: 150
  }
];

// GET /api/restaurants - List with filters
router.get('/', async (req: Request, res: Response) => {
  const { category, area, keyword, sort = 'rating', page = 1, limit = 20 } = req.query;

  let filtered = [...restaurants];

  if (keyword) {
    filtered = filtered.filter(r =>
      r.name.includes(keyword as string) ||
      r.description.includes(keyword as string)
    );
  }

  if (category) {
    filtered = filtered.filter(r => r.category === category);
  }

  // Sort
  if (sort === 'rating') {
    filtered.sort((a, b) => b.rating - a.rating);
  } else if (sort === 'reviews') {
    filtered.sort((a, b) => b.reviewCount - a.reviewCount);
  }

  // Pagination
  const pageNum = parseInt(page as string);
  const limitNum = parseInt(limit as string);
  const start = (pageNum - 1) * limitNum;
  const paginated = filtered.slice(start, start + limitNum);

  res.json({
    data: paginated,
    pagination: {
      page: pageNum,
      limit: limitNum,
      total: filtered.length,
      pages: Math.ceil(filtered.length / limitNum)
    }
  });
});

// GET /api/restaurants/:id - Get details
router.get('/:id', async (req: Request, res: Response) => {
  const restaurant = restaurants.find(r => r.id === req.params.id);

  if (!restaurant) {
    return res.status(404).json({ error: 'Restaurant not found' });
  }

  res.json(restaurant);
});

// POST /api/restaurants - Create (admin only)
router.post('/', authenticateToken, requireRole(['admin']), async (req: AuthRequest, res: Response) => {
  const { name, description, category, address, priceRange } = req.body;

  if (!name || !category || !address) {
    return res.status(400).json({ error: 'Required fields missing' });
  }

  const restaurant = {
    id: `rest-${Date.now()}`,
    name,
    description,
    category,
    address,
    priceRange: priceRange || 'moderate',
    rating: 0,
    reviewCount: 0,
    createdAt: new Date().toISOString()
  };

  restaurants.push(restaurant);

  res.status(201).json(restaurant);
});

// PUT /api/restaurants/:id - Update (admin only)
router.put('/:id', authenticateToken, requireRole(['admin']), async (req: AuthRequest, res: Response) => {
  const index = restaurants.findIndex(r => r.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({ error: 'Restaurant not found' });
  }

  restaurants[index] = {
    ...restaurants[index],
    ...req.body,
    updatedAt: new Date().toISOString()
  };

  res.json(restaurants[index]);
});

// DELETE /api/restaurants/:id - Delete (admin only)
router.delete('/:id', authenticateToken, requireRole(['admin']), async (req: AuthRequest, res: Response) => {
  const index = restaurants.findIndex(r => r.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({ error: 'Restaurant not found' });
  }

  restaurants.splice(index, 1);

  res.json({ message: 'Restaurant deleted' });
});

export default router;
