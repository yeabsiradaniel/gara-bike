
const express = require('express');
const router = express.Router();
const Ride = require('../models/Ride');
const Bike = require('../models/Bike');
const User = require('../models/User');
const Wallet = require('../models/Wallet');
const Transaction = require('../models/Transaction');
const ParkingZone = require('../models/ParkingZone');

function haversine(lon1, lat1, lon2, lat2) {
  lon1 = (lon1 * Math.PI) / 180;
  lat1 = (lat1 * Math.PI) / 180;
  lon2 = (lon2 * Math.PI) / 180;
  lat2 = (lat2 * Math.PI) / 180;

  let dlon = lon2 - lon1;
  let dlat = lat2 - lat1;
  let a = Math.pow(Math.sin(dlat / 2), 2) + Math.cos(lat1) * Math.cos(lat2) * Math.pow(Math.sin(dlon / 2), 2);
  let c = 2 * Math.asin(Math.sqrt(a));
  let r = 6371; // Radius of earth in kilometers
  return c * r * 1000; // return distance in meters
}

// Start a ride
const { body, validationResult } = require('express-validator');
const auth = require('../middleware/auth');

// Start a ride
router.post('/rides/start', 
  auth, 
  [ body('qrCode', 'QR Code is required').not().isEmpty() ], 
  async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { qrCode } = req.body;
  const { userId } = req.userData;

  try {
    const user = await User.findById(userId);
    const wallet = await Wallet.findOne({ user: userId });
    if (!wallet || wallet.balance <= 0) {
      return res.status(400).json({ error: 'Insufficient funds. Please top up your wallet to start a ride.' });
    }

    const existingRide = await Ride.findOne({ user: userId, endTime: null });
    if (existingRide) {
      return res.status(400).json({ error: 'You already have an active ride.' });
    }

    const bike = await Bike.findOne({ qrCode });

    if (!bike) {
      return res.status(404).json({ error: 'Bike not found' });
    }

    if (bike.status === 'RESERVED') {
      if (bike.reservedBy.toString() !== userId) {
        return res.status(400).json({ error: 'Bike is reserved by another user.' });
      }
      if (bike.reservationExpiresAt && new Date() > bike.reservationExpiresAt) {
        await Bike.findByIdAndUpdate(bike._id, { status: 'AVAILABLE', reservedBy: null, reservationExpiresAt: null });
        return res.status(400).json({ error: 'Your reservation has expired.' });
      }
    } else if (bike.status !== 'AVAILABLE') {
      return res.status(400).json({ error: 'Bike not available to start a ride' });
    }

    const ride = new Ride({
      user: userId,
      bike: bike._id,
      startLocation: bike.location,
    });
    await ride.save();

    const updatedBike = await Bike.findByIdAndUpdate(bike._id, {
      status: 'IN_USE',
      reservedBy: null,
      reservationExpiresAt: null,
    }, { new: true });

    // Manually construct the response to match Django's RideSerializer
    const responseData = {
        id: ride._id,
        user: {
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
        },
        bike: {
            id: updatedBike._id,
            qr_code: updatedBike.qrCode,
            status: updatedBike.status,
            latitude: updatedBike.location.coordinates[0],
            longitude: updatedBike.location.coordinates[1],
            battery_level: updatedBike.batteryLevel,
        },
        start_latitude: ride.startLocation.coordinates[1],
        start_longitude: ride.startLocation.coordinates[0],
        end_latitude: null,
        end_longitude: null,
        start_time: ride.startTime.toISOString(),
        end_time: null,
        cost: null,
        distance_meters: null,
        calories_burned: null,
    };

    res.status(201).json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to start ride', details: error.message });
  }
});

// End a ride
router.post('/rides/:id/end', 
  auth, 
  [
    body('latitude', 'Latitude must be a numeric value').isNumeric(),
    body('longitude', 'Longitude must be a numeric value').isNumeric(),
    body('distance', 'Distance must be a numeric value').isNumeric(),
    body('calories', 'Calories must be a numeric value').isNumeric(),
  ],
  async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id } = req.params;
  const { latitude, longitude, distance, calories } = req.body;

  if (!latitude || !longitude) {
    return res.status(400).json({ error: 'Final location required.' });
  }

  try {
    const ride = await Ride.findById(id).populate({
        path: 'user',
        populate: { path: 'corporateAccount' }
    }).populate('bike');

    if (!ride || ride.endTime) {
      return res.status(404).json({ error: 'Ride not found or already ended' });
    }

    const parkingZones = await ParkingZone.find({ isActive: true });
    const inParkingZone = parkingZones.some(zone => haversine(longitude, latitude, zone.longitude, zone.latitude) <= zone.radius);

    if (!inParkingZone) {
      return res.status(400).json({ error: 'You must end your ride in a designated parking zone.' });
    }

    const rideDurationInMinutes = Math.ceil((new Date() - ride.startTime) / (1000 * 60));
    let cost = 0;

    const userPass = await UserPass.findOne({ user: ride.user._id, expiresAt: { $gt: new Date() } });

    if (!userPass) {
        const baseCost = rideDurationInMinutes * 1.5; // Example cost calculation
        const discount = ride.user.corporateAccount ? baseCost * (ride.user.corporateAccount.discountPercentage / 100) : 0;
        cost = baseCost - discount;

        const wallet = await Wallet.findOneAndUpdate({ user: ride.user._id }, { $inc: { balance: -cost } });
        
        if (!wallet) {
            return res.status(404).json({ error: 'User wallet not found.' });
        }

        const transaction = new Transaction({
            wallet: wallet._id,
            amount: -cost,
            transactionType: 'RIDE_PAYMENT',
            description: `Payment for ride ${ride._id}`,
        });
        await transaction.save();
    }

    ride.endTime = new Date();
    ride.endLocation = { type: 'Point', coordinates: [longitude, latitude] };
    ride.distanceMeters = distance;
    ride.caloriesBurned = calories;
    ride.cost = cost;
    await ride.save();

    await Bike.findByIdAndUpdate(ride.bike._id, {
      status: 'AVAILABLE',
      location: { type: 'Point', coordinates: [longitude, latitude] },
    });

    await User.findByIdAndUpdate(ride.user._id, {
        $inc: {
            totalDistanceMeters: distance,
            totalCaloriesBurned: calories,
            totalDurationMinutes: rideDurationInMinutes,
        }
    });

    // Manually construct the response to match Django's RideSerializer
    const responseData = {
        id: ride._id,
        user: {
            id: ride.user._id,
            username: ride.user.username,
            email: ride.user.email,
            phone_number: ride.user.phoneNumber,
            nid: ride.user.nid,
            referral_code: ride.user.referralCode,
            total_distance_meters: ride.user.totalDistanceMeters + (distance || 0),
            total_calories_burned: ride.user.totalCaloriesBurned + (calories || 0),
            total_duration_minutes: ride.user.totalDurationMinutes + rideDurationInMinutes,
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
            status: 'AVAILABLE', // Status is now available
            latitude: longitude, // Bike's new location
            longitude: latitude,
            battery_level: ride.bike.batteryLevel,
        },
        start_latitude: ride.startLocation.coordinates[1],
        start_longitude: ride.startLocation.coordinates[0],
        end_latitude: ride.endLocation.coordinates[1],
        end_longitude: ride.endLocation.coordinates[0],
        start_time: ride.startTime.toISOString(),
        end_time: ride.endTime.toISOString(),
        cost: ride.cost,
        distance_meters: ride.distanceMeters,
        calories_burned: ride.caloriesBurned,
    };

    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to end ride', details: error.message });
  }
});

module.exports = router;
