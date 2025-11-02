/**
 * Middleware de autenticación
 */

const jwt = require('jsonwebtoken');
const { cache } = require('../config/redis');

// Verificar token JWT
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({ 
        error: 'Token no proporcionado',
        code: 'AUTH_NO_TOKEN'
      });
    }

    // Verificar token
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret-key');
    
    // Verificar si el usuario existe en Redis
    const userCache = await cache.get(`user:${decoded.userId}`);
    
    if (!userCache) {
      // Si no está en cache, el usuario podría haber sido deshabilitado
      return res.status(401).json({ 
        error: 'Usuario no autorizado',
        code: 'AUTH_INVALID_USER'
      });
    }

    // Agregar info del usuario al request
    req.user = {
      id: decoded.userId,
      email: decoded.email,
      ...userCache,
    };

    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(403).json({ 
        error: 'Token inválido',
        code: 'AUTH_INVALID_TOKEN'
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(403).json({ 
        error: 'Token expirado',
        code: 'AUTH_EXPIRED_TOKEN'
      });
    }

    return res.status(500).json({ 
      error: 'Error de autenticación',
      code: 'AUTH_ERROR'
    });
  }
};

// Verificar permisos específicos
const authorizeRole = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ 
        error: 'No autenticado',
        code: 'AUTH_NOT_AUTHENTICATED'
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ 
        error: 'No autorizado para esta acción',
        code: 'AUTH_INSUFFICIENT_PERMISSIONS'
      });
    }

    next();
  };
};

// Verificar si el usuario es dueño del negocio
const verifyBusinessOwner = async (req, res, next) => {
  try {
    const { businessId } = req.params;
    const { query } = require('../config/database');

    const result = await query(
      'SELECT user_id FROM negocios WHERE id = $1',
      [businessId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Negocio no encontrado',
        code: 'BUSINESS_NOT_FOUND'
      });
    }

    if (result.rows[0].user_id !== req.user.id) {
      return res.status(403).json({ 
        error: 'No eres el dueño de este negocio',
        code: 'BUSINESS_OWNERSHIP_DENIED'
      });
    }

    next();
  } catch (error) {
    console.error('Error verificando ownership:', error);
    return res.status(500).json({ 
      error: 'Error verificando permisos',
      code: 'BUSINESS_VERIFY_ERROR'
    });
  }
};

module.exports = {
  authenticateToken,
  authorizeRole,
  verifyBusinessOwner,
};

