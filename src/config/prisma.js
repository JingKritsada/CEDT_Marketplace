const { PrismaClient } = require('@prisma/client');

// ใช้ตัวแปร global เพื่อเก็บ instance ของ Prisma ในโหมด development
// ป้องกันปัญหาสร้าง connection ใหม่ทุกครั้งที่ nodemon รีสตาร์ท
const prisma = global.prisma || new PrismaClient();

if (process.env.NODE_ENV !== 'production') global.prisma = prisma;

module.exports = prisma;