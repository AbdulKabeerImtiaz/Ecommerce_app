 
// const jwt = require('jsonwebtoken');

// const authMiddleware = (req, res, next) => {
//     const token = req.header("Authorization");

//     if (!token) {
//         return res.status(401).json({ message: "Access Denied. No Token Provided." });
//     }

//     try {
//         const decoded = jwt.verify(token, process.env.JWT_SECRET);
//         req.user = decoded;
//         next();
//     } catch (error) {
//         res.status(400).json({ message: "Invalid Token" });
//     }
// };

// module.exports = authMiddleware;



// const authMiddleware = (req, res, next) => {
//     const authHeader = req.header("Authorization");

//     if (!authHeader) {
//         return res.status(401).json({ message: "Access Denied. No Token Provided." });
//     }

//     const token = authHeader.split(" ")[1]; 

//     if (!token) {
//         return res.status(401).json({ message: "Access Denied. Malformed Token." });
//     }

//     try {
//         const decoded = jwt.verify(token, process.env.JWT_SECRET);
//         req.user = decoded;
//         next();
//     } catch (error) {
//         res.status(400).json({ message: "Invalid Token" });
//     }
// };

const jwt = require('jsonwebtoken');

const authMiddleware = async (req, res, next) => {
    try {
        const token = req.header('x-auth-token');  
        if (!token) return res.status(401).json({ msg: "No auth token, access denied" });

        const verified = jwt.verify(token, process.env.JWT_SECRET);
        if (!verified) return res.status(401).json({ msg: "Token verification failed, authorization denied" });

        req.user = verified.id;
        req.token = token;
        next();
    } catch (err) {
        res.status(500).json({ error: err.message });  
    }
};

module.exports = authMiddleware;

