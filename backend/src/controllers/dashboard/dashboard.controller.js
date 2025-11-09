/**
 * Controlador de Dashboard
 */

const dashboardService = require('../../services/dashboard/dashboard.service');
const { success, error } = require('../../utils/response.util');
const { asyncHandler } = require('../../middleware/error.middleware');

// GET /api/dashboard/stats
const getDashboardStats = asyncHandler(async (req, res) => {
  const { businessId } = req.query;
  
  if (!businessId) {
    return error(res, 'businessId es requerido', 400);
  }
  
  const stats = await dashboardService.getDashboardStats(businessId);
  return success(res, stats, 'Estadísticas obtenidas exitosamente');
});

// GET /api/dashboard/alerts
const getCriticalAlerts = asyncHandler(async (req, res) => {
  const { businessId } = req.query;
  
  if (!businessId) {
    return error(res, 'businessId es requerido', 400);
  }
  
  const alerts = await dashboardService.getCriticalAlerts(businessId);
  return success(res, alerts, 'Alertas obtenidas exitosamente');
});

module.exports = {
  getDashboardStats,
  getCriticalAlerts,
};


