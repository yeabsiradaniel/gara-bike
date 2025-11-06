
require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors'); // Import cors

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors()); // Use cors middleware to allow all origins
app.use(express.json());

// Database Connection
mongoose.connect(process.env.DATABASE_URL, { useNewUrlParser: true, useUnifiedTopology: true });
const db = mongoose.connection;
db.on('error', (error) => console.error(error));
db.once('open', () => console.log('Connected to MongoDB Atlas'));

app.get('/', (req, res) => {
  res.send('Gara Bike Backend in Node.js');
});

const authRoutes = require('./routes/auth');
const bikeRoutes = require('./routes/bikes');
const rideRoutes = require('./routes/rides');
const walletRoutes = require('./routes/wallet');
const passRoutes = require('./routes/passes');
const userRoutes = require('./routes/users');
const parkingZoneRoutes = require('./routes/parkingZones');
const bikeReportRoutes = require('./routes/bikeReports');
const supportTicketRoutes = require('./routes/supportTickets');
const adminUserRoutes = require('./routes/admin/users');
const adminBikeRoutes = require('./routes/admin/bikes');
const adminRideRoutes = require('./routes/admin/rides');
const adminSupportTicketRoutes = require('./routes/admin/supportTickets');
const adminParkingZoneRoutes = require('./routes/admin/parkingZones');
const adminCorporateAccountRoutes = require('./routes/admin/corporateAccounts');
const adminDashboardRoutes = require('./routes/admin/dashboard');
const adminBikeReportRoutes = require('./routes/admin/bikeReports');
const adminUserPassRoutes = require('./routes/admin/userPasses');
const adminTransactionRoutes = require('./routes/admin/transactions');
const adminWalletRoutes = require('./routes/admin/wallets'); // Add this line
app.use('/api', authRoutes);
app.use('/api', bikeRoutes);
app.use('/api', rideRoutes);
app.use('/api', walletRoutes);
app.use('/api', passRoutes);
app.use('/api', userRoutes);
app.use('/api', parkingZoneRoutes);
app.use('/api', bikeReportRoutes);
app.use('/api', supportTicketRoutes);
app.use('/api', adminUserRoutes);
app.use('/api', adminBikeRoutes);
app.use('/api', adminRideRoutes);
app.use('/api', adminSupportTicketRoutes);
app.use('/api', adminParkingZoneRoutes);
app.use('/api', adminCorporateAccountRoutes);
app.use('/api', adminDashboardRoutes);
app.use('/api', adminBikeReportRoutes);
app.use('/api', adminUserPassRoutes);
app.use('/api', adminTransactionRoutes);
app.use('/api', adminWalletRoutes); // Add this line

const adminRoutes = require('./routes/admin');

// Mount the admin router
app.use('/api/admin', adminRoutes);

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
