const express = require('express');
const router = express.Router();
const User = require('../../models/User');
const Bike = require('../../models/Bike');
const Ride = require('../../models/Ride');
const adminAuth = require('../../middleware/adminAuth');

router.get('/', adminAuth, async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    const totalBikes = await Bike.countDocuments();
    const activeRides = await Ride.countDocuments({ endTime: null });

    const revenueResult = await Ride.aggregate([
      { $group: { _id: null, totalRevenue: { $sum: '$cost' } } },
    ]);
    const totalRevenue = revenueResult.length > 0 ? revenueResult[0].totalRevenue : 0;

    const sevenDaysAgo = new Date(new Date().setDate(new Date().getDate() - 7));
    const ridesPerDay = await Ride.aggregate([
      { $match: { startTime: { $gte: sevenDaysAgo } } },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$startTime' } },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    const bikeStatusDistribution = await Bike.aggregate([
      { $group: { _id: '$status', count: { $sum: 1 } } },
    ]);

    res.json({
      totalUsers,
      totalBikes,
      activeRides,
      totalRevenue,
      ridesPerDay,
      bikeStatusDistribution,
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch dashboard stats', details: error.message });
  }
});

module.exports = router;