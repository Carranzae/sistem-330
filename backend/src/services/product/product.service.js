/**
 * Servicio de Productos
 * Usa PostgreSQL directo (NO Supabase)
 */

const { query } = require('../../config/database');
const logger = require('../logger/logger.service');

// Obtener todos los productos
const getAllProducts = async (businessId = null) => {
  try {
    let sql = 'SELECT * FROM productos';
    let params = [];
    
    if (businessId) {
      sql += ' WHERE negocio_id = $1';
      params.push(businessId);
    }
    
    sql += ' ORDER BY created_at DESC';
    
    const result = await query(sql, params);
    return result.rows;
  } catch (error) {
    logger.error('Error obteniendo productos', { error: error.message });
    throw error;
  }
};

// Obtener producto por ID
const getProductById = async (productId) => {
  try {
    const result = await query(
      'SELECT * FROM productos WHERE id = $1',
      [productId]
    );
    
    if (result.rows.length === 0) {
      return null;
    }
    
    return result.rows[0];
  } catch (error) {
    logger.error('Error obteniendo producto', { error: error.message, productId });
    throw error;
  }
};

// Crear producto
const createProduct = async (productData) => {
  try {
    const {
      negocio_id,
      nombre,
      precio,
      stock,
      categoria,
      descripcion,
      codigo_barras,
      atributos,
    } = productData;

    const result = await query(
      `INSERT INTO productos (
        negocio_id, nombre, precio, stock, categoria, 
        descripcion, codigo_barras, atributos, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())
      RETURNING *`,
      [
        negocio_id,
        nombre,
        precio,
        stock,
        categoria,
        descripcion,
        codigo_barras,
        atributos ? JSON.stringify(atributos) : null,
      ]
    );
    
    const product = result.rows[0];
    logger.info('Producto creado', { productId: product.id, nombre: product.nombre });
    return product;
  } catch (error) {
    logger.error('Error creando producto', { error: error.message });
    throw error;
  }
};

// Actualizar producto
const updateProduct = async (productId, productData) => {
  try {
    const fields = [];
    const values = [];
    let paramCount = 1;

    Object.keys(productData).forEach((key) => {
      if (productData[key] !== undefined) {
        fields.push(`${key} = $${paramCount}`);
        if (typeof productData[key] === 'object') {
          values.push(JSON.stringify(productData[key]));
        } else {
          values.push(productData[key]);
        }
        paramCount++;
      }
    });

    values.push(productId);
    fields.push(`updated_at = NOW()`);

    const sql = `UPDATE productos SET ${fields.join(', ')} WHERE id = $${paramCount} RETURNING *`;
    
    const result = await query(sql, values);
    
    logger.info('Producto actualizado', { productId });
    return result.rows[0];
  } catch (error) {
    logger.error('Error actualizando producto', { error: error.message, productId });
    throw error;
  }
};

// Eliminar producto
const deleteProduct = async (productId) => {
  try {
    await query('DELETE FROM productos WHERE id = $1', [productId]);
    logger.info('Producto eliminado', { productId });
    return true;
  } catch (error) {
    logger.error('Error eliminando producto', { error: error.message, productId });
    throw error;
  }
};

// Ajustar stock de un producto (sumar o restar)
const adjustStock = async (productId, quantity, operation = 'add') => {
  try {
    let sql;
    
    if (operation === 'add') {
      // Sumar stock
      sql = `UPDATE productos 
             SET stock = stock + $1, updated_at = NOW() 
             WHERE id = $2 
             RETURNING *`;
    } else if (operation === 'subtract') {
      // Restar stock
      sql = `UPDATE productos 
             SET stock = GREATEST(stock - $1, 0), updated_at = NOW() 
             WHERE id = $2 
             RETURNING *`;
    } else if (operation === 'set') {
      // Establecer stock específico
      sql = `UPDATE productos 
             SET stock = $1, updated_at = NOW() 
             WHERE id = $2 
             RETURNING *`;
    } else {
      throw new Error('Operación no válida. Use: add, subtract o set');
    }
    
    const result = await query(sql, [quantity, productId]);
    
    if (result.rows.length === 0) {
      throw new Error('Producto no encontrado');
    }
    
    logger.info('Stock ajustado', { productId, quantity, operation });
    return result.rows[0];
  } catch (error) {
    logger.error('Error ajustando stock', { error: error.message, productId, quantity, operation });
    throw error;
  }
};

// Actualizar stock de múltiples productos (para ventas)
const updateMultipleStocks = async (products) => {
  try {
    const updates = [];
    
    for (const product of products) {
      const { producto_id, cantidad } = product;
      
      // Verificar que hay suficiente stock
      const productData = await getProductById(producto_id);
      if (!productData) {
        throw new Error(`Producto ${producto_id} no encontrado`);
      }
      
      if (productData.stock < cantidad) {
        throw new Error(`Stock insuficiente para ${productData.nombre}. Disponible: ${productData.stock}, Requerido: ${cantidad}`);
      }
      
      // Restar stock
      await adjustStock(producto_id, cantidad, 'subtract');
      
      updates.push({
        producto_id,
        nombre: productData.nombre,
        cantidad_anterior: productData.stock,
        cantidad_actualizada: productData.stock - cantidad,
      });
    }
    
    logger.info('Stocks actualizados en múltiples productos', { count: updates.length });
    return updates;
  } catch (error) {
    logger.error('Error actualizando stocks múltiples', { error: error.message });
    throw error;
  }
};

// Obtener productos con stock bajo
const getProductsWithLowStock = async (businessId = null, threshold = 10) => {
  try {
    let sql = 'SELECT * FROM productos WHERE stock <= $1';
    let params = [threshold];
    
    if (businessId) {
      sql += ' AND negocio_id = $2';
      params.push(businessId);
    }
    
    sql += ' ORDER BY stock ASC';
    
    const result = await query(sql, params);
    return result.rows;
  } catch (error) {
    logger.error('Error obteniendo productos con stock bajo', { error: error.message });
    throw error;
  }
};

module.exports = {
  getAllProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
  adjustStock,
  updateMultipleStocks,
  getProductsWithLowStock,
};
