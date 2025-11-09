/**
 * Rutas de Dashboard
 */

const express = require('express');
const router = express.Router();
const dashboardController = require('../../controllers/dashboard/dashboard.controller');
const { authenticateToken } = require('../../middleware/auth.middleware');

// GET /api/dashboard/stats
router.get('/stats', 
  authenticateToken,
  dashboardController.getDashboardStats
);

// GET /api/dashboard/alerts
router.get('/alerts', 
  authenticateToken,
  dashboardController.getCriticalAlerts
);

module.exports = router;


