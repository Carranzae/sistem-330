/**
 * Rutas de Negocios
 */

const express = require('express');
const router = express.Router();
const businessController = require('../../controllers/business/business.controller');
const { authenticateToken } = require('../../middleware/auth.middleware');
const { commonValidations, handleValidationErrors } = require('../../middleware/validator.middleware');

// GET /api/businesses
router.get('/', businessController.getAllBusinesses);

// GET /api/businesses/:id
router.get('/:id', 
  commonValidations.uuid,
  handleValidationErrors,
  businessController.getBusinessById
);

// POST /api/businesses
router.post('/', 
  authenticateToken,
  commonValidations.createBusiness,
  handleValidationErrors,
  businessController.createBusiness
);

// PUT /api/businesses/:id
router.put('/:id', 
  authenticateToken,
  commonValidations.uuid,
  handleValidationErrors,
  businessController.updateBusiness
);

// DELETE /api/businesses/:id
router.delete('/:id', 
  authenticateToken,
  commonValidations.uuid,
  handleValidationErrors,
  businessController.deleteBusiness
);

module.exports = router;

