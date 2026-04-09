const prisma = require('../config/prisma');

// ดึงรายการสินค้าทั้งหมด พร้อมระบบ Filter
exports.getListings = async (req, res) => {
    try {
        const { categoryId, courseCode, status } = req.query; // รับค่าจาก Query Params

        const listings = await prisma.listing.findMany({
            where: {
                AND: [
                    categoryId ? { categoryId } : {},
                    courseCode ? { courseCode } : {},
                    status ? { status } : {}
                ]
            },
            include: {
                category: true,
                seller: {
                    select: { displayName: true, avatarUrl: true }
                },
                pickupLocation: true
            },
            orderBy: { createdAt: 'desc' }
        });

        res.status(200).json(listings);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed to fetch listings' });
    }
};

// เพิ่มฟีเจอร์ลงขายสินค้า (ต้องใช้ Auth)
exports.createListing = async (req, res) => {
    try {
        const { title, description, price, isFree, categoryId, courseCode, pickupLocationId, images } = req.body;
        const sellerId = req.user.userId; // ได้มาจาก authMiddleware

        const newListing = await prisma.listing.create({
            data: {
                title,
                description,
                price: parseFloat(price),
                isFree,
                courseCode,
                images,
                sellerId,
                categoryId,
                pickupLocationId
            }
        });

        res.status(201).json(newListing);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed to create listing' });
    }
};