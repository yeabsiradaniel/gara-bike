const express = require('express');
const router = express.Router();
const Ride = require('../../models/Ride');
const adminAuth = require('../../middleware/adminAuth');

// Get all rides
router.get('/', adminAuth, async (req, res) => {
  try {
    const rides = await Ride.find().populate('user').populate('bike').sort({ startTime: -1 });
    const responseData = rides.map(ride => ({
        id: ride._id,
        user: {
            id: ride.user._id,
            username: ride.user.username,
            email: ride.user.email,
            phone_number: ride.user.phoneNumber,
            nid: ride.user.nid,
            referral_code: ride.user.referralCode,
            total_distance_meters: ride.user.totalDistanceMeters,
            total_calories_burned: ride.user.totalCaloriesBurned,
            total_duration_minutes: ride.user.totalDurationMinutes,
            home_address_name: ride.user.homeAddressName,
            home_address_lat: ride.user.homeAddressLat,
            home_address_lon: ride.user.homeAddressLon,
            work_address_name: ride.user.workAddressName,
            work_address_lat: ride.user.workAddressLat,
            work_address_lon: ride.user.workAddressLon,
        },
        bike: {
            id: ride.bike._id,
            qr_code: ride.bike.qrCode,
            status: ride.bike.status,
            latitude: ride.bike.location ? ride.bike.location.coordinates[1] : null,
            longitude: ride.bike.location ? ride.bike.location.coordinates[0] : null,
            battery_level: ride.bike.batteryLevel,
            last_reported_at: ride.bike.updatedAt ? ride.bike.updatedAt.toISOString() : null,
        },
        start_time: ride.startTime.toISOString(),
        end_time: ride.endTime ? ride.endTime.toISOString() : null,
        cost: ride.cost,
        distance_meters: ride.distanceMeters,
        start_latitude: ride.startLocation.coordinates[1],
        start_longitude: ride.startLocation.coordinates[0],
        end_latitude: ride.endLocation ? ride.endLocation.coordinates[1] : null,
        end_longitude: ride.endLocation ? ride.endLocation.coordinates[0] : null,
    }));
    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch rides', details: error.message });
  }
});

module.exports = router;