const CartItem = require('../models/cartModel');
const db = require('../config/db'); 

// exports.addCartItem = (req, res) => {
//   const { customerId, productId, quantity } = req.body;

//   if (!customerId || !productId || !quantity) {
//     return res.status(400).json({ message: 'All fields are required.' });
//   }

//   CartItem.addCartItem(customerId, productId, quantity, (err, result) => {
//     if (err) {
//       console.error('Error adding cart item:', err);
//       return res.status(500).json({ message: 'Database error.' });
//     }
//     res.status(201).json({ message: 'Cart item added successfully!', cartItemId: result.insertId });
//   });
// };

exports.addCartItem = async (req, res) => {
    const { customerId, productId} = req.body;
    console.log('Request body:', req.body);

  
    if (!customerId || !productId) {
        console.log(`customer id: ${customerId}`);
        console.log(`product id: ${productId}`);
      return res.status(400).json({ message: 'All fields are required.' });
    }
  
    try {
      const [existingRows] = await db.execute(
        'SELECT * FROM cart_items WHERE customer_id = ? AND product_id = ?',
        [customerId, productId]
    );

    if (existingRows.length > 0) {
        // Product exists in cart → increase quantity by 1
        await db.execute(
            'UPDATE cart_items SET quantity = quantity + 1 WHERE customer_id = ? AND product_id = ?',
            [customerId, productId]
        );
    } else {
        // // Product not in cart → insert new row with quantity = 1
        // await db.execute(
        //     'INSERT INTO cart_items (customer_id, product_id, quantity) VALUES (?, ?, ?)',
        //     [customerId, productId, 1]
        // );
        const [result]=await CartItem.addCartItem(customerId, productId);
    }

      const [userRows] = await db.execute('SELECT * FROM users WHERE id = ?', [customerId]);
      if (userRows.length === 0) {
        return res.status(404).json({ message: 'User not found.' });
      }
  
      const user = userRows[0];
  
      // 3. Get updated cart items
      //const [cartRows] = await db.execute('SELECT * FROM cart_items WHERE customer_id = ?', [customerId]);
      const [cartRows] = await CartItem.getCartItemsByCustomer(customerId);

      const cart = cartRows.map(item => ({
        id: item.id,
        customerId: item.customer_id,
        productId: item.product_id,
        quantity: item.quantity,
      }));
  
      // 4. Return full user object with updated cart
      res.status(200).json({
        message: 'Cart item added successfully!',
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          address: user.address,
          createdAt: user.created_at,
          type: user.type,
          cart,
        },
      });
    } catch (err) {
      console.error('Error adding cart item:', err);
      res.status(500).json({ message: 'Server error', error: err });
    }
  };

exports.getCartItemsByCustomer = (req, res) => {
  const { customerId } = req.params;

  CartItem.getCartItemsByCustomer(customerId, (err, results) => {
    if (err) {
      console.error('Error fetching cart items:', err);
      return res.status(500).json({ message: 'Database error.' });
    }
    res.json(results);
  });
};

exports.deleteCartItem = async (req, res) => {
    const { customerId, productId} = req.body;
    if (!customerId || !productId) {
        console.log(`customer id: ${customerId}`);
        console.log(`product id: ${productId}`);
      return res.status(400).json({ message: 'All fields are required.' });
    }
  
    try {
    CartItem.deleteCartItem(customerId, productId);
    // 2. Get user info
    const [userRows] = await db.execute('SELECT * FROM users WHERE id = ?', [customerId]);
    if (userRows.length === 0) {
      return res.status(404).json({ message: 'User not found.' });
    }

    const user = userRows[0];

    // 3. Get updated cart items
    //const [cartRows] = await db.execute('SELECT * FROM cart_items WHERE customer_id = ?', [customerId]);
    const [cartRows] = await CartItem.getCartItemsByCustomer(customerId);

    const cart = cartRows.map(item => ({
      id: item.id,
      customerId: item.customer_id,
      productId: item.product_id,
      quantity: item.quantity,
    }));

    // 4. Return full user object with updated cart
    res.status(200).json({
      message: 'Cart item deleted successfully!',
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        address: user.address,
        createdAt: user.created_at,
        type: user.type,
        cart,
      },
    });
  } catch (err) {
    console.error('Error deleting cart item:', err);
    res.status(500).json({ message: 'Server error', error: err });
  }
};

exports.updateCartItemQuantity = async (req, res) => {
    const { customerId, productId,direc} = req.body;
    if (!customerId || !productId || !direc) {
        console.log(`customer id: ${customerId}`);
        console.log(`product id: ${productId}`);
      return res.status(400).json({ message: 'All fields are required.' });
    }
  
    try {
    CartItem.updateQuantity(customerId, productId,direc);
    // 2. Get user info
    const [userRows] = await db.execute('SELECT * FROM users WHERE id = ?', [customerId]);
    if (userRows.length === 0) {
      return res.status(404).json({ message: 'User not found.' });
    }

    const user = userRows[0];

    // 3. Get updated cart items
    //const [cartRows] = await db.execute('SELECT * FROM cart_items WHERE customer_id = ?', [customerId]);
    const [cartRows] = await CartItem.getCartItemsByCustomer(customerId);

    const cart = cartRows.map(item => ({
      id: item.id,
      customerId: item.customer_id,
      productId: item.product_id,
      quantity: item.quantity,
    }));

    // 4. Return full user object with updated cart
    res.status(200).json({
      message: 'Cart item updated successfully!',
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        address: user.address,
        createdAt: user.created_at,
        type: user.type,
        cart,
      },
    });
  } catch (err) {
    console.error('Error updating cart item:', err);
    res.status(500).json({ message: 'Server error', error: err });
  }
};
 
// exports.updateCartItemQuantity = (req, res) => {
//     const { id } = req.params;
//     const { quantity } = req.body;
  
//     if (!quantity) {
//       return res.status(400).json({ message: 'Quantity is required.' });
//     }
  
//     CartItem.updateCartItemQuantity(id, quantity, (err, result) => {
//       if (err) {
//         console.error('Error updating cart item quantity:', err);
//         return res.status(500).json({ message: 'Database error.' });
//       }
//       res.json({ message: 'Cart item quantity updated successfully!' });
//     });
//   };

exports.deleteAllCartItemsForUser = async (req, res) => {
  const { customerId } = req.body;

  if (!customerId) {
    return res.status(400).json({ message: 'Customer ID is required' });
  }

  try {
    const result = await CartItem.deleteAllByCustomerId(customerId);

    res.status(200).json({
      message: 'All cart items deleted successfully',
      deletedRows: result.affectedRows,
    });
  } catch (error) {
    console.error('Error deleting cart items:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};
