const { placeOrder } = require('../models/orderModel');
const db = require('../config/db'); 

const handlePlaceOrder = async (req, res) => {
  try {
    //const userId = req.user.id; 
    const { userId,totalPrice, cart, address } = req.body;

    if (!userId || !totalPrice || !cart || cart.length === 0 || !address) {
      return res.status(400).json({ error: 'Missing fields or empty cart' });
    }

    const result = await placeOrder(userId, totalPrice, cart, address);
    return res.status(201).json({ message: 'Order placed', orderId: result.orderId });
  } catch (error) {
    console.error('Order placement failed:', error.message);
    return res.status(500).json({ error: error.message });
  }
};

// const getUserOrders = async (req, res) => {
//   const customerId = req.query.id;

//   try {
//     const [rows] = await db.query(`
//       (
//         SELECT 
//           o.id AS order_id,
//           o.customer_id,
//           o.total_amount,
//           o.commission,
//           o.created_at,
//           o.status AS order_status,
//           o.address,
//           p.id AS product_id,
//           p.name,
//           p.description,
//           p.price,
//           p.category,
//           p.created_at AS product_created_at,
//           p.images,
//           p.user_id AS seller_id,
//           oi.quantity,
//           oi.price_per_unit,
//           oi.status AS item_status
//         FROM orders o
//         LEFT JOIN order_items oi ON o.id = oi.order_id
//         LEFT JOIN products p ON oi.product_id = p.id
//         WHERE o.customer_id = ?
//       )
//       UNION
//       (
//         SELECT 
//           o.id AS order_id,
//           o.customer_id,
//           o.total_amount,
//           o.commission,
//           o.created_at,
//           o.status AS order_status,
//           o.address,
//           p.id AS product_id,
//           p.name,
//           p.description,
//           p.price,
//           p.category,
//           p.created_at AS product_created_at,
//           p.images,
//           p.user_id AS seller_id,
//           oih.quantity,
//           oih.price_per_unit,
//           oih.status AS item_status
//         FROM orders o
//         LEFT JOIN order_item_history oih ON o.id = oih.order_id AND oih.status = 'shipped'
//         LEFT JOIN products p ON oih.product_id = p.id
//         WHERE o.customer_id = ?
//       )
//     `, [customerId, customerId]);

//     // Group data by order
//     const ordersMap = {};

//     for (const row of rows) {
//       const orderId = row.order_id;

//       if (!ordersMap[orderId]) {
//         ordersMap[orderId] = {
//           id: orderId,
//           userId: row.customer_id, // This is the customer (not seller)
//           totalPrice: row.total_amount,
//           orderedAt: new Date(row.created_at).getTime(),
//           status: row.order_status,
//           address: row.address,
//           products: [],
//           quantity: []
//         };
//       }

//       if (row.product_id) {
//         const product = {
//           id: row.product_id,
//           name: row.name,
//           description: row.description,
//           price: row.price,
//           category: row.category,
//           createdAt: row.product_created_at,
//           images: row.images,
//           userId: row.seller_id, // This is sellerId in product
//         };

//         ordersMap[orderId].products.push(product);
//         ordersMap[orderId].quantity.push(row.quantity);
//       }
//     }

//     const orders = Object.values(ordersMap);
//     res.json(orders);
//   } catch (error) {
//     console.error('Error fetching user orders:', error);
//     res.status(500).json({ error: 'Internal Server Error' });
//   }
// };

const getUserOrders = async (req, res) => {
  const userId = req.query.id;
  const role = req.query.role;

  try {
    let rows;

    if (role === 'customer') {

      [rows] = await db.query(`
        (
          SELECT 
            o.id AS order_id,
            o.customer_id,
            o.total_amount,
            o.commission,
            o.created_at,
            o.status AS order_status,
            o.address,
            p.id AS product_id,
            p.name,
            p.description,
            p.price,
            p.category,
            p.created_at AS product_created_at,
            p.images,
            p.user_id AS seller_id,
            oi.quantity,
            oi.price_per_unit,
            oi.status AS item_status
          FROM orders o
          LEFT JOIN order_items oi ON o.id = oi.order_id
          LEFT JOIN products p ON oi.product_id = p.id
          WHERE o.customer_id = ?
        )
        UNION
        (
          SELECT 
            o.id AS order_id,
            o.customer_id,
            o.total_amount,
            o.commission,
            o.created_at,
            o.status AS order_status,
            o.address,
            p.id AS product_id,
            p.name,
            p.description,
            p.price,
            p.category,
            p.created_at AS product_created_at,
            p.images,
            p.user_id AS seller_id,
            oih.quantity,
            oih.price_per_unit,
            oih.status AS item_status
          FROM orders o
          LEFT JOIN order_item_history oih ON o.id = oih.order_id AND oih.status = 'shipped'
          LEFT JOIN products p ON oih.product_id = p.id
          WHERE o.customer_id = ?
        )
      `, [userId, userId]);

    } else if (role === 'seller') {
  
      [rows] = await db.query(`
        SELECT 
          o.id AS order_id,
          o.customer_id,
          o.total_amount,
          o.commission,
          o.created_at,
          o.status AS order_status,
          o.address,
          p.id AS product_id,
          p.name,
          p.description,
          p.price,
          p.category,
          p.created_at AS product_created_at,
          p.images,
          p.user_id AS seller_id,
          oi.quantity,
          oi.price_per_unit,
          oi.status AS item_status
        FROM order_items oi
        INNER JOIN products p ON oi.product_id = p.id
        INNER JOIN orders o ON oi.order_id = o.id
        WHERE p.user_id = ?
      `, [userId]);
    } else {
      return res.status(400).json({ error: 'Invalid role provided' });
    }

    const ordersMap = {};

    for (const row of rows) {
      const orderId = row.order_id;

      if (!ordersMap[orderId]) {
        ordersMap[orderId] = {
          id: orderId,
          userId: row.customer_id,
          totalPrice: row.total_amount,
          orderedAt: new Date(row.created_at).getTime(),
          status: row.order_status,
          address: row.address,
          products: [],
          quantity: [],
        };
      }

      if (row.product_id) {
        const product = {
          id: row.product_id,
          name: row.name,
          description: row.description,
          price: row.price,
          category: row.category,
          createdAt: row.product_created_at,
          images: row.images,
          userId: row.seller_id,
        };

        ordersMap[orderId].products.push(product);
        ordersMap[orderId].quantity.push(row.quantity);
      }
    }

    const orders = Object.values(ordersMap);
    res.status(200).json(orders);

  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};



module.exports = {
  handlePlaceOrder,
  getUserOrders
};
 
