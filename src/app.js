const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();

// Middlewares พื้นฐาน
app.use(cors());
app.use(express.json()); // สำหรับอ่าน Body ที่เป็น JSON

// Health Check Route สำหรับทดสอบว่า Server รันติดไหม
app.get('/', (req, res) => {
    res.status(200).json({ message: 'CEDT Marketplace API is running!' });
});

module.exports = app;