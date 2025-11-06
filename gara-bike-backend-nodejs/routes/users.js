
const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Bike = require('../models/Bike');
const Ride = require('../models/Ride');
const auth = require('../middleware/auth');

// Get user profile
router.get('/users/me', auth, async (req, res) => {
  const { userId } = req.userData;

  try {
    const user = await User.findById(userId).select('-password');

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Manually construct the response to match Django's UserSerializer
    const responseData = {
        id: user._id,
        username: user.username,
        email: user.email,
        phone_number: user.phoneNumber,
        nid: user.nid,
        referral_code: user.referralCode,
        total_distance_meters: user.totalDistanceMeters,
        total_calories_burned: user.totalCaloriesBurned,
        total_duration_minutes: user.totalDurationMinutes,
        home_address_name: user.homeAddressName,
        home_address_lat: user.homeAddressLat,
        home_address_lon: user.homeAddressLon,
        work_address_name: user.workAddressName,
        work_address_lat: user.workAddressLat,
        work_address_lon: user.workAddressLon,
    };

    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch user profile', details: error.message });
  }
});

// Update user profile
router.patch('/users/me', auth, async (req, res) => {
  const { userId } = req.userData;
  const allowedUpdates = [
    'username', 'phoneNumber',
    'homeAddressName', 'homeAddressLat', 'homeAddressLon',
    'workAddressName', 'workAddressLat', 'workAddressLon'
  ];
  const updates = {};

  for (const key of allowedUpdates) {
    if (req.body[key] !== undefined) {
      updates[key] = req.body[key];
    }
  }

  try {
    const user = await User.findByIdAndUpdate(userId, { $set: updates }, { new: true }).select('-password');

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Manually construct the response to match Django's UserSerializer (as UserProfileUpdateSerializer is a subset)
    const responseData = {
        id: user._id,
        username: user.username,
        email: user.email,
        phone_number: user.phoneNumber,
        nid: user.nid,
        referral_code: user.referralCode,
        total_distance_meters: user.totalDistanceMeters,
        total_calories_burned: user.totalCaloriesBurned,
        total_duration_minutes: user.totalDurationMinutes,
        home_address_name: user.homeAddressName,
        home_address_lat: user.homeAddressLat,
        home_address_lon: user.homeAddressLon,
        work_address_name: user.workAddressName,
        work_address_lat: user.workAddressLat,
        work_address_lon: user.workAddressLon,
    };

    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update user profile', details: error.message });
  }
});

// Get active reservation
router.get('/users/me/active-reservation', auth, async (req, res) => {
  const { userId } = req.userData;

  try {
    const bike = await Bike.findOne({ reservedBy: userId, status: 'RESERVED' });

    if (!bike) {
      return res.status(404).json({ error: 'No active reservation found' });
    }

    res.json(bike);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch active reservation', details: error.message });
  }
});

// Get active ride
router.get('/users/me/active-ride', auth, async (req, res) => {
  const { userId } = req.userData;

  try {
    const ride = await Ride.findOne({ user: userId, endTime: null });

    if (!ride) {
      return res.status(404).json({ error: 'No active ride found' });
    }

    res.json(ride);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch active ride', details: error.message });
  }
});

// Get user statistics
router.get('/users/me/statistics', auth, async (req, res) => {
  const { userId } = req.userData;

  try {
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const totalDistanceMeters = user.totalDistanceMeters || 0;
    const totalCaloriesBurned = user.totalCaloriesBurned || 0;
    const totalDurationMinutes = user.totalDurationMinutes || 0;

    res.json({
      duration: `${totalDurationMinutes} mins`,
      distance: `${totalDistanceMeters.toFixed(0)} m`,
      calories: `${totalCaloriesBurned} cal`,
      carbon: `${(totalDistanceMeters * 0.01).toFixed(2)} oz`,
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch user statistics', details: error.message });
  }
});

// Get referral code
router.get('/users/me/referral-code', auth, async (req, res) => {
  const { userId } = req.userData;

  try {
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ invitation_code: user.referralCode });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch referral code', details: error.message });
  }
});

module.exports = router;
