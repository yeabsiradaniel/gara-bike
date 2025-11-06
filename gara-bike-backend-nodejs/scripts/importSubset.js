const mongoose = require('mongoose');
const fs = require('fs');
require('dotenv').config();

const Bike = require('../models/Bike');
const ParkingZone = require('../models/ParkingZone');

const migrationData = JSON.parse(fs.readFileSync('../gara-bike-backend/migration_subset.json', 'utf-8'));

async function importData() {
  try {
    await mongoose.connect(process.env.DATABASE_URL);
    console.log('Connected to MongoDB for import.');

    // Clear existing data
    await Bike.deleteMany({});
    await ParkingZone.deleteMany({});
    console.log('Cleared existing Bikes and Parking Zones.');

    // Import Parking Zones
    if (migrationData.parking_zones && migrationData.parking_zones.length > 0) {
        const parkingZonesToImport = migrationData.parking_zones.map(pz => ({
            name: pz.name,
            latitude: parseFloat(pz.latitude),
            longitude: parseFloat(pz.longitude),
            radius: pz.radius,
            isActive: pz.is_active
        }));
        await ParkingZone.insertMany(parkingZonesToImport);
        console.log(`Imported ${parkingZonesToImport.length} parking zones.`);
    }

    // Import Bikes
    if (migrationData.bikes && migrationData.bikes.length > 0) {
        const bikesToImport = migrationData.bikes.map(bike => ({
            qrCode: bike.qr_code,
            status: bike.status,
            batteryLevel: bike.battery_level,
            lastReportedAt: bike.last_reported_at,
            location: {
              type: 'Point',
              coordinates: [parseFloat(bike.longitude), parseFloat(bike.latitude)]
            }
        }));
        await Bike.insertMany(bikesToImport);
        console.log(`Imported ${bikesToImport.length} bikes.`);
    }

    console.log('Data migration successful!');

  } catch (error) {
    console.error('Migration failed:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB.');
  }
}

importData();
