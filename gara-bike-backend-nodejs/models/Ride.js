const mongoose = require('mongoose');

const rideSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  bike: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Bike',
    required: true,
  },
  startTime: {
    type: Date,
    default: Date.now,
  },
  endTime: {
    type: Date,
  },
  startLocation: {
    type: {
        type: String,
        enum: ['Point'],
        required: true
    },
    coordinates: {
        type: [Number],
        required: true
    }
  },
  endLocation: {
    type: {
        type: String,
        enum: ['Point'],
    },
    coordinates: {
        type: [Number],
    }
  },
  cost: {
    type: Number,
  },
  distanceMeters: {
    type: Number,
  },
  caloriesBurned: {
    type: Number,
  },
}, { timestamps: true });

module.exports = mongoose.model('Ride', rideSchema);
