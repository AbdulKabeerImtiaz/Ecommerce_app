const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { registerUserSeller, findUserByEmail, findUserByID, seller_storeName,updateOrderItemStatus,getSellerEarnings} = require('../models/sellerModel');

// Register a new user
const register = async (req, res) => {
    try {
        const { name, email, password,role,storeName} = req.body;
        const existingUser = await findUserByEmail(email);
        if (existingUser) {
            return res.status(400).json({ message: "Seller already exists" });
        }

        const sellerRegistered=await registerUserSeller(name, email, password,role);
        if (!sellerRegistered) {
            return res.status(400).json({ message: "Seller didn't get registered" });
        }

        const seller_id = await findUserByID(email);
        if (!seller_id) {
            return res.status(400).json({ message: "Failed to retrieve seller ID" });
        }

        await seller_storeName(seller_id,storeName);
        res.status(201).json({ message: "Seller registered successfully" });

    } catch (error) {
        //res.status(500).json({ message: "Server error", error });
        res.status(500).json({ message: error.message || "Server error" });
    }
};

const updateStatus = async (req, res) => {
    try {
      const { orderId, productId, status } = req.body;
  
      if (!orderId || !productId || !status) {
        return res.status(400).json({ message: 'Missing required fields' });
      }
  
      await updateOrderItemStatus(orderId, productId, status);
      res.status(200).json({ message: 'Order item status updated successfully' });
    } catch (error) {
      console.error('Error updating order item status:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  };

  const getSellerTotalEarnings = async (req, res) => {
    try {
      const sellerId = req.query.sellerId;
    //   const category = req.query.category; // optional
      if (!sellerId) {
        return res.status(400).json({ message: 'Missing sellerId' });
      }
  
      const earnings = await getSellerEarnings(sellerId);
      res.status(200).json({ sellerId, totalEarnings: earnings });
    } catch (err) {
      console.error('Earnings fetch error:', err);
      res.status(500).json({ message: 'Server error while fetching earnings' });
    }
  };  

module.exports = { register,updateStatus,getSellerTotalEarnings};


