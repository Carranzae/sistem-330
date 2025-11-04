/**
 * Rutas de Clientes
 */

const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../../middleware/auth.middleware');
const { commonValidations, handleValidationErrors } = require('../../middleware/validator.middleware');
const clientService = require('../../services/client/client.service');
const { success, created } = require('../../utils/response.util');
const { asyncHandler } = require('../../middleware/error.middleware');

// GET /api/clients
const getAllClients = asyncHandler(async (req, res) => {
  const { businessId } = req.query;
  const clients = await clientService.getAllClients(businessId);
  return success(res, clients, 'Clientes obtenidos exitosamente');
});

// POST /api/clients
const createClient = asyncHandler(async (req, res) => {
  const clientData = req.body;
  const client = await clientService.createClient(clientData);
  return created(res, client, 'Cliente creado exitosamente');
});

router.get('/', getAllClients);
router.post('/', authenticateToken, handleValidationErrors, createClient);

module.exports = router;

