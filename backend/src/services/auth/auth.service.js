/**
 * Servicio de Autenticación
 */

const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { query } = require('../../config/database');
const { cache } = require('../../config/redis');
const logger = require('../logger/logger.service');

// Generar token JWT
const generateToken = (userId, email) => {
  return jwt.sign(
    { userId, email },
    process.env.JWT_SECRET || 'secret-key',
    { expiresIn: '24h' }
  );
};

// Registrar usuario
const registerUser = async (email, password, userData = {}) => {
  try {
    // Verificar si el usuario ya existe
    const existingUser = await query(
      'SELECT id FROM usuarios WHERE email = $1',
      [email.toLowerCase()]
    );

    if (existingUser.rows.length > 0) {
      throw new Error('Usuario ya existe');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Crear usuario
    const result = await query(
      `INSERT INTO usuarios (email, password_hash, nombre_completo, activo, created_at)
       VALUES ($1, $2, $3, $4, NOW())
       RETURNING id, email, nombre_completo, activo, created_at`,
      [
        email.toLowerCase(),
        hashedPassword,
        userData.nombre_completo || null,
        true
      ]
    );

    const user = result.rows[0];

    // Guardar en cache
    await cache.set(`user:${user.id}`, {
      email: user.email,
      nombre_completo: user.nombre_completo,
      activo: user.activo,
    }, 3600 * 24); // 24 horas

    logger.info('Usuario registrado', { userId: user.id, email: user.email });

    // Generar token
    const token = generateToken(user.id, user.email);

    return {
      user: {
        id: user.id,
        email: user.email,
        nombre_completo: user.nombre_completo,
      },
      token,
    };
  } catch (error) {
    logger.error('Error registrando usuario', { error: error.message });
    throw error;
  }
};

// Login
const loginUser = async (email, password) => {
  try {
    // Buscar usuario
    const result = await query(
      'SELECT * FROM usuarios WHERE email = $1',
      [email.toLowerCase()]
    );

    if (result.rows.length === 0) {
      throw new Error('Credenciales inválidas');
    }

    const user = result.rows[0];

    // Verificar password
    const isValidPassword = await bcrypt.compare(password, user.password_hash);

    if (!isValidPassword) {
      throw new Error('Credenciales inválidas');
    }

    // Verificar si está activo
    if (!user.activo) {
      throw new Error('Usuario desactivado');
    }

    // Guardar en cache
    await cache.set(`user:${user.id}`, {
      email: user.email,
      nombre_completo: user.nombre_completo,
      activo: user.activo,
    }, 3600 * 24); // 24 horas

    logger.info('Usuario logueado', { userId: user.id, email: user.email });

    // Generar token
    const token = generateToken(user.id, user.email);

    return {
      user: {
        id: user.id,
        email: user.email,
        nombre_completo: user.nombre_completo,
      },
      token,
    };
  } catch (error) {
    logger.error('Error en login', { error: error.message, email });
    throw error;
  }
};

// Logout
const logoutUser = async (userId) => {
  try {
    // Eliminar de cache
    await cache.delete(`user:${userId}`);
    
    logger.info('Usuario deslogueado', { userId });
  } catch (error) {
    logger.error('Error en logout', { error: error.message });
    throw error;
  }
};

// Obtener usuario por ID
const getUserById = async (userId) => {
  try {
    const result = await query(
      'SELECT id, email, nombre_completo, activo, created_at FROM usuarios WHERE id = $1',
      [userId]
    );

    return result.rows[0] || null;
  } catch (error) {
    logger.error('Error obteniendo usuario', { error: error.message });
    throw error;
  }
};

module.exports = {
  registerUser,
  loginUser,
  logoutUser,
  getUserById,
  generateToken,
};

