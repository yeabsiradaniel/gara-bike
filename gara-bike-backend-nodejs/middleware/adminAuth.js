const jwt = require('jsonwebtoken');
const User = require('../models/User');

module.exports = async (req, res, next) => {
  try {
    const token = req.headers.authorization.split(' ')[1];
    const decodedToken = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decodedToken.userId);

    if (!user || !user.isAdmin) {
      return res.status(403).json({ error: 'Forbidden: Admins only' });
    }

    req.userData = { userId: decodedToken.userId, isAdmin: user.isAdmin };
    next();
  } catch (error) {
    res.status(401).json({ error: 'Authentication failed' });
  }
};