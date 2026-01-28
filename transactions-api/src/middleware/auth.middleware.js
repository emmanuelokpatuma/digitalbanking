const axios = require('axios');

const AUTH_API_URL = process.env.AUTH_API_URL || 'http://localhost:3001';

const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    // Verify token with auth service
    const response = await axios.get(`${AUTH_API_URL}/api/auth/verify`, {
      headers: { Authorization: authHeader }
    });

    req.user = response.data.user;
    next();
  } catch (error) {
    if (error.response?.status === 401) {
      return res.status(401).json({ error: 'Invalid or expired token' });
    }
    console.error('Authentication error:', error.message);
    return res.status(500).json({ error: 'Authentication failed' });
  }
};

module.exports = { authenticate };
