const db = require('../config/db'); 

const placeOrder = async (userId,totalPrice, cart,address) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const [orderResult] = await connection.query(
      `INSERT INTO orders (customer_id, total_amount, commission,address) VALUES (?, ?, ?, ?)`,
      [userId, totalPrice, totalPrice * 0.1,address] // 10% commission
    );

    const orderId = orderResult.insertId;

    for (const item of cart) {
      const [productResult] = await connection.query(
        `SELECT price, quantity FROM products WHERE id = ? FOR UPDATE`,
        [item.productId]
      );

      if (productResult.length === 0) {
        throw new Error(`Product with ID ${item.productId} not found`);
      }

      const product = productResult[0];

      if (product.quantity < item.quantity) {
        throw new Error(`Insufficient stock for product ID ${item.productId}`);
      }

      await connection.query(
        `INSERT INTO order_items (order_id, product_id, quantity, price_per_unit) VALUES (?, ?, ?, ?)`,
        [orderId, item.productId, item.quantity, product.price]
      );

      await connection.query(
        `UPDATE products SET quantity = quantity - ? WHERE id = ?`,
        [item.quantity, item.productId]
      );
    }

    await connection.commit();
    return { success: true, orderId };
  } catch (err) {
    await connection.rollback();
    throw err;
  } finally {
    connection.release();
  }
};

module.exports = {
  placeOrder,
};

