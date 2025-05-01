const express = require('express');
const router = express.Router();
const { handlePlaceOrder,getUserOrders } = require('../controllers/orderController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/placeOrder', authMiddleware, handlePlaceOrder);
router.get('/getAllOrders', authMiddleware, getUserOrders);

module.exports = router;
 
