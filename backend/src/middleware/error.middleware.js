/**
 * Middleware de manejo de errores
 */

const logger = require('../services/logger/logger.service');

const errorHandler = (err, req, res, next) => {
  // Log del error
  logger.error('Error en API', {
    message: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method,
    ip: req.ip,
    user: req.user?.id || 'anonymous',
  });

  // Error de base de datos
  if (err.code && err.code.startsWith('23')) {
    return res.status(400).json({
      error: 'Error de integridad de datos',
      message: process.env.NODE_ENV === 'development' ? err.message : 'Datos duplicados o inválidos',
      code: 'DB_INTEGRITY_ERROR'
    });
  }

  // Error de validación
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      error: 'Error de validación',
      message: err.message,
      code: 'VALIDATION_ERROR',
      details: err.details || []
    });
  }

  // Error JWT
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({
      error: 'Token inválido',
      code: 'AUTH_INVALID_TOKEN'
    });
  }

  // Error por defecto
  const statusCode = err.statusCode || 500;
  const message = statusCode === 500 
    ? 'Error interno del servidor' 
    : err.message;

  res.status(statusCode).json({
    error: message,
    code: err.code || 'INTERNAL_ERROR',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
};

// Not found handler
const notFoundHandler = (req, res, next) => {
  res.status(404).json({
    error: 'Endpoint no encontrado',
    code: 'NOT_FOUND',
    path: req.path
  });
};

// Async handler wrapper
const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

module.exports = {
  errorHandler,
  notFoundHandler,
  asyncHandler,
};

