
const express = require('express');
const router = express.Router();
const ParkingZone = require('../models/ParkingZone');
const auth = require('../middleware/auth');

// Get all active parking zones
router.get('/parking-zones', auth, async (req, res) => {
  try {
    const parkingZones = await ParkingZone.find({ isActive: true });
    res.json(parkingZones);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch parking zones', details: error.message });
  }
});

module.exports = router;
