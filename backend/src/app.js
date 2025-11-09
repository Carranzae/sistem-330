/**
 * Aplicación principal del backend
 * Arquitectura empresarial con PostgreSQL y Redis
 */

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const bodyParser = require('body-parser');

// Config
const { initRedis } = require('./config/redis');
const logger = require('./services/logger/logger.service');

// Middleware
const { errorHandler, notFoundHandler } = require('./middleware/error.middleware');
const { generalLimiter } = require('./middleware/rateLimit.middleware');

// Initialize app
const app = express();

// Security middleware
app.use(helmet());

// CORS
app.use(cors({
  origin: process.env.FRONTEND_URL || '*',
  credentials: true,
}));

// Body parser
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Rate limiting
app.use('/api', generalLimiter);

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
  });
});

// API Routes
app.use('/api/auth', require('./routes/auth.routes'));
app.use('/api/businesses', require('./routes/businesses/businesses.routes'));
app.use('/api/products', require('./routes/products/products.routes'));
app.use('/api/sales', require('./routes/sales/sales.routes'));
app.use('/api/clients', require('./routes/clients/clients.routes'));
app.use('/api/dashboard', require('./routes/dashboard/dashboard.routes'));

// TODO: Agregar más rutas
// app.use('/api/security', require('./routes/security/security.routes'));

// Error handling
app.use(notFoundHandler);
app.use(errorHandler);

// Start server
const PORT = process.env.PORT || 3000;

const startServer = async () => {
  try {
    // Inicializar Redis
    await initRedis();
    
    // Iniciar servidor
    app.listen(PORT, () => {
      logger.info(`🚀 Servidor iniciado en puerto ${PORT}`);
      console.log(`╔═══════════════════════════════════════════════╗`);
      console.log(`║  Backend Multi-Negocio API                   ║`);
      console.log(`║  Puerto: ${PORT}                              ║`);
      console.log(`║  Ambiente: ${process.env.NODE_ENV || 'dev'}   ║`);
      console.log(`╚═══════════════════════════════════════════════╝`);
    });
  } catch (error) {
    logger.error('Error al iniciar servidor', { error: error.message });
    console.error('❌ Error al iniciar servidor:', error);
    process.exit(1);
  }
};

// Handle uncaught errors
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection', { reason, promise });
});

process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception', { error: error.message });
  process.exit(1);
});

// Start
startServer();

module.exports = app;

