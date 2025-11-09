/**
 * Servicio de Dashboard
 * Estadísticas en tiempo real para Abarrotes y Bodega
 */

const { query } = require('../../config/database');
const logger = require('../logger/logger.service');

// Dashboard general con métricas principales
const getDashboardStats = async (businessId) => {
  try {
    // Ventas del día
    const todaySales = await query(
      `SELECT 
        COUNT(*) as total_ventas,
        COALESCE(SUM(total), 0) as total_monto,
        COUNT(DISTINCT DATE(created_at)) as dias_activos
      FROM ventas 
      WHERE negocio_id = $1 
      AND DATE(created_at) = CURRENT_DATE`,
      [businessId]
    );

    // Ventas del mes
    const monthSales = await query(
      `SELECT 
        COUNT(*) as total_ventas,
        COALESCE(SUM(total), 0) as total_monto
      FROM ventas 
      WHERE negocio_id = $1 
      AND DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE)`,
      [businessId]
    );

    // Productos totales
    const totalProducts = await query(
      `SELECT COUNT(*) as total FROM productos WHERE negocio_id = $1`,
      [businessId]
    );

    // Productos con stock
    const productsInStock = await query(
      `SELECT COUNT(*) as total FROM productos WHERE negocio_id = $1 AND stock > 0`,
      [businessId]
    );

    // Productos con stock bajo (menor o igual a 10)
    const lowStockProducts = await query(
      `SELECT COUNT(*) as total FROM productos WHERE negocio_id = $1 AND stock <= 10 AND stock > 0`,
      [businessId]
    );

    // Productos sin stock
    const outOfStock = await query(
      `SELECT COUNT(*) as total FROM productos WHERE negocio_id = $1 AND stock = 0`,
      [businessId]
    );

    // Clientes totales
    const totalClients = await query(
      `SELECT COUNT(*) as total FROM clientes WHERE negocio_id = $1`,
      [businessId]
    );

    // Clientes con deuda
    const clientsWithDebt = await query(
      `SELECT COUNT(*) as total FROM clientes WHERE negocio_id = $1 AND deuda_actual > 0`,
      [businessId]
    );

    // Top 5 productos más vendidos (últimos 30 días)
    const topProducts = await query(
      `SELECT 
        p.id,
        p.nombre,
        p.categoria,
        COUNT(vp.producto_id) as veces_vendido,
        SUM(vp.cantidad) as unidades_vendidas
      FROM productos p
      INNER JOIN ventas v ON v.negocio_id = p.negocio_id
      CROSS JOIN LATERAL json_array_elements(v.productos) as vp
      WHERE p.negocio_id = $1
      AND v.created_at >= NOW() - INTERVAL '30 days'
      GROUP BY p.id, p.nombre, p.categoria
      ORDER BY veces_vendido DESC
      LIMIT 5`,
      [businessId]
    );

    // Ventas por método de pago (hoy)
    const salesByMethod = await query(
      `SELECT 
        metodo_pago,
        COUNT(*) as cantidad,
        SUM(total) as total_monto
      FROM ventas 
      WHERE negocio_id = $1 
      AND DATE(created_at) = CURRENT_DATE
      GROUP BY metodo_pago
      ORDER BY cantidad DESC`,
      [businessId]
    );

    // Ventas de los últimos 7 días para gráfico
    const last7Days = await query(
      `SELECT 
        DATE(created_at) as fecha,
        COUNT(*) as total_ventas,
        SUM(total) as total_monto
      FROM ventas 
      WHERE negocio_id = $1 
      AND created_at >= NOW() - INTERVAL '7 days'
      GROUP BY DATE(created_at)
      ORDER BY DATE(created_at) ASC`,
      [businessId]
    );

    // Cálculo de tendencia (comparar con mes anterior)
    const lastMonthSales = await query(
      `SELECT COALESCE(SUM(total), 0) as total_monto
      FROM ventas 
      WHERE negocio_id = $1 
      AND DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')`,
      [businessId]
    );

    const currentMonthSales = monthSales.rows[0]?.total_monto || 0;
    const previousMonthSales = lastMonthSales.rows[0]?.total_monto || 0;
    
    let salesGrowth = 0;
    if (previousMonthSales > 0) {
      salesGrowth = ((currentMonthSales - previousMonthSales) / previousMonthSales) * 100;
    } else if (currentMonthSales > 0) {
      salesGrowth = 100;
    }

    return {
      sales: {
        today: {
          count: parseInt(todaySales.rows[0]?.total_ventas || 0),
          amount: parseFloat(todaySales.rows[0]?.total_monto || 0),
        },
        month: {
          count: parseInt(monthSales.rows[0]?.total_ventas || 0),
          amount: parseFloat(monthSales.rows[0]?.total_monto || 0),
        },
        growth: parseFloat(salesGrowth.toFixed(2)),
        byMethod: salesByMethod.rows.map(row => ({
          method: row.metodo_pago,
          count: parseInt(row.cantidad),
          amount: parseFloat(row.total_monto || 0),
        })),
        last7Days: last7Days.rows.map(row => ({
          date: row.fecha.toISOString().split('T')[0],
          count: parseInt(row.total_ventas),
          amount: parseFloat(row.total_monto || 0),
        })),
      },
      inventory: {
        total: parseInt(totalProducts.rows[0]?.total || 0),
        inStock: parseInt(productsInStock.rows[0]?.total || 0),
        lowStock: parseInt(lowStockProducts.rows[0]?.total || 0),
        outOfStock: parseInt(outOfStock.rows[0]?.total || 0),
      },
      clients: {
        total: parseInt(totalClients.rows[0]?.total || 0),
        withDebt: parseInt(clientsWithDebt.rows[0]?.total || 0),
      },
      topProducts: topProducts.rows.map(row => ({
        id: row.id,
        name: row.nombre,
        category: row.categoria,
        timesSold: parseInt(row.veces_vendido || 0),
        unitsSold: parseInt(row.unidades_vendidas || 0),
      })),
    };
  } catch (error) {
    logger.error('Error obteniendo estadísticas del dashboard', { error: error.message });
    throw error;
  }
};

// Alertas críticas
const getCriticalAlerts = async (businessId) => {
  try {
    const alerts = [];

    // Productos sin stock
    const outOfStock = await query(
      `SELECT id, nombre, categoria FROM productos 
      WHERE negocio_id = $1 AND stock = 0
      LIMIT 10`,
      [businessId]
    );

    if (outOfStock.rows.length > 0) {
      alerts.push({
        type: 'out_of_stock',
        severity: 'critical',
        title: 'Productos Sin Stock',
        message: `${outOfStock.rows.length} productos sin stock`,
        count: outOfStock.rows.length,
        items: outOfStock.rows,
      });
    }

    // Productos con stock bajo
    const lowStock = await query(
      `SELECT id, nombre, stock, categoria FROM productos 
      WHERE negocio_id = $1 AND stock > 0 AND stock <= 10
      ORDER BY stock ASC
      LIMIT 10`,
      [businessId]
    );

    if (lowStock.rows.length > 0) {
      alerts.push({
        type: 'low_stock',
        severity: 'warning',
        title: 'Stock Bajo',
        message: `${lowStock.rows.length} productos requieren reposición`,
        count: lowStock.rows.length,
        items: lowStock.rows.map(row => ({
          id: row.id,
          nombre: row.nombre,
          stock: row.stock,
          categoria: row.categoria,
        })),
      });
    }

    // Clientes morosos críticos (más de 60 días)
    const delinquentClients = await query(
      `SELECT id, nombre_completo, deuda_actual, dias_mora
      FROM clientes 
      WHERE negocio_id = $1 AND deuda_actual > 0 AND dias_mora > 60
      ORDER BY deuda_actual DESC
      LIMIT 10`,
      [businessId]
    );

    if (delinquentClients.rows.length > 0) {
      alerts.push({
        type: 'delinquent_clients',
        severity: 'warning',
        title: 'Clientes Morosos Críticos',
        message: `${delinquentClients.rows.length} clientes con más de 60 días de mora`,
        count: delinquentClients.rows.length,
        items: delinquentClients.rows.map(row => ({
          id: row.id,
          nombre: row.nombre_completo,
          deuda: parseFloat(row.deuda_actual || 0),
          diasMora: parseInt(row.dias_mora || 0),
        })),
      });
    }

    return alerts;
  } catch (error) {
    logger.error('Error obteniendo alertas críticas', { error: error.message });
    throw error;
  }
};

module.exports = {
  getDashboardStats,
  getCriticalAlerts,
};


