const app = require('./src/app');
const prisma = require('./src/config/prisma');

const PORT = process.env.PORT || 3000;

async function startServer() {
    try {
        await prisma.$connect();
        console.log('Connected to PostgreSQL database');

        app.listen(PORT, () => {
            console.log(`Server is running on http://localhost:${PORT}`);
        });
    } catch (error) {
        console.error('Unable to connect to the database:', error);
        process.exit(1);
    }
}

startServer();