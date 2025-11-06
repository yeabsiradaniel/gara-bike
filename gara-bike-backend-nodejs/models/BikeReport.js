const mongoose = require('mongoose');

const bikeReportSchema = new mongoose.Schema({
  bike: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Bike',
    required: true,
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  reportType: {
    type: String,
    required: true,
  },
  comments: {
    type: String,
  },
  isResolved: {
    type: Boolean,
    default: false,
  },
}, { timestamps: true });

module.exports = mongoose.model('BikeReport', bikeReportSchema);
