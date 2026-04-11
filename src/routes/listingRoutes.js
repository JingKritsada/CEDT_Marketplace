const express = require('express');
const router = express.Router();
const listingController = require('../controllers/listingController');
const authMiddleware = require('../middlewares/authMiddleware');

router.get('/', listingController.getListings);
router.post('/', authMiddleware, listingController.createListing);
router.get('/:id', listingController.getListingById);

module.exports = router;