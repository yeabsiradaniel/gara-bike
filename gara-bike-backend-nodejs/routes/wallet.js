
const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();
const Wallet = require('../models/Wallet');
const Transaction = require('../models/Transaction');
const Pass = require('../models/Pass');
const UserPass = require('../models/UserPass');
const auth = require('../middleware/auth');

// Get wallet details
router.get('/wallet', auth, async (req, res) => {
  const { userId } = req.userData;

  try {
    const wallet = await Wallet.findOne({ user: userId });
    const transactions = await Transaction.find({ wallet: wallet._id });

    if (!wallet) {
      return res.status(404).json({ error: 'Wallet not found' });
    }

    res.json({ wallet, transactions });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch wallet', details: error.message });
  }
});

// Top up wallet
router.post('/wallet/top-up', auth, async (req, res) => {
  const { amount, paymentMethod } = req.body;
  const { userId } = req.userData;

  try {
    const wallet = await Wallet.findOneAndUpdate({ user: userId }, { $inc: { balance: amount } }, { new: true });

    const transaction = new Transaction({
        wallet: wallet._id,
        amount,
        transactionType: 'TOP_UP',
        description: `Top up via ${paymentMethod}`,
    });
    await transaction.save();

    res.json({ message: 'Wallet topped up', newBalance: wallet.balance });
  } catch (error) {
    res.status(500).json({ error: 'Failed to top up wallet', details: error.message });
  }
});

// Purchase a pass
router.post('/wallet/purchase-pass', auth, async (req, res) => {
  const { passId } = req.body;
  const { userId } = req.userData;

  try {
    const pass = await Pass.findById(passId);

    if (!pass) {
      return res.status(404).json({ error: 'Pass not found' });
    }

    const wallet = await Wallet.findOne({ user: userId });

    if (!wallet || wallet.balance < pass.price) {
      return res.status(400).json({ error: 'Insufficient balance' });
    }

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + pass.durationDays);

    const session = await mongoose.startSession();
    session.startTransaction();

    try {
        const updatedWallet = await Wallet.findByIdAndUpdate(wallet._id, { $inc: { balance: -pass.price } }, { session });

        const userPass = new UserPass({ user: userId, pass: passId, expiresAt });
        await userPass.save({ session });

        const transaction = new Transaction({
            wallet: wallet._id,
            amount: -pass.price,
            transactionType: 'PASS_PURCHASE',
            description: `Purchased ${pass.name}`,
        });
        await transaction.save({ session });

        await session.commitTransaction();
        res.status(201).json(userPass);

    } catch (error) {
        await session.abortTransaction();
        throw error;
    } finally {
        session.endSession();
    }

  } catch (error) {
    res.status(500).json({ error: 'Failed to purchase pass', details: error.message });
  }
});

module.exports = router;
