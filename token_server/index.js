const express = require('express');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 8080;

// Enable CORS for Flutter Web / Desktop client lookups
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  next();
});

// GET /token endpoint
app.get('/token', (req, res) => {
  const { userId, role } = req.query;

  if (!userId || !role) {
    console.error(`[${new Date().toISOString()}] [TOKEN] [ERROR] Missing userId or role in request query parameters`);
    return res.status(400).json({
      error: 'Missing query parameters. Make sure to supply ?userId=&role='
    });
  }

  // Complying with 100ms standard mock dev approaching format
  const mockToken = `mock_100ms_token_for_${userId}_as_${role}_${Date.now()}`;

  console.log(`[${new Date().toISOString()}] [TOKEN] [INFO] Generated 100ms auth token for user "${userId}" with role "${role}"`);

  return res.json({
    token: mockToken
  });
});

// Start listening
app.listen(PORT, () => {
  console.log(`================================================================`);
  console.log(` WTF 100ms Token Server running on http://localhost:${PORT}`);
  console.log(` GET Endpoint: http://localhost:${PORT}/token?userId=DK&role=member`);
  console.log(`================================================================`);
});
