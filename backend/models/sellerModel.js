const db = require('../config/db');
const bcrypt = require('bcryptjs');

const registerUserSeller = async (name, email, password,role) => {
    const hashedPassword = await bcrypt.hash(password, 10); 
    const query = `INSERT INTO users (name, email, password,role) VALUES (?, ?, ?, ?)`;
    return db.execute(query, [name, email, hashedPassword,role]);
};

  const seller_storeName= async (seller_id,storeName) => {
    const [result]=await db.execute(`INSERT INTO seller_stores(seller_id,store_name) VALUES (?,?)`,[seller_id,storeName]);
    return result;
  };

const findUserByEmail = async (email) => {
    const query = `SELECT * FROM users WHERE email = ?`;
    const [rows] = await db.execute(query, [email]);
    return rows[0];
};

const findUserByID = async (email) => {
    const query = `SELECT id FROM users WHERE email = ?`;
    const [rows] = await db.execute(query, [email]);
    return rows.length > 0 ? rows[0].id : null;
};

const updateOrderItemStatus = async (orderId, productId, status) => {
  const query = `
    UPDATE order_items
    SET status = ?
    WHERE order_id = ? AND product_id = ?
  `;

  await db.execute(query, [status, orderId, productId]);
};

// const getSellerEarnings = async (sellerId, category = null) => {
//   let query = `
//     SELECT SUM(total_earning) AS total FROM (
//       -- Earnings from current order_items
//       SELECT (oi.quantity * oi.price_per_uni) AS total_earning
//       FROM order_items oi
//       JOIN products p ON oi.product_id = p.id
//       WHERE p.user_id = ?
//       ${category ? 'AND p.category = ?' : ''}

//       UNION ALL

//       -- Earnings from archived order_item_history
//       SELECT (oih.quantity * oih.price_per_uni) AS total_earning
//       FROM order_item_history oih
//       JOIN products p ON oih.product_id = p.id
//       WHERE oih.seller_id = ?
//       ${category ? 'AND p.category = ?' : ''}
//     ) AS combined;
//   `;

//   const values = category
//     ? [sellerId, category, sellerId, category]
//     : [sellerId, sellerId];

//   const [rows] = await db.execute(query, values);
//   return rows[0].total || 0;
// };

const CATEGORIES = ['Mobiles', 'Essentials', 'Books', 'Appliances', 'Fashion'];

const getSellerEarnings = async (sellerId) => {
  const earnings = {
    totalEarnings: 0,
    mobileEarnings: 0,
    essentialEarnings: 0,
    booksEarnings: 0,
    applianceEarnings: 0,
    fashionEarnings: 0,
  };

  const totalQuery = `
    SELECT SUM(total_earning) AS total FROM (
      SELECT (oi.quantity * oi.price_per_unit) AS total_earning
      FROM order_items oi
      JOIN products p ON oi.product_id = p.id
      WHERE p.user_id = ?

      UNION ALL

      SELECT (oih.quantity * oih.price_per_unit) AS total_earning
      FROM order_item_history oih
      JOIN products p ON oih.product_id = p.id
      WHERE oih.seller_id = ?
    ) AS combined;
  `;

  const [totalResult] = await db.execute(totalQuery, [sellerId, sellerId]);
  earnings.totalEarnings = totalResult[0].total || 0;

  for (const category of CATEGORIES) {
    const categoryQuery = `
      SELECT SUM(total_earning) AS total FROM (
        SELECT (oi.quantity * oi.price_per_unit) AS total_earning
        FROM order_items oi
        JOIN products p ON oi.product_id = p.id
        WHERE p.user_id = ? AND p.category = ?

        UNION ALL

        SELECT (oih.quantity * oih.price_per_unit) AS total_earning
        FROM order_item_history oih
        JOIN products p ON oih.product_id = p.id
        WHERE oih.seller_id = ? AND p.category = ?
      ) AS category_combined;
    `;
    const [categoryResult] = await db.execute(categoryQuery, [sellerId, category, sellerId, category]);
    const total = categoryResult[0].total || 0;

    if (category === 'Mobiles') earnings.mobileEarnings = total;
    else if (category === 'Essentials') earnings.essentialEarnings = total;
    else if (category === 'Books') earnings.booksEarnings = total;
    else if (category === 'Appliances') earnings.applianceEarnings = total;
    else if (category === 'Fashion') earnings.fashionEarnings = total;
  }

  return earnings;
};


module.exports = { registerUserSeller, findUserByEmail, findUserByID, seller_storeName, updateOrderItemStatus,getSellerEarnings};
