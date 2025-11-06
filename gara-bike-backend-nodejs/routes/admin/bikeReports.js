const express = require('express');
const router = express.Router();
const BikeReport = require('../../models/BikeReport');
const adminAuth = require('../../middleware/adminAuth');

// Get all bike reports
router.get('/admin/bikereports', adminAuth, async (req, res) => {
  try {
    const reports = await BikeReport.find().populate('user', 'email').populate('bike', 'qrCode');
    res.json(reports);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch bike reports', details: error.message });
  }
});

// Update a bike report
router.patch('/admin/bikereports/:id', adminAuth, async (req, res) => {
    const { id } = req.params;
    const { isResolved } = req.body;
  
    try {
      const report = await BikeReport.findByIdAndUpdate(id, { isResolved }, { new: true });
      res.json(report);
    } catch (error) {
      res.status(500).json({ error: 'Failed to update bike report', details: error.message });
    }
});

module.exports = router;
