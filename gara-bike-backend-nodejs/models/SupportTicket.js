const mongoose = require('mongoose');

const supportTicketSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  subject: {
    type: String,
    required: true,
  },
  message: {
    type: String,
    required: true,
  },
  status: {
    type: String,
    required: true,
    default: 'OPEN',
    enum: ['OPEN', 'IN_PROGRESS', 'CLOSED'],
  },
}, { timestamps: true });

module.exports = mongoose.model('SupportTicket', supportTicketSchema);
