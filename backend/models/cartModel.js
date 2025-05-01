 
const db = require('../config/db'); 

const CartItem = {
  addCartItem: async (customerId, productId) => {
    const query = 'INSERT INTO cart_items (customer_id, product_id, quantity) VALUES (?, ?, ?)';
    return db.query(query, [customerId, productId, 1]);
  },

  getCartItemsByCustomer: async (customerId) => {
    const query = 'SELECT * FROM cart_items WHERE customer_id = ?';
    return db.query(query, [customerId]);
  },

  deleteCartItem: async (customerId,productId) => {
    const query = 'DELETE FROM cart_items WHERE customer_id = ? and product_id=?';
    db.query(query, [customerId,productId]);
  },

  updateQuantity: async (customerId,productId,direc) => {
    if (direc === 1) {
        const query = 'UPDATE cart_items SET quantity = quantity + 1 WHERE customer_id = ? and product_id=?';
        db.query(query, [customerId,productId]);
    } else {
        const query = 'UPDATE cart_items SET quantity = quantity - 1 WHERE customer_id = ? and product_id=?';
        db.query(query, [customerId,productId]);
    }
  },

  deleteAllByCustomerId: async (customerId) => {
    const [result] = await db.execute(
      'DELETE FROM cart_items WHERE customer_id = ?',
      [customerId]
    );
    return result;
  },
};

module.exports = CartItem;
