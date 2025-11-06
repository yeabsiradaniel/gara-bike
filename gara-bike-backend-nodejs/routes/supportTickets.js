
const express = require('express');
const router = express.Router();
const SupportTicket = require('../models/SupportTicket');
const auth = require('../middleware/auth');

// Create a support ticket
router.post('/support-tickets', auth, async (req, res) => {
  const { subject, message } = req.body;
  const { userId } = req.userData;

  try {
    const supportTicket = new SupportTicket({
      user: userId,
      subject,
      message,
    });
    await supportTicket.save();

    res.status(201).json(supportTicket);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create support ticket', details: error.message });
  }
});

// Get all support tickets for a user
router.get('/support-tickets', auth, async (req, res) => {
    const { userId } = req.userData;

    try {
        const supportTickets = await SupportTicket.find({ user: userId }).sort({ createdAt: -1 });

        res.json(supportTickets);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch support tickets', details: error.message });
    }
});

module.exports = router;
