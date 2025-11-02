/**
 * Middleware de validación de datos
 */

const { body, param, query, validationResult } = require('express-validator');

// Handler para errores de validación
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Error de validación',
      code: 'VALIDATION_ERROR',
      details: errors.array()
    });
  }
  
  next();
};

// Validaciones comunes
const commonValidations = {
  // UUID
  uuid: [
    param('id').isUUID().withMessage('ID debe ser un UUID válido')
  ],
  
  // Business ID
  businessId: [
    param('businessId').isUUID().withMessage('Business ID debe ser un UUID válido')
  ],
  
  // Pagination
  pagination: [
    query('page').optional().isInt({ min: 1 }).withMessage('Page debe ser un número mayor a 0'),
    query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit debe ser entre 1 y 100')
  ],
  
  // Business creation
  createBusiness: [
    body('nombre_comercial').trim().notEmpty().withMessage('Nombre comercial es requerido'),
    body('pais').trim().notEmpty().withMessage('País es requerido'),
    body('rubro').trim().notEmpty().withMessage('Rubro es requerido'),
    body('categoria').isIn(['abarrotes', 'ropa_calzado', 'hogar_decoracion', 'electronica', 'verduleria', 'papa_mayorista', 'carniceria', 'ferreteria', 'farmacia', 'restaurante', 'mayorista', 'otro']).withMessage('Categoría inválida')
  ],
  
  // Product creation
  createProduct: [
    body('nombre').trim().notEmpty().withMessage('Nombre es requerido'),
    body('precio').isFloat({ min: 0 }).withMessage('Precio debe ser un número positivo'),
    body('stock').isInt({ min: 0 }).withMessage('Stock debe ser un número entero positivo')
  ],
  
  // Sale creation
  createSale: [
    body('productos').isArray({ min: 1 }).withMessage('Debe haber al menos un producto'),
    body('productos.*.producto_id').isUUID().withMessage('Producto ID inválido'),
    body('productos.*.cantidad').isInt({ min: 1 }).withMessage('Cantidad debe ser mayor a 0'),
    body('metodo_pago').isIn(['efectivo', 'yape', 'plin', 'tarjeta', 'credito']).withMessage('Método de pago inválido')
  ],
};

module.exports = {
  handleValidationErrors,
  commonValidations,
};

