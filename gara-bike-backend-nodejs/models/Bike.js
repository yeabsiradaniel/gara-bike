const mongoose = require('mongoose');

const bikeSchema = new mongoose.Schema({
  qrCode: {
    type: String,
    required: true,
    unique: true,
  },
  status: {
    type: String,
    required: true,
    default: 'AVAILABLE',
    enum: ['AVAILABLE', 'RESERVED', 'IN_USE', 'MAINTENANCE'],
  },
  location: {
    type: {
        type: String,
        enum: ['Point'],
        default: 'Point'
    },
    coordinates: {
        type: [Number],
        index: '2dsphere'
    }
  },
  batteryLevel: {
    type: Number,
    default: 100,
    min: 0,
    max: 100,
  },
  reservedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    unique: true,
    sparse: true, // Allows multiple documents to have a null value for this field
  },
  reservationExpiresAt: {
    type: Date,
  },
}, { timestamps: true }); // Adds createdAt and updatedAt timestamps

module.exports = mongoose.model('Bike', bikeSchema);
