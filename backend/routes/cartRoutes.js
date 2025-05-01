const express = require('express');
const router = express.Router();
const cartItemController = require('../controllers/cartController');

// Add item to cart
router.post('/add', cartItemController.addCartItem);

router.post('/delete', cartItemController.deleteCartItem);
router.post('/update', cartItemController.updateCartItemQuantity);
router.post('/deleteAll', cartItemController.deleteAllCartItemsForUser);


// Get all cart items for a customer
// router.get('/customer/:customerId', cartItemController.getCartItemsByCustomer);

// // Delete an item from cart
// router.delete('/delete/:id', cartItemController.deleteCartItem);

// // Update quantity of a cart item
// router.put('/updateQuantity/:id', cartItemController.updateCartItemQuantity);

module.exports = router;
 
