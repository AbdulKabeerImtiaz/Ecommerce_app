const express = require('express');
const { register, updateStatus, getSellerTotalEarnings} = require('../controllers/sellerController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

// Public Routes
router.post('/register', register);
router.post('/updateStatus', updateStatus);
router.get('/analytics', getSellerTotalEarnings);


module.exports=router;