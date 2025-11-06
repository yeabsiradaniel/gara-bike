
const express = require('express');
const router = express.Router();
const BikeReport = require('../models/BikeReport');
const Bike = require('../models/Bike');
const auth = require('../middleware/auth');

// Create a bike report
router.post('/bike-reports', auth, async (req, res) => {
  const { bikeId, reportType, comments } = req.body;
  const { userId } = req.userData;

  try {
    const bikeReport = new BikeReport({
      bike: bikeId,
      user: userId,
      reportType,
      comments,
    });
    await bikeReport.save();

    // Optionally, update the bike status to 'MAINTENANCE'
    await Bike.findByIdAndUpdate(bikeId, { status: 'MAINTENANCE' });

    res.status(201).json(bikeReport);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create bike report', details: error.message });
  }
});

module.exports = router;
