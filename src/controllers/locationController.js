const prisma = require('../config/prisma');

exports.getLocations = async (req, res) => {
    try {
        const locations = await prisma.pickupLocation.findMany({
            orderBy: { name: 'asc' }
        });
        res.status(200).json(locations);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch locations' });
    }
};