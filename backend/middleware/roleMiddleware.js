const jwt = require('jsonwebtoken');
const db = require('../config/db');

const verifySeller = async (req, res, next) => {
  try {
    const token = req.header('x-auth-token');
    if (!token) {
      return res.status(401).json({ message: 'Access Denied: No token provided' });
    }
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // decoded contains user id, email, etc.

    const [rows] = await db.execute('SELECT * FROM users WHERE id = ?', [decoded.id]);
    const user = rows[0];

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (user.role !== 'seller') {
      return res.status(403).json({ message: 'Access denied: Not a seller' });
    }

    next();
  } catch (error) {
    res.status(401).json({ message: 'Invalid or expired token', error });
  }
};

module.exports = verifySeller;
