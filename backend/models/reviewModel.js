const db = require('../config/db');

const createReview = async (customer_id, product_id, rating, comment) => {
  const [result] = await db.execute(
    `INSERT INTO reviews (customer_id, product_id, rating, comment)
     VALUES (?, ?, ?, ?)`,
    [customer_id, product_id, rating, comment]
  );
  return result;
};

// const updateReview = async (customer_id, product_id, rating, comment) => {
//   const [result] = await db.execute(
//     `UPDATE reviews
//      SET rating = ?, comment = ?, created_at = NOW()
//      WHERE customer_id = ? AND product_id = ?`,
//     [rating, comment, customer_id, product_id]
//   );
//   return result;
// };

const findReview = async (customer_id, product_id) => {
  const [rows] = await db.execute(
    `SELECT * FROM reviews
     WHERE customer_id = ? AND product_id = ?`,
    [customer_id, product_id]
  );
  return rows[0];
};

module.exports = {
  createReview,
  findReview,
};
