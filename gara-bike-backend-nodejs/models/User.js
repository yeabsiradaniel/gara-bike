const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true,
  },
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },
  password: {
    type: String,
    required: true,
  },
  phoneNumber: {
    type: String,
    required: true,
    unique: true,
  },
  nid: {
    type: String,
    required: true,
    unique: true,
  },
  isVerified: {
    type: Boolean,
    default: false,
  },
  isAdmin: {
    type: Boolean,
    default: false,
  },
  referralCode: {
    type: String,
    unique: true,
  },
  corporateAccount: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'CorporateAccount',
  },
  totalDistanceMeters: {
    type: Number,
    default: 0,
  },
  totalCaloriesBurned: {
    type: Number,
    default: 0,
  },
  totalDurationMinutes: {
    type: Number,
    default: 0,
  },
  homeAddressName: String,
  homeAddressLat: Number,
  homeAddressLon: Number,
  workAddressName: String,
  workAddressLat: Number,
  workAddressLon: Number,
  dateJoined: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('User', userSchema);
