/**
 * Utilidades para respuestas HTTP
 */

// Respuesta exitosa
const success = (res, data = null, message = 'OK', statusCode = 200) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
  });
};

// Respuesta de error
const error = (res, message = 'Error', statusCode = 500, code = null) => {
  return res.status(statusCode).json({
    success: false,
    error: message,
    code: code || 'ERROR',
  });
};

// Respuesta con paginación
const paginated = (res, data, pagination) => {
  return res.json({
    success: true,
    data,
    pagination: {
      page: pagination.page || 1,
      limit: pagination.limit || 20,
      total: pagination.total || 0,
      totalPages: Math.ceil((pagination.total || 0) / (pagination.limit || 20)),
    },
  });
};

// Respuesta created
const created = (res, data = null, message = 'Creado exitosamente') => {
  return success(res, data, message, 201);
};

// Respuesta no encontrado
const notFound = (res, message = 'Recurso no encontrado', code = 'NOT_FOUND') => {
  return error(res, message, 404, code);
};

// Respuesta no autorizado
const unauthorized = (res, message = 'No autorizado', code = 'UNAUTHORIZED') => {
  return error(res, message, 401, code);
};

// Respuesta prohibido
const forbidden = (res, message = 'Prohibido', code = 'FORBIDDEN') => {
  return error(res, message, 403, code);
};

// Respuesta conflicto
const conflict = (res, message = 'Conflicto', code = 'CONFLICT') => {
  return error(res, message, 409, code);
};

// Respuesta bad request
const badRequest = (res, message = 'Solicitud inválida', code = 'BAD_REQUEST') => {
  return error(res, message, 400, code);
};

module.exports = {
  success,
  error,
  paginated,
  created,
  notFound,
  unauthorized,
  forbidden,
  conflict,
  badRequest,
};

