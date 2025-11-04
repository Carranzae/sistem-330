/**
 * Configuración de Redis Cache
 */

const redis = require('redis');
require('dotenv').config();

let redisClient;
let connectionAttempted = false;

// Crear cliente Redis
const createRedisClient = async () => {
  try {
    const client = redis.createClient({
      url: process.env.REDIS_URL || 'redis://localhost:6379',
      socket: {
        reconnectStrategy: false, // No intentar reconectar
      },
    });

    // Silenciar errores de conexión
    client.on('error', () => {
      // Errores silenciados - se manejan en catch
    });
    client.on('connect', () => console.log('✅ Redis conectado'));

    await client.connect();
    connectionAttempted = true;
    return client;
  } catch (error) {
    // Solo mostrar una vez
    if (!connectionAttempted) {
      console.warn('⚠️  Redis no disponible - cache deshabilitado');
      connectionAttempted = true;
    }
    return null;
  }
};

// Inicializar Redis
const initRedis = async () => {
  redisClient = await createRedisClient();
};

// Get Redis client
const getRedisClient = () => {
  return redisClient;
};

// Cache helper
const cache = {
  get: async (key) => {
    if (!redisClient) return null;
    try {
      const value = await redisClient.get(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      console.error('Redis get error:', error);
      return null;
    }
  },
  
  set: async (key, value, expiration = 3600) => {
    if (!redisClient) return false;
    try {
      await redisClient.setEx(key, expiration, JSON.stringify(value));
      return true;
    } catch (error) {
      console.error('Redis set error:', error);
      return false;
    }
  },
  
  delete: async (key) => {
    if (!redisClient) return false;
    try {
      await redisClient.del(key);
      return true;
    } catch (error) {
      console.error('Redis delete error:', error);
      return false;
    }
  },
  
  clear: async (pattern) => {
    if (!redisClient) return false;
    try {
      const keys = await redisClient.keys(pattern);
      if (keys.length > 0) {
        await redisClient.del(keys);
      }
      return true;
    } catch (error) {
      console.error('Redis clear error:', error);
      return false;
    }
  },
};

module.exports = {
  initRedis,
  getRedisClient,
  cache,
};

