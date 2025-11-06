const mongoose = require('mongoose');

const corporateAccountSchema = new mongoose.Schema({
  companyName: {
    type: String,
    required: true,
    unique: true,
  },
  emailDomain: {
    type: String,
    required: true,
    unique: true,
  },
  discountPercentage: {
    type: Number,
    default: 0,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
});

module.exports = mongoose.model('CorporateAccount', corporateAccountSchema);
