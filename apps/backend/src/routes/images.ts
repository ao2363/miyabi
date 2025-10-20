import express from 'express';
const router = express.Router();
router.post('/upload', (req, res) => res.json({ url: 'https://example.com/image.jpg' }));
export default router;
