const express = require('express');
const router = express.Router();
const Transaction = require('../../models/Transaction');
const adminAuth = require('../../middleware/adminAuth');

// Get all transactions
router.get('/', adminAuth, async (req, res) => {
  try {
    const transactions = await Transaction.find().populate({ path: 'wallet', populate: { path: 'user', select: 'email' } }).sort({ createdAt: -1 });
    const responseData = transactions.map(t => ({
        id: t._id,
        wallet: t.wallet,
        amount: t.amount,
        transaction_type: t.transactionType,
        timestamp: t.createdAt.toISOString(),
        description: t.description,
    }));
    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch transactions', details: error.message });
  }
});

module.exports = router;