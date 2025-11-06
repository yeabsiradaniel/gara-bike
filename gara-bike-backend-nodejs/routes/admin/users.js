const express = require('express');
const router = express.Router();
const User = require('../../models/User');
const adminAuth = require('../../middleware/adminAuth');

// Get all users
router.get('/', adminAuth, async (req, res) => {
  try {
    const users = await User.find().populate('corporateAccount').sort({ dateJoined: -1 });
    const responseData = users.map(user => {
        let corporateAccountData = null;
        if (user.corporateAccount) {
            corporateAccountData = {
                id: user.corporateAccount._id,
                company_name: user.corporateAccount.companyName,
                email_domain: user.corporateAccount.emailDomain,
                discount_percentage: user.corporateAccount.discountPercentage,
                is_active: user.corporateAccount.isActive,
            };
        }
        return {
            id: user._id,
            username: user.username,
            email: user.email,
            phone_number: user.phoneNumber,
            is_staff: user.isAdmin, // Assuming isAdmin in Node.js maps to is_staff in Django for admin purposes
            is_active: user.isVerified, // Assuming isVerified in Node.js maps to is_active in Django
            is_verified: user.isVerified,
            corporate_account: corporateAccountData,
            date_joined: user.dateJoined.toISOString(),
        };
    });
    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch users', details: error.message });
  }
});

// Update a user
router.put('/:id', adminAuth, async (req, res) => {
  try {
    const { corporate_account_id, ...updates } = req.body;
    if (corporate_account_id !== undefined) {
        updates.corporateAccount = corporate_account_id;
    }
    const updatedUser = await User.findByIdAndUpdate(req.params.id, updates, { new: true }).populate('corporateAccount');
    if (!updatedUser) {
        return res.status(404).json({ error: 'User not found' });
    }
    let corporateAccountData = null;
    if (updatedUser.corporateAccount) {
        corporateAccountData = {
            id: updatedUser.corporateAccount._id,
            company_name: updatedUser.corporateAccount.companyName,
            email_domain: updatedUser.corporateAccount.emailDomain,
            discount_percentage: updatedUser.corporateAccount.discountPercentage,
            is_active: updatedUser.corporateAccount.isActive,
        };
    }
    const responseData = {
        id: updatedUser._id,
        username: updatedUser.username,
        email: updatedUser.email,
        phone_number: updatedUser.phoneNumber,
        is_staff: updatedUser.isAdmin,
        is_active: updatedUser.isVerified,
        is_verified: updatedUser.isVerified,
        corporate_account: corporateAccountData,
        date_joined: updatedUser.dateJoined.toISOString(),
    };
    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update user', details: error.message });
  }
});

// Delete a user
router.delete('/:id', adminAuth, async (req, res) => {
  try {
    await User.findByIdAndDelete(req.params.id);
    res.json({ message: 'User deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete user', details: error.message });
  }
});

module.exports = router;