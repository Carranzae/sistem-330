/**
 * Servicio de Ventas
 * Usa PostgreSQL directo (NO Supabase)
 */

const { query } = require('../../config/database');
const logger = require('../logger/logger.service');
const { updateMultipleStocks } = require('../product/product.service');

// Obtener todas las ventas
const getAllSales = async (businessId = null) => {
  try {
    let sql = 'SELECT * FROM ventas';
    let params = [];
    
    if (businessId) {
      sql += ' WHERE negocio_id = $1';
      params.push(businessId);
    }
    
    sql += ' ORDER BY created_at DESC';
    
    const result = await query(sql, params);
    return result.rows;
  } catch (error) {
    logger.error('Error obteniendo ventas', { error: error.message });
    throw error;
  }
};

// Obtener venta por ID
const getSaleById = async (saleId) => {
  try {
    const result = await query(
      'SELECT * FROM ventas WHERE id = $1',
      [saleId]
    );
    
    if (result.rows.length === 0) {
      return null;
    }
    
    return result.rows[0];
  } catch (error) {
    logger.error('Error obteniendo venta', { error: error.message, saleId });
    throw error;
  }
};

// Crear venta
const createSale = async (saleData) => {
  try {
    const {
      negocio_id,
      cliente_id,
      productos,
      total,
      subtotal,
      impuestos,
      descuento,
      metodo_pago,
      estado,
      notas,
    } = saleData;

    // Verificar y actualizar stock antes de crear la venta
    if (productos && Array.isArray(productos) && productos.length > 0) {
      await updateMultipleStocks(productos);
    }

    const result = await query(
      `INSERT INTO ventas (
        negocio_id, cliente_id, productos, total, subtotal,
        impuestos, descuento, metodo_pago, estado, notas, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW())
      RETURNING *`,
      [
        negocio_id,
        cliente_id,
        productos ? JSON.stringify(productos) : null,
        total,
        subtotal,
        impuestos,
        descuento,
        metodo_pago,
        estado || 'completada',
        notas,
      ]
    );
    
    const sale = result.rows[0];
    logger.info('Venta creada', { saleId: sale.id, total: sale.total });
    
    return sale;
  } catch (error) {
    logger.error('Error creando venta', { error: error.message });
    throw error;
  }
};

// Actualizar venta
const updateSale = async (saleId, saleData) => {
  try {
    const fields = [];
    const values = [];
    let paramCount = 1;

    Object.keys(saleData).forEach((key) => {
      if (saleData[key] !== undefined) {
        fields.push(`${key} = $${paramCount}`);
        if (typeof saleData[key] === 'object') {
          values.push(JSON.stringify(saleData[key]));
        } else {
          values.push(saleData[key]);
        }
        paramCount++;
      }
    });

    values.push(saleId);
    fields.push(`updated_at = NOW()`);

    const sql = `UPDATE ventas SET ${fields.join(', ')} WHERE id = $${paramCount} RETURNING *`;
    
    const result = await query(sql, values);
    
    logger.info('Venta actualizada', { saleId });
    return result.rows[0];
  } catch (error) {
    logger.error('Error actualizando venta', { error: error.message, saleId });
    throw error;
  }
};

// Cancelar venta (anular)
const cancelSale = async (saleId) => {
  try {
    const result = await query(
      `UPDATE ventas 
       SET estado = 'cancelada', 
           fecha_cancelacion = NOW(),
           updated_at = NOW() 
       WHERE id = $1 
       RETURNING *`,
      [saleId]
    );
    
    logger.info('Venta cancelada', { saleId });
    return result.rows[0];
  } catch (error) {
    logger.error('Error cancelando venta', { error: error.message, saleId });
    throw error;
  }
};

module.exports = {
  getAllSales,
  getSaleById,
  createSale,
  updateSale,
  cancelSale,
};
