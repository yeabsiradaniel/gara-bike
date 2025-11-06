
const express = require('express');
const router = express.Router();
const Bike = require('../models/Bike');
const Wallet = require('../models/Wallet');
const Transaction = require('../models/Transaction');
const { body, validationResult } = require('express-validator');
const auth = require('../middleware/auth');

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

// Get all available bikes
router.get('/bikes', auth, async (req, res) => {
  const { lat, lon, zone_id } = req.query;

  try {
    let bikes = await Bike.find({ status: 'AVAILABLE' }).populate('reservedBy');

    if (zone_id) {
      const zone = await ParkingZone.findById(zone_id);
      if (zone) {
        bikes = bikes.filter(bike => {
          const bikeLat = bike.location.coordinates[1];
          const bikeLon = bike.location.coordinates[0];
          const distance = haversine(zone.longitude, zone.latitude, bikeLon, bikeLat);
          return distance <= zone.radius;
        });
      }
    }

    if (lat && lon) {
      const userLat = parseFloat(lat);
      const userLon = parseFloat(lon);
      bikes.forEach(bike => {
        const bikeLat = bike.location.coordinates[1];
        const bikeLon = bike.location.coordinates[0];
        bike.distance = haversine(userLon, userLat, bikeLon, bikeLat);
      });
      bikes.sort((a, b) => a.distance - b.distance);
    }

    // Manually construct the response to match Django's BikeSerializer
    const responseData = bikes.map(bike => {
        let reservedByData = null;
        if (bike.reservedBy) {
            reservedByData = {
                id: bike.reservedBy._id,
                username: bike.reservedBy.username,
                email: bike.reservedBy.email,
                phone_number: bike.reservedBy.phoneNumber,
                nid: bike.reservedBy.nid,
                referral_code: bike.reservedBy.referralCode,
                total_distance_meters: bike.reservedBy.totalDistanceMeters,
                total_calories_burned: bike.reservedBy.totalCaloriesBurned,
                total_duration_minutes: bike.reservedBy.totalDurationMinutes,
                home_address_name: bike.reservedBy.homeAddressName,
                home_address_lat: bike.reservedBy.homeAddressLat,
                home_address_lon: bike.reservedBy.homeAddressLon,
                work_address_name: bike.reservedBy.workAddressName,
                work_address_lat: bike.reservedBy.workAddressLat,
                work_address_lon: bike.reservedBy.workAddressLon,
            };
        }

        return {
            id: bike._id,
            qr_code: bike.qrCode,
            status: bike.status,
            latitude: bike.location.coordinates[1],
            longitude: bike.location.coordinates[0],
            battery_level: bike.batteryLevel,
            distance: bike.distance || undefined, // Only include if calculated
            reserved_by: reservedByData,
            reservation_expires_at: bike.reservationExpiresAt ? bike.reservationExpiresAt.toISOString() : null,
        };
    });

    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch bikes', details: error.message });
  }
});

// Reserve a bike
router.post('/bikes/:id/reserve', 
  auth,
  [ body('duration', 'Duration must be an integer').optional().isInt() ],
  async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id } = req.params;
  const { userId } = req.userData;
  const { duration } = req.body;

  try {
    const user = await User.findById(userId);
    const wallet = await Wallet.findOne({ user: userId });
    if (!wallet || wallet.balance <= 0) {
      return res.status(400).json({ error: 'Insufficient funds. Please top up your wallet to make a reservation.' });
    }

    const existingRide = await Ride.findOne({ user: userId, endTime: null });
    const existingReservation = await Bike.findOne({ reservedBy: userId });
    if (existingRide || existingReservation) {
      return res.status(400).json({ error: 'You already have an active ride or reservation.' });
    }

    const bike = await Bike.findById(id);

    if (!bike || bike.status !== 'AVAILABLE') {
      return res.status(400).json({ error: 'Bike not available for reservation' });
    }

    const reservationDuration = duration && duration > 0 ? parseInt(duration) : 5;

    const updatedBike = await Bike.findByIdAndUpdate(id, {
      status: 'RESERVED',
      reservedBy: userId,
      reservationExpiresAt: new Date(Date.now() + reservationDuration * 60 * 1000),
    }, { new: true }).populate('reservedBy');

    // Manually construct the response to match Django's BikeSerializer
    const responseData = {
        id: updatedBike._id,
        qr_code: updatedBike.qrCode,
        status: updatedBike.status,
        latitude: updatedBike.location.coordinates[0],
        longitude: updatedBike.location.coordinates[1],
        battery_level: updatedBike.batteryLevel,
        distance: null, // Not calculated on reservation
        reserved_by: {
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
        reservation_expires_at: updatedBike.reservationExpiresAt.toISOString(),
    };

    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to reserve bike', details: error.message });
  }
});

// Cancel a reservation
router.post('/bikes/:id/cancel-reservation', auth, async (req, res) => {
  const { id } = req.params;
  const { userId } = req.userData;

  try {
    const bike = await Bike.findOne({ _id: id, reservedBy: userId, status: 'RESERVED' });

    if (!bike) {
      return res.status(404).json({ error: 'Reservation not found.' });
    }

    const cancellationFee = 5.00;
    const wallet = await Wallet.findOneAndUpdate(
      { user: userId },
      { $inc: { balance: -cancellationFee } },
      { new: true }
    );

    if (!wallet) {
        return res.status(404).json({ error: 'User wallet not found.' });
    }

    const transaction = new Transaction({
        wallet: wallet._id,
        amount: -cancellationFee,
        transactionType: 'CANCELLATION_FEE',
        description: `Cancellation fee for bike ${bike._id}`,
    });
    await transaction.save();

    await Bike.findByIdAndUpdate(id, {
      status: 'AVAILABLE',
      reservedBy: null,
      reservationExpiresAt: null,
    });

    res.json({ message: 'Reservation cancelled.', fee_charged: cancellationFee.toString() });
  } catch (error) {
    res.status(500).json({ error: 'Failed to cancel reservation', details: error.message });
  }
});

module.exports = router;
