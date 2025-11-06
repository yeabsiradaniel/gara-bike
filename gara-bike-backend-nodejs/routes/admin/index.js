const express = require('express');
const router = express.Router();

// Import admin route modules
const userRoutes = require('./users');
const bikeRoutes = require('./bikes');
const rideRoutes = require('./rides');
const supportTicketRoutes = require('./supportTickets');
const parkingZoneRoutes = require('./parkingZones');
const corporateAccountRoutes = require('./corporateAccounts');
const dashboardRoutes = require('./dashboard');
const userPassRoutes = require('./userPasses');
const transactionRoutes = require('./transactions');
const walletRoutes = require('./wallets');

// Use admin route modules
router.use('/users', userRoutes);
router.use('/bikes', bikeRoutes);
router.use('/rides', rideRoutes);
router.use('/support-tickets', supportTicketRoutes);
router.use('/parking-zones', parkingZoneRoutes);
router.use('/corporate-accounts', corporateAccountRoutes);
router.use('/dashboard', dashboardRoutes);
router.use('/user-passes', userPassRoutes);
router.use('/transactions', transactionRoutes);
router.use('/wallets', walletRoutes);

module.exports = router;