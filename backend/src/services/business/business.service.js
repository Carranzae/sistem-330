/**
 * Servicio de Negocios
 * Usa PostgreSQL directo (NO Supabase)
 */

const { query } = require('../../config/database');
const logger = require('../logger/logger.service');

// Obtener todos los negocios
const getAllBusinesses = async (userId = null) => {
  try {
    let sql = 'SELECT * FROM negocios';
    let params = [];
    
    // Filtrar por usuario si se proporciona
    if (userId) {
      sql += ' WHERE user_id = $1';
      params.push(userId);
    }
    
    sql += ' ORDER BY created_at DESC';
    
    const result = await query(sql, params);
    return result.rows;
  } catch (error) {
    logger.error('Error obteniendo negocios', { error: error.message });
    throw error;
  }
};

// Obtener negocio por ID
const getBusinessById = async (businessId) => {
  try {
    const result = await query(
      'SELECT * FROM negocios WHERE id = $1',
      [businessId]
    );
    
    if (result.rows.length === 0) {
      return null;
    }
    
    return result.rows[0];
  } catch (error) {
    logger.error('Error obteniendo negocio', { error: error.message, businessId });
    throw error;
  }
};

// Crear negocio
const createBusiness = async (businessData) => {
  try {
    const {
      user_id,
      nombre_comercial,
      ruc,
      pais,
      direccion_completa,
      rubro,
      categoria,
      modelo_negocio,
      configuracion,
      modulos_activos,
    } = businessData;

    const result = await query(
      `INSERT INTO negocios (
        user_id, nombre_comercial, ruc, pais, direccion_completa, 
        rubro, categoria, modelo_negocio, configuracion, 
        modulos_activos, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW())
      RETURNING *`,
      [
        user_id,
        nombre_comercial,
        ruc,
        pais,
        direccion_completa,
        rubro,
        categoria,
        modelo_negocio,
        configuracion ? JSON.stringify(configuracion) : null,
        modulos_activos ? JSON.stringify(modulos_activos) : null,
      ]
    );
    
    const business = result.rows[0];
    logger.info('Negocio creado', { businessId: business.id, nombre: business.nombre_comercial });
    return business;
  } catch (error) {
    logger.error('Error creando negocio', { error: error.message });
    throw error;
  }
};

// Actualizar negocio
const updateBusiness = async (businessId, businessData) => {
  try {
    const fields = [];
    const values = [];
    let paramCount = 1;

    Object.keys(businessData).forEach((key) => {
      if (businessData[key] !== undefined) {
        fields.push(`${key} = $${paramCount}`);
        // Si es JSON, convertir a string
        if (typeof businessData[key] === 'object') {
          values.push(JSON.stringify(businessData[key]));
        } else {
          values.push(businessData[key]);
        }
        paramCount++;
      }
    });

    values.push(businessId);
    fields.push(`updated_at = NOW()`);

    const sql = `UPDATE negocios SET ${fields.join(', ')} WHERE id = $${paramCount} RETURNING *`;
    
    const result = await query(sql, values);
    
    logger.info('Negocio actualizado', { businessId });
    return result.rows[0];
  } catch (error) {
    logger.error('Error actualizando negocio', { error: error.message, businessId });
    throw error;
  }
};

// Eliminar negocio
const deleteBusiness = async (businessId) => {
  try {
    const result = await query(
      'DELETE FROM negocios WHERE id = $1',
      [businessId]
    );
    
    logger.info('Negocio eliminado', { businessId });
    return true;
  } catch (error) {
    logger.error('Error eliminando negocio', { error: error.message, businessId });
    throw error;
  }
};

module.exports = {
  getAllBusinesses,
  getBusinessById,
  createBusiness,
  updateBusiness,
  deleteBusiness,
};
