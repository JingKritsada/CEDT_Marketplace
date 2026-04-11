const express = require('express');
const router = express.Router();
const listingController = require('../controllers/listingController');
const authMiddleware = require('../middlewares/authMiddleware');

router.get('/', listingController.getListings);
router.post('/', authMiddleware, listingController.createListing);
router.get('/search', listingController.searchListings);
router.get('/:id', listingController.getListingById);

router.patch('/:id', authMiddleware, listingController.updateListing);
router.delete('/:id', authMiddleware, listingController.deleteListing);

module.exports = router;