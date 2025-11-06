const express = require('express');
const router = express.Router();
const Wallet = require('../../models/Wallet');
const adminAuth = require('../../middleware/adminAuth');

// Get all wallets
router.get('/', adminAuth, async (req, res) => {
  try {
    const wallets = await Wallet.find().populate('user', 'email').sort({ createdAt: -1 });
    const responseData = wallets.map(w => ({
        id: w._id,
        user: w.user, // Already populated with email
        balance: w.balance,
    }));
    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch wallets', details: error.message });
  }
});

// Delete a wallet
router.delete('/:id', adminAuth, async (req, res) => {
  try {
    const wallet = await Wallet.findByIdAndDelete(req.params.id);
    if (!wallet) {
      return res.status(404).json({ error: 'Wallet not found' });
    }
    res.json({ message: 'Wallet deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete wallet', details: error.message });
  }
});

module.exports = router;