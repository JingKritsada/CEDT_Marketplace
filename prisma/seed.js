const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    // สร้างหมวดหมู่สินค้า
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

    // สร้างจุดนัดรับภายในคณะ
    const locations = [
        { name: 'Larn Gear', building: 'Engineering Building 3', description: 'Under the red roof' },
        { name: 'Library', building: 'Engineering Building 100 Years', description: '1st floor entrance' }
    ];

    for (const loc of locations) {
        await prisma.pickupLocation.create({ data: loc });
    }

    console.log('Seed data inserted successfully!');
}

main()
    .catch((e) => { console.error(e); process.exit(1); })
    .finally(async () => { await prisma.$disconnect(); });