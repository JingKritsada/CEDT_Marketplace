const express = require('express');
const router = express.Router();
const listingController = require('../controllers/listingController');
const authMiddleware = require('../middlewares/authMiddleware'); // ดึง Middleware ตรวจ Token มาใช้

router.post('/', authMiddleware, listingController.getListings);
router.post('/', authMiddleware, listingController.createListing);

module.exports = router;