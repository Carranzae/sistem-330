/**
 * Controlador de Productos
 */

const productService = require('../../services/product/product.service');
const { success, error, created, notFound } = require('../../utils/response.util');
const { asyncHandler } = require('../../middleware/error.middleware');

// GET /api/products
const getAllProducts = asyncHandler(async (req, res) => {
  const { businessId } = req.query;
  const products = await productService.getAllProducts(businessId);
  return success(res, products, 'Productos obtenidos exitosamente');
});

// GET /api/products/:id
const getProductById = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const product = await productService.getProductById(id);
  
  if (!product) {
    return notFound(res, 'Producto no encontrado');
  }
  
  return success(res, product, 'Producto obtenido exitosamente');
});

// POST /api/products
const createProduct = asyncHandler(async (req, res) => {
  const productData = req.body;
  const product = await productService.createProduct(productData);
  return created(res, product, 'Producto creado exitosamente');
});

// PUT /api/products/:id
const updateProduct = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const productData = req.body;
  const product = await productService.updateProduct(id, productData);
  return success(res, product, 'Producto actualizado exitosamente');
});

// DELETE /api/products/:id
const deleteProduct = asyncHandler(async (req, res) => {
  const { id } = req.params;
  await productService.deleteProduct(id);
  return success(res, null, 'Producto eliminado exitosamente');
});

// PUT /api/products/:id/stock
const adjustStock = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { quantity, operation } = req.body;
  
  if (!quantity) {
    return error(res, 'La cantidad es requerida', 400);
  }
  
  const product = await productService.adjustStock(id, quantity, operation || 'set');
  return success(res, product, 'Stock actualizado exitosamente');
});

// GET /api/products/low-stock
const getProductsWithLowStock = asyncHandler(async (req, res) => {
  const { businessId, threshold } = req.query;
  const products = await productService.getProductsWithLowStock(
    businessId, 
    threshold ? parseInt(threshold) : 10
  );
  return success(res, products, 'Productos con stock bajo obtenidos exitosamente');
});

module.exports = {
  getAllProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
  adjustStock,
  getProductsWithLowStock,
};

