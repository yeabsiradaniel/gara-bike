const mongoose = require('mongoose');
require('dotenv').config();

async function listCollections() {
  try {
    await mongoose.connect(process.env.DATABASE_URL);
    console.log('Connected to MongoDB.');

    const collections = await mongoose.connection.db.listCollections().toArray();
    const collectionNames = collections.map(c => c.name);
    console.log('Found collections:', collectionNames);

  } catch (error) {
    console.error('Failed to list collections:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB.');
  }
}

listCollections();
