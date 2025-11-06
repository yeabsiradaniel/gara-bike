
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const fs = require('fs');
const path = require('path');

async function main() {
  const bikesFilePath = path.join(__dirname, '../../gara-bike-backend/bikes.json');
  const parkingZonesFilePath = path.join(__dirname, '../../gara-bike-backend/parking_zones.json');

  const bikesData = JSON.parse(fs.readFileSync(bikesFilePath, 'utf-8'));
  const parkingZonesData = JSON.parse(fs.readFileSync(parkingZonesFilePath, 'utf-8'));

  for (const bike of bikesData) {
    await prisma.bike.create({
      data: {
        qrCode: bike.fields.qr_code,
        status: bike.fields.status,
        latitude: bike.fields.latitude,
        longitude: bike.fields.longitude,
        batteryLevel: bike.fields.battery_level,
      },
    });
  }

  for (const zone of parkingZonesData) {
    await prisma.parkingZone.create({
      data: {
        name: zone.fields.name,
        latitude: zone.fields.latitude,
        longitude: zone.fields.longitude,
        radius: zone.fields.radius,
        isActive: zone.fields.is_active,
      },
    });
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
