const express = require('express');
const router = express.Router();
const ParkingZone = require('../../models/ParkingZone');
const adminAuth = require('../../middleware/adminAuth');

// Get all parking zones
router.get('/', adminAuth, async (req, res) => {
  try {
    const zones = await ParkingZone.find().sort({ name: 1 });
    const responseData = zones.map(zone => ({
        id: zone._id,
        name: zone.name,
        latitude: zone.latitude,
        longitude: zone.longitude,
        radius: zone.radius,
        is_active: zone.isActive,
    }));
    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch parking zones', details: error.message });
  }
});

// Create a new parking zone
router.post('/', adminAuth, async (req, res) => {
  try {
    const zone = new ParkingZone(req.body);
    await zone.save();
    const responseData = {
        id: zone._id,
        name: zone.name,
        latitude: zone.latitude,
        longitude: zone.longitude,
        radius: zone.radius,
        is_active: zone.isActive,
    };
    res.status(201).json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create parking zone', details: error.message });
  }
});

// Update a parking zone
router.put('/:id', adminAuth, async (req, res) => {
  try {
    const updatedZone = await ParkingZone.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedZone) {
        return res.status(404).json({ error: 'Parking zone not found' });
    }
    const responseData = {
        id: updatedZone._id,
        name: updatedZone.name,
        latitude: updatedZone.latitude,
        longitude: updatedZone.longitude,
        radius: updatedZone.radius,
        is_active: updatedZone.isActive,
    };
    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update parking zone', details: error.message });
  }
});

// Delete a parking zone
router.delete('/:id', adminAuth, async (req, res) => {
  try {
    await ParkingZone.findByIdAndDelete(req.params.id);
    res.json({ message: 'Parking zone deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete parking zone', details: error.message });
  }
});

module.exports = router;