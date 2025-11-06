const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
  wallet: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Wallet',
    required: true,
  },
  amount: {
    type: Number,
    required: true,
  },
  transactionType: {
    type: String,
    required: true,
    enum: ['TOP_UP', 'RIDE_PAYMENT', 'PASS_PURCHASE', 'CANCELLATION_FEE', 'REFUND'],
  },
  description: {
    type: String,
  },
}, { timestamps: true });

module.exports = mongoose.model('Transaction', transactionSchema);
