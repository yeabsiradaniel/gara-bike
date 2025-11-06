const express = require('express');
const router = express.Router();
const CorporateAccount = require('../../models/CorporateAccount');
const adminAuth = require('../../middleware/adminAuth');

// Get all corporate accounts
router.get('/', adminAuth, async (req, res) => {
  try {
    const accounts = await CorporateAccount.find().sort({ companyName: 1 });
    const responseData = accounts.map(account => ({
        id: account._id,
        company_name: account.companyName,
        email_domain: account.emailDomain,
        discount_percentage: account.discountPercentage,
        is_active: account.isActive,
    }));
    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch corporate accounts', details: error.message });
  }
});

// Create a new corporate account
router.post('/', adminAuth, async (req, res) => {
  try {
    const account = new CorporateAccount(req.body);
    await account.save();
    const responseData = {
        id: account._id,
        company_name: account.companyName,
        email_domain: account.emailDomain,
        discount_percentage: account.discountPercentage,
        is_active: account.isActive,
    };
    res.status(201).json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create corporate account', details: error.message });
  }
});

// Update a corporate account
router.put('/:id', adminAuth, async (req, res) => {
  try {
    const updatedAccount = await CorporateAccount.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedAccount) {
        return res.status(404).json({ error: 'Corporate account not found' });
    }
    const responseData = {
        id: updatedAccount._id,
        company_name: updatedAccount.companyName,
        email_domain: updatedAccount.emailDomain,
        discount_percentage: updatedAccount.discountPercentage,
        is_active: updatedAccount.isActive,
    };
    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update corporate account', details: error.message });
  }
});

// Delete a corporate account
router.delete('/:id', adminAuth, async (req, res) => {
  try {
    await CorporateAccount.findByIdAndDelete(req.params.id);
    res.json({ message: 'Corporate account deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete corporate account', details: error.message });
  }
});

module.exports = router;