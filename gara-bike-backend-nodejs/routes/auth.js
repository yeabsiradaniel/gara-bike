
const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const otpGenerator = require('otp-generator');

const { body, validationResult } = require('express-validator');

const User = require('../models/User');
const Wallet = require('../models/Wallet');
const CorporateAccount = require('../models/CorporateAccount');

const otpCache = new Map();

// Register a new user
router.post('/register', 
  [
    body('email', 'Please include a valid email').isEmail().normalizeEmail(),
    body('password', 'Password must be 6 or more characters').isLength({ min: 6 }),
    body('username', 'Username is required').not().isEmpty(),
    body('phoneNumber', 'Phone number is required').not().isEmpty(),
    body('nid', 'National ID must be a 16-digit numeric code').isLength({ min: 16, max: 16 }).isNumeric(),
  ],
  async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { username, password, email, phoneNumber, nid } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(password, 10);

    const emailDomain = email.split('@')[1];
    const corporateAccount = await CorporateAccount.findOne({ emailDomain });

    const referralCode = Math.random().toString(36).substring(2, 8).toUpperCase();
    console.log(`Generated referral code for ${email}: ${referralCode}`);

    const user = new User({
      username,
      password: hashedPassword,
      email,
      phoneNumber,
      nid,
      corporateAccount: corporateAccount ? corporateAccount._id : null,
      referralCode,
    });
    await user.save();

    // Create a wallet for the new user
    const wallet = new Wallet({ user: user._id });
    await wallet.save();

    const otp = otpGenerator.generate(4, { upperCase: false, specialChars: false, alphabets: false });
    otpCache.set(user.id, otp);

    console.log(`OTP for ${email}: ${otp}`);

    res.status(201).json({ message: 'User created successfully. Please verify OTP.' });
  } catch (error) {
    res.status(400).json({ error: 'User registration failed', details: error.message });
  }
});

// Verify OTP
router.post('/verify-otp', async (req, res) => {
  const { email, otp } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const storedOtp = otpCache.get(user.id);

    if (storedOtp !== otp) {
      return res.status(400).json({ error: 'Invalid OTP' });
    }

    await User.findByIdAndUpdate(user.id, { isVerified: true });

    otpCache.delete(user.id);

    res.status(200).json({ message: 'OTP verified successfully' });
  } catch (error) {
    res.status(500).json({ error: 'OTP verification failed', details: error.message });
  }
});

// Login a user
router.post('/login', 
  [
    body('email', 'Please include a valid email').isEmail().normalizeEmail(),
    body('password', 'Password is required').exists(),
  ],
  async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Invalid password' });
    }

    const token = jwt.sign({ userId: user._id, isAdmin: user.isAdmin }, process.env.JWT_SECRET, {
      expiresIn: '1h',
    });

    res.json({ token, user: { email: user.email, username: user.username, isAdmin: user.isAdmin } });
  } catch (error) {
    res.status(500).json({ error: 'Login failed', details: error.message });
  }
});

module.exports = router;
