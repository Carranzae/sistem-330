/**
 * Servicio de Clientes
 * Usa PostgreSQL directo (NO Supabase)
 */

const { query } = require('../../config/database');
const logger = require('../logger/logger.service');

// Obtener todos los clientes
const getAllClients = async (businessId = null) => {
  try {
    let sql = 'SELECT * FROM clientes';
    let params = [];
    
    if (businessId) {
      sql += ' WHERE negocio_id = $1';
      params.push(businessId);
    }
    
    sql += ' ORDER BY created_at DESC';
    
    const result = await query(sql, params);
    return result.rows;
  } catch (error) {
    logger.error('Error obteniendo clientes', { error: error.message });
    throw error;
  }
};

// Obtener cliente por ID
const getClientById = async (clientId) => {
  try {
    const result = await query(
      'SELECT * FROM clientes WHERE id = $1',
      [clientId]
    );
    
    if (result.rows.length === 0) {
      return null;
    }
    
    return result.rows[0];
  } catch (error) {
    logger.error('Error obteniendo cliente', { error: error.message, clientId });
    throw error;
  }
};

// Crear cliente
const createClient = async (clientData) => {
  try {
    const {
      negocio_id,
      nombre_completo,
      tipo_documento,
      numero_documento,
      telefono,
      email,
      direccion,
      notas,
    } = clientData;

    const result = await query(
      `INSERT INTO clientes (
        negocio_id, nombre_completo, tipo_documento, numero_documento,
        telefono, email, direccion, notas, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())
      RETURNING *`,
      [
        negocio_id,
        nombre_completo,
        tipo_documento,
        numero_documento,
        telefono,
        email,
        direccion,
        notas,
      ]
    );
    
    const client = result.rows[0];
    logger.info('Cliente creado', { clientId: client.id, nombre: client.nombre_completo });
    return client;
  } catch (error) {
    logger.error('Error creando cliente', { error: error.message });
    throw error;
  }
};

// Actualizar cliente
const updateClient = async (clientId, clientData) => {
  try {
    const fields = [];
    const values = [];
    let paramCount = 1;

    Object.keys(clientData).forEach((key) => {
      if (clientData[key] !== undefined) {
        fields.push(`${key} = $${paramCount}`);
        values.push(clientData[key]);
        paramCount++;
      }
    });

    values.push(clientId);
    fields.push(`updated_at = NOW()`);

    const sql = `UPDATE clientes SET ${fields.join(', ')} WHERE id = $${paramCount} RETURNING *`;
    
    const result = await query(sql, values);
    
    logger.info('Cliente actualizado', { clientId });
    return result.rows[0];
  } catch (error) {
    logger.error('Error actualizando cliente', { error: error.message, clientId });
    throw error;
  }
};

// Eliminar cliente
const deleteClient = async (clientId) => {
  try {
    await query('DELETE FROM clientes WHERE id = $1', [clientId]);
    logger.info('Cliente eliminado', { clientId });
    return true;
  } catch (error) {
    logger.error('Error eliminando cliente', { error: error.message, clientId });
    throw error;
  }
};

module.exports = {
  getAllClients,
  getClientById,
  createClient,
  updateClient,
  deleteClient,
};
