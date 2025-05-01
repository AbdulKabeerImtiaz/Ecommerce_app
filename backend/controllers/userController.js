const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { registerUser, findUserByEmail,findUserById,addAddress } = require('../models/userModel');
const db = require('../config/db'); 
// const CartItem = require('../models/cartModel');

// Register a new user
const register = async (req, res) => {
    console.log(req.body)
    try {
        const { name, email, password } = req.body;
        const existingUser = await findUserByEmail(email);
        if (existingUser) {
            return res.status(400).json({ message: "User already exists" });
        }

        await registerUser(name, email, password);
        res.status(201).json({ message: "User registered successfully" });

    } catch (error) {
        res.status(500).json({ message: "Server error", error });
    }
};

// User Login
const login = async (req, res) => {
    try {
        console.log(req.body)
        const { email, password } = req.body;

        const user = await findUserByEmail(email); 
        console.log(user.password)
        if (!user) {
            return res.status(400).json({ message: "Invalid email or password" });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ message: "Invalid email or password" });
        }

        const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET, {
            expiresIn: "1h"
        });
        if (user.role==='customer') {
            //CartItem.getCartItemsByCustomer()
            const [items] = await db.execute('SELECT * FROM cart_items');
        
            const userCart = items
              .filter(cart_item => cart_item.customer_id === user.id) 
              .map(cart_item => ({
                id: cart_item.id,
                customerId: cart_item.customer_id,
                productId: cart_item.product_id,
                quantity: cart_item.quantity,
              }));

              res.status(200).json({
                token,
                user: {
                  id: user.id,
                  name: user.name,
                  email: user.email,
                  role: user.role,
                  cart: userCart  
                }
              });
        }else{
            res.status(200).json({ token, user: { id: user.id, name: user.name, email: user.email, role: user.role } });
        }
        // const [items] = await db.execute('SELECT * FROM cart_items');
        
        //     const userCart = items
        //       .filter(cart_item => cart_item.customer_id === user.id) 
        //       .map(cart_item => ({
        //         id: cart_item.id,
        //         customerId: cart_item.customer_id,
        //         productId: cart_item.product_id,
        //         quantity: cart_item.quantity,
        //       }));
        
        //     // res.status(200).json({
        //     //     ...user,
        //     //     cart: userCart  
        //     // });

    } catch (error) {
        res.status(500).json({ message: "Server error", error: error.message });
    }
};

const addUserAddress=async (req,res)=>{
    try {
        const { id, address } = req.body;

        const result = await addAddress(id,address);
        if (result.affectedRows === 0) {
            return res.status(404).json({ msg: 'User not found' });
        }
        const user = await findUserById(id); 
        if (!user) {
            return res.status(400).json({ message: "No User with such Id" });
        }
        res.status(200).json(user);

    } catch (error) {
        res.status(500).json({ message: "Server error", error });
    }
}

module.exports = { register, login,addUserAddress };


