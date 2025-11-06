const express = require('express');
const router = express.Router();
const Bike = require('../../models/Bike');
const adminAuth = require('../../middleware/adminAuth');

// Get all bikes
router.get('/', adminAuth, async (req, res) => {
  try {
    const bikes = await Bike.find().sort({ createdAt: -1 });
    const responseData = bikes.map(bike => ({
        id: bike._id,
        qr_code: bike.qrCode,
        status: bike.status,
        latitude: bike.location ? bike.location.coordinates[1] : null,
        longitude: bike.location ? bike.location.coordinates[0] : null,
        battery_level: bike.batteryLevel,
        last_reported_at: bike.updatedAt ? bike.updatedAt.toISOString() : null, // Assuming updatedAt is last_reported_at
    }));
    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch bikes', details: error.message });
  }
});

// Create a new bike
router.post('/', adminAuth, async (req, res) => {
  try {
    const { latitude, longitude, ...bikeData } = req.body;
    if (latitude && longitude) {
        bikeData.location = { type: 'Point', coordinates: [longitude, latitude] };
    }
    const bike = new Bike(bikeData);
    await bike.save();
    const responseData = {
        id: bike._id,
        qr_code: bike.qrCode,
        status: bike.status,
        latitude: bike.location ? bike.location.coordinates[1] : null,
        longitude: bike.location ? bike.location.coordinates[0] : null,
        battery_level: bike.batteryLevel,
        last_reported_at: bike.updatedAt ? bike.updatedAt.toISOString() : null,
    };
    res.status(201).json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create bike', details: error.message });
  }
});

// Update a bike
router.put('/:id', adminAuth, async (req, res) => {
  try {
    const { latitude, longitude, ...bikeData } = req.body;
    if (latitude && longitude) {
        bikeData.location = { type: 'Point', coordinates: [longitude, latitude] };
    }
    const updatedBike = await Bike.findByIdAndUpdate(req.params.id, bikeData, { new: true });
    if (!updatedBike) {
        return res.status(404).json({ error: 'Bike not found' });
    }
    const responseData = {
        id: updatedBike._id,
        qr_code: updatedBike.qrCode,
        status: updatedBike.status,
        latitude: updatedBike.location ? updatedBike.location.coordinates[1] : null,
        longitude: updatedBike.location ? updatedBike.location.coordinates[0] : null,
        battery_level: updatedBike.batteryLevel,
        last_reported_at: updatedBike.updatedAt ? updatedBike.updatedAt.toISOString() : null,
    };
    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update bike', details: error.message });
  }
});

// Delete a bike
router.delete('/:id', adminAuth, async (req, res) => {
  try {
    await Bike.findByIdAndDelete(req.params.id);
    res.json({ message: 'Bike deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete bike', details: error.message });
  }
});

module.exports = router;