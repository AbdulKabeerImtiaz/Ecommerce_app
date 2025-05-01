const db = require('../config/db');
const bcrypt = require('bcryptjs');

const registerUser = async (name, email, password) => {
    const hashedPassword = await bcrypt.hash(password, 10); 
    const query = `INSERT INTO users (name, email, password) VALUES (?, ?, ?)`;
    return db.execute(query, [name, email, hashedPassword]);
};

const findUserByEmail = async (email) => {
    const query = `SELECT * FROM users WHERE email = ?`;
    const [rows] = await db.execute(query, [email]);
    return rows[0];
};

const findUserById = async (id) => {
    const query = `SELECT * FROM users WHERE id = ?`;
    const [rows] = await db.execute(query, [id]);
    return rows[0];
};

const addAddress = async (id,address) => {
    const query = `UPDATE users SET address=? where id=?`;
    const [result] = await db.execute(query, [address,id]);

    return result;
};


module.exports = { registerUser, findUserByEmail,findUserById,addAddress };

