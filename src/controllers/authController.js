const prisma = require('../config/prisma');
const jwt = require('jsonwebtoken');

exports.login = async (req, res) => {
    try {
        const { studentId, email, displayName } = req.body;

        let user = await prisma.user.upsert({
            where: { email },
            update: { displayName },
            create: { studentId, email, displayName },
        });

        const accessToken = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '15m' });
        const refreshToken = jwt.sign({ userId: user.id }, process.env.JWT_REFRESH_SECRET, { expiresIn: '7d' });

        res.status(200).json({
            message: 'Login successful',
            user,
            accessToken,
            refreshToken
        });
    } catch (error) {
        console.error('Auth Error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.refresh = async (req, res) => {
    try {
        const { refreshToken } = req.body;

        if (!refreshToken) {
            return res.status(401).json({ error: 'Refresh token is required' });
        }

        jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET, (err, decoded) => {
            if (err) {
                return res.status(403).json({ error: 'Invalid or expired refresh token' });
            }

            const accessToken = jwt.sign(
                { userId: decoded.userId },
                process.env.JWT_SECRET,
                { expiresIn: '15m' }
            );

            res.status(200).json({ accessToken });
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Internal server error' });
    }
};