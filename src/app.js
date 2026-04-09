const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();

const authRoutes = require('./routes/authRoutes');
const listingRoutes = require('./routes/listingRoutes');
const categoryRoutes = require('./routes/categoryRoutes');

// Middlewares พื้นฐาน
app.use(cors());
app.use(express.json());

app.use('/auth', authRoutes);
app.use('/listings', listingRoutes);
app.use('/categories', categoryRoutes);

app.get('/', (req, res) => {
    res.status(200).json({ message: 'CEDT Marketplace API is running!' });
});

module.exports = app;