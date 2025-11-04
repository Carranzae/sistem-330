/**
 * Rutas de Ventas
 */

const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../../middleware/auth.middleware');
const { commonValidations, handleValidationErrors } = require('../../middleware/validator.middleware');
const saleService = require('../../services/sale/sale.service');
const { success, created } = require('../../utils/response.util');
const { asyncHandler } = require('../../middleware/error.middleware');

// GET /api/sales
const getAllSales = asyncHandler(async (req, res) => {
  const { businessId } = req.query;
  const sales = await saleService.getAllSales(businessId);
  return success(res, sales, 'Ventas obtenidas exitosamente');
});

// GET /api/sales/:id
const getSaleById = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const sale = await saleService.getSaleById(id);
  return success(res, sale, 'Venta obtenida exitosamente');
});

// POST /api/sales
const createSale = asyncHandler(async (req, res) => {
  const saleData = req.body;
  const sale = await saleService.createSale(saleData);
  return created(res, sale, 'Venta creada exitosamente');
});

router.get('/', getAllSales);
router.get('/:id', commonValidations.uuid, handleValidationErrors, getSaleById);
router.post('/', authenticateToken, commonValidations.createSale, handleValidationErrors, createSale);

module.exports = router;

