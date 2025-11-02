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

module.exports = {
  getAllProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
};
