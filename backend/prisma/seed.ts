import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    console.log('🌱 Starting seeding...');

    // 1. Seed Categories (ใช้ upsert เพื่อป้องกันข้อมูลซ้ำถ้าเผลอรันหลายรอบ)
    const categories = [
        { name: 'Microcontrollers', slug: 'microcontrollers' },
        { name: 'Sensors', slug: 'sensors' },
        { name: 'Robotics Kits', slug: 'robotics-kits' },
        { name: 'PCBs', slug: 'pcbs' }
    ];

    for (const cat of categories) {
        await prisma.category.upsert({
            where: { slug: cat.slug },
            update: {},
            create: cat,
        });
    }
    console.log('✅ Categories seeded');

    // 2. Seed Pickup Locations
    const locations = [
        { name: 'Larn Gear', building: 'Engineering Building 3', description: 'Under the red roof' },
        { name: 'Library', building: 'Engineering Building 100 Years', description: '1st floor entrance' }
    ];

    for (const loc of locations) {
        // สำหรับ Location เราเช็คด้วยชื่อก่อนเพื่อไม่ให้เกิดข้อมูลซ้ำ (เพราะ ID เป็น UUID)
        const existingLoc = await prisma.pickupLocation.findFirst({
            where: { name: loc.name }
        });

        if (!existingLoc) {
            await prisma.pickupLocation.create({ data: loc });
        }
    }
    console.log('✅ Pickup Locations seeded');

    console.log('🚀 Seed data inserted successfully!');
}

main()
    .catch((e) => {
        console.error('❌ Seeding error:', e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });