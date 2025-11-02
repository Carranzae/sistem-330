/**
 * Middleware de Rate Limiting
 */

const rateLimit = require('express-rate-limit');
const { RATE_LIMIT } = require('../config/constants');

// Rate limiter general
const generalLimiter = rateLimit({
  windowMs: RATE_LIMIT.WINDOW_MS,
  max: RATE_LIMIT.MAX_REQUESTS,
  message: {
    error: 'Demasiadas solicitudes, intenta más tarde',
    code: 'RATE_LIMIT_EXCEEDED'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// Rate limiter para login
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts
  message: {
    error: 'Demasiados intentos de login, intenta más tarde',
    code: 'LOGIN_RATE_LIMIT_EXCEEDED'
  },
  skipSuccessfulRequests: true,
});

// Rate limiter para operaciones pesadas
const heavyLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 10, // 10 requests
  message: {
    error: 'Demasiadas solicitudes, espera un momento',
    code: 'HEAVY_RATE_LIMIT_EXCEEDED'
  },
});

module.exports = {
  generalLimiter,
  loginLimiter,
  heavyLimiter,
};

