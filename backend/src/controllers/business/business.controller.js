/**
 * Controlador de Negocios
 */

const businessService = require('../../services/business/business.service');
const { success, error, created, notFound } = require('../../utils/response.util');
const { asyncHandler } = require('../../middleware/error.middleware');

// GET /api/businesses
const getAllBusinesses = asyncHandler(async (req, res) => {
  const businesses = await businessService.getAllBusinesses();
  return success(res, businesses, 'Negocios obtenidos exitosamente');
});

// GET /api/businesses/:id
const getBusinessById = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const business = await businessService.getBusinessById(id);
  
  if (!business) {
    return notFound(res, 'Negocio no encontrado');
  }
  
  return success(res, business, 'Negocio obtenido exitosamente');
});

// POST /api/businesses
const createBusiness = asyncHandler(async (req, res) => {
  const businessData = req.body;
  const business = await businessService.createBusiness(businessData);
  return created(res, business, 'Negocio creado exitosamente');
});

// PUT /api/businesses/:id
const updateBusiness = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const businessData = req.body;
  const business = await businessService.updateBusiness(id, businessData);
  return success(res, business, 'Negocio actualizado exitosamente');
});

// DELETE /api/businesses/:id
const deleteBusiness = asyncHandler(async (req, res) => {
  const { id } = req.params;
  await businessService.deleteBusiness(id);
  return success(res, null, 'Negocio eliminado exitosamente');
});

module.exports = {
  getAllBusinesses,
  getBusinessById,
  createBusiness,
  updateBusiness,
  deleteBusiness,
};

