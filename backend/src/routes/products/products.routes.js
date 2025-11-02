/**
 * Rutas de Productos
 */

const express = require('express');
const router = express.Router();
const productController = require('../../controllers/product/product.controller');
const { authenticateToken } = require('../../middleware/auth.middleware');
const { commonValidations, handleValidationErrors } = require('../../middleware/validator.middleware');

// GET /api/products
router.get('/', productController.getAllProducts);

// GET /api/products/:id
router.get('/:id', 
  commonValidations.uuid,
  handleValidationErrors,
  productController.getProductById
);

// POST /api/products
router.post('/', 
  authenticateToken,
  commonValidations.createProduct,
  handleValidationErrors,
  productController.createProduct
);

// PUT /api/products/:id
router.put('/:id', 
  authenticateToken,
  commonValidations.uuid,
  handleValidationErrors,
  productController.updateProduct
);

// DELETE /api/products/:id
router.delete('/:id', 
  authenticateToken,
  commonValidations.uuid,
  handleValidationErrors,
  productController.deleteProduct
);

module.exports = router;

