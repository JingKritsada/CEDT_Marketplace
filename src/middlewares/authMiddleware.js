const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // รูปแบบ "Bearer <token>"

    if (!token) return res.status(401).json({ error: 'Access denied. No token provided.' });

    try {
        const verified = jwt.verify(token, process.env.JWT_SECRET);
        req.user = verified; // เก็บข้อมูล user ไว้ใน request เพื่อใช้ในลำดับถัดไป
        next();
    } catch (error) {
        res.status(403).json({ error: 'Invalid or expired token' });
    }
};