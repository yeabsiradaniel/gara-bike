const mongoose = require('mongoose');
require('dotenv').config();

const collectionsToDrop = [
    'Bike', 'BikeReport', 'CorporateAccount', 'ParkingZone', 'Pass', 'Ride', 'SupportTicket', 'Transaction', 'UserPass', 'Wallet'
];

async function cleanupCollections() {
  try {
    await mongoose.connect(process.env.DATABASE_URL);
    console.log('Connected to MongoDB for cleanup.');

    const db = mongoose.connection.db;
    for (const collectionName of collectionsToDrop) {
        try {
            const result = await db.dropCollection(collectionName);
            if (result) {
                console.log(`Successfully dropped collection: ${collectionName}`);
            }
        } catch (error) {
            if (error.code === 26) { // NamespaceNotFound error
                console.log(`Collection not found, skipping: ${collectionName}`);
            } else {
                throw error;
            }
        }
    }

    console.log('Database cleanup complete!');

  } catch (error) {
    console.error('Cleanup failed:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB.');
  }
}

cleanupCollections();
