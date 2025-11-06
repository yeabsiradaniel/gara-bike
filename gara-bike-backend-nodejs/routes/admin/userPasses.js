const express = require('express');
const router = express.Router();
const UserPass = require('../../models/UserPass');
const adminAuth = require('../../middleware/adminAuth');

// Get all user passes
router.get('/', adminAuth, async (req, res) => {
  try {
    const passes = await UserPass.find().populate('user', 'email').populate('pass').sort({ purchasedAt: -1 });
    const responseData = passes.map(p => ({
        id: p._id,
        user: p.user, // Already populated with email
        pass_type: p.pass, // Already populated
        purchased_at: p.purchasedAt.toISOString(),
        expires_at: p.expiresAt.toISOString(),
    }));
    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch user passes', details: error.message });
  }
});

module.exports = router;