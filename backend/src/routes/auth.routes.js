/**
 * Rutas de autenticación
 */

const express = require('express');
const router = express.Router();
const { loginLimiter } = require('../middleware/rateLimit.middleware');
const { body, validationResult } = require('express-validator');
const { success, error } = require('../utils/response.util');
const authService = require('../services/auth/auth.service');

// Login
router.post('/login', 
  loginLimiter,
  [
    body('email').isEmail().withMessage('Email inválido'),
    body('password').notEmpty().withMessage('Password requerido'),
  ],
  async (req, res) => {
    try {
      // Validar
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ 
          success: false,
          error: 'Error de validación',
          details: errors.array() 
        });
      }

      const { email, password } = req.body;

      // Login
      const result = await authService.loginUser(email, password);

      return success(res, result, 'Login exitoso');
    } catch (err) {
      return error(res, err.message, 401);
    }
  }
);

// Register
router.post('/register',
  [
    body('email').isEmail().withMessage('Email inválido'),
    body('password').isLength({ min: 6 }).withMessage('Password debe tener al menos 6 caracteres'),
    body('nombre_completo').optional().trim(),
  ],
  async (req, res) => {
    try {
      // Validar
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ 
          success: false,
          error: 'Error de validación',
          details: errors.array() 
        });
      }

      const { email, password, nombre_completo } = req.body;

      // Registrar
      const result = await authService.registerUser(email, password, { nombre_completo });

      return success(res, result, 'Usuario registrado exitosamente');
    } catch (err) {
      return error(res, err.message, 400);
    }
  }
);

module.exports = router;

