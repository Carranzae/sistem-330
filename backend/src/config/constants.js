/**
 * Constantes de la aplicación
 */

module.exports = {
  // API Version
  API_VERSION: 'v1',
  
  // Pagination
  DEFAULT_PAGE_SIZE: 20,
  MAX_PAGE_SIZE: 100,
  
  // Cache TTL (in seconds)
  CACHE_TTL: {
    SHORT: 60,      // 1 minute
    MEDIUM: 300,    // 5 minutes
    LONG: 3600,     // 1 hour
    DAY: 86400,     // 24 hours
  },
  
  // JWT
  JWT_EXPIRY: '24h',
  
  // Rate limiting
  RATE_LIMIT: {
    WINDOW_MS: 15 * 60 * 1000,  // 15 minutes
    MAX_REQUESTS: 100,           // 100 requests per window
  },
  
  // Business categories
  CATEGORIES: [
    'abarrotes',
    'ropa_calzado',
    'hogar_decoracion',
    'electronica',
    'verduleria',
    'papa_mayorista',
    'carniceria',
    'ferreteria',
    'farmacia',
    'restaurante',
    'mayorista',
    'otro',
  ],
  
  // Payment methods
  PAYMENT_METHODS: [
    'efectivo',
    'yape',
    'plin',
    'tarjeta',
    'credito',
  ],
  
  // Sale status
  SALE_STATUS: {
    PENDING: 'pendiente',
    COMPLETED: 'completada',
    CANCELLED: 'cancelada',
    REFUNDED: 'reembolsada',
  },
  
  // Inventory operation types
  INVENTORY_OPERATIONS: {
    SALE: 'venta',
    PURCHASE: 'compra',
    ADJUSTMENT: 'ajuste',
    RETURN: 'devolucion',
    LOSS: 'merma',
  },
  
  // Security
  SECURITY: {
    MAX_LOGIN_ATTEMPTS: 5,
    BLOCK_DURATION_MINUTES: 30,
    TOKEN_EXPIRY_MINUTES: 60,
  },
};

