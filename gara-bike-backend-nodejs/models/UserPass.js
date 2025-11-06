const mongoose = require('mongoose');

const userPassSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  pass: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Pass',
    required: true,
  },
  expiresAt: {
    type: Date,
    required: true,
  },
}, { timestamps: { createdAt: 'purchasedAt' } });

module.exports = mongoose.model('UserPass', userPassSchema);
