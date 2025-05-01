const express = require('express');
const { rateProduct } = require('../controllers/reviewController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.post('/rateProduct', authMiddleware, rateProduct);

module.exports = router;
