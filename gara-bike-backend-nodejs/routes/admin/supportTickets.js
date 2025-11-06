const express = require('express');
const router = express.Router();
const SupportTicket = require('../../models/SupportTicket');
const adminAuth = require('../../middleware/adminAuth');

// Get all support tickets
router.get('/', adminAuth, async (req, res) => {
  try {
    const tickets = await SupportTicket.find().populate('user').sort({ createdAt: -1 });
    const responseData = tickets.map(ticket => ({
        id: ticket._id,
        user: {
            id: ticket.user._id,
            username: ticket.user.username,
            email: ticket.user.email,
            phone_number: ticket.user.phoneNumber,
            nid: ticket.user.nid,
            referral_code: ticket.user.referralCode,
            total_distance_meters: ticket.user.totalDistanceMeters,
            total_calories_burned: ticket.user.totalCaloriesBurned,
            total_duration_minutes: ticket.user.totalDurationMinutes,
            home_address_name: ticket.user.homeAddressName,
            home_address_lat: ticket.user.homeAddressLat,
            home_address_lon: ticket.user.homeAddressLon,
            work_address_name: ticket.user.workAddressName,
            work_address_lat: ticket.user.workAddressLat,
            work_address_lon: ticket.user.workAddressLon,
        },
        subject: ticket.subject,
        message: ticket.message,
        status: ticket.status,
        created_at: ticket.createdAt.toISOString(),
    }));
    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch support tickets', details: error.message });
  }
});

// Update a support ticket
router.put('/:id', adminAuth, async (req, res) => {
  try {
    const updatedTicket = await SupportTicket.findByIdAndUpdate(req.params.id, req.body, { new: true }).populate('user');
    if (!updatedTicket) {
        return res.status(404).json({ error: 'Support ticket not found' });
    }
    const responseData = {
        id: updatedTicket._id,
        user: {
            id: updatedTicket.user._id,
            username: updatedTicket.user.username,
            email: updatedTicket.user.email,
            phone_number: updatedTicket.user.phoneNumber,
            nid: updatedTicket.user.nid,
            referral_code: updatedTicket.user.referralCode,
            total_distance_meters: updatedTicket.user.totalDistanceMeters,
            total_calories_burned: updatedTicket.user.totalCaloriesBurned,
            total_duration_minutes: updatedTicket.user.totalDurationMinutes,
            home_address_name: updatedTicket.user.homeAddressName,
            home_address_lat: updatedTicket.user.homeAddressLat,
            home_address_lon: updatedTicket.user.homeAddressLon,
            work_address_name: updatedTicket.user.workAddressName,
            work_address_lat: updatedTicket.user.workAddressLat,
            work_address_lon: updatedTicket.user.workAddressLon,
        },
        subject: updatedTicket.subject,
        message: updatedTicket.message,
        status: updatedTicket.status,
        created_at: updatedTicket.createdAt.toISOString(),
    };
    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update support ticket', details: error.message });
  }
});

module.exports = router;