const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');

// GET /categories - ดึงรายชื่อหมวดหมู่ทั้งหมด
router.get('/', categoryController.getCategories);

module.exports = router;