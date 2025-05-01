const express = require('express');
const { register, login, addUserAddress } = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

// Public Routes
router.post('/register', register);
router.post('/login', login);

// Protected Route (Only accessible with a valid JWT token)
router.get('/profile', authMiddleware, (req, res) => {
    res.json({ message: "Welcome to your profile!", user: req.user });
});

router.post("/tokenIsValid",async (req,res)=>{
    try {
        const token=req.header('x-auth-token');
        if(!token)return res.json(false);
        const verified=jwt.verify(token,'passwordKey');
        if(!verified) return res.json(false);

        const user=await User.findById(verified.id);
        if(!user) return res.json(false);
        res.json(true);
    } catch (e) {
        res.status(500).json({error:e.message});
    }
})

// router.get('/',authMiddleware, async(req,res)=>{
//     const user=await User.findById(req.user);
//     res.json({...user._doc, token: req.token});
// });

router.get('/', authMiddleware, async (req, res) => {
    try {
      const userId = req.user; 
      const [rows] = await db.execute('SELECT * FROM users WHERE id = ?', [userId]);
  
      if (rows.length === 0) {
        return res.status(404).json({ error: 'User not found' });
      }
  
      const user = rows[0];
      res.json({ ...user, token: req.token });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });

  router.post('/addAddress', addUserAddress);

module.exports = router;

