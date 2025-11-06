
const express = require('express');
const router = express.Router();
const Pass = require('../models/Pass');
const auth = require('../middleware/auth');

// Get all active passes
router.get('/passes', auth, async (req, res) => {
  try {
    const passes = await Pass.find({ isActive: true });
    res.json(passes);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch passes', details: error.message });
  }
});

module.exports = router;
