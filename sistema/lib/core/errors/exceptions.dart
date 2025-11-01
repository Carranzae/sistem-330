/// Excepciones - Representan errores técnicos
/// Se lanzan desde la capa de datos

abstract class BaseException implements Exception {
  final String message;
  
  const BaseException(this.message);
  
  @override
  String toString() => message;
}

/// Excepción de servidor
class ServerException extends BaseException {
  const ServerException(String message) : super(message);
  
  factory ServerException.fromStatusCode(int statusCode, [String? body]) {
    final message = body ?? _getDefaultMessage(statusCode);
    return ServerException('Error $statusCode: $message');
  }
  
  static String _getDefaultMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Solicitud incorrecta';
      case 401:
        return 'No autorizado';
      case 403:
        return 'Acceso denegado';
      case 404:
        return 'Recurso no encontrado';
      case 500:
        return 'Error del servidor';
      case 503:
        return 'Servicio no disponible';
      default:
        return 'Error desconocido';
    }
  }
}

/// Excepción de red
class NetworkException extends BaseException {
  const NetworkException([String? message])
      : super(message ?? 'Sin conexión a internet');
}

/// Excepción de caché
class CacheException extends BaseException {
  const CacheException(String message) : super(message);
}

/// Excepción de base de datos
class DatabaseException extends BaseException {
  const DatabaseException(String message) : super(message);
}

/// Excepción de validación
class ValidationException extends BaseException {
  const ValidationException(String message) : super(message);
}

/// Recurso no encontrado
class NotFoundException extends BaseException {
  const NotFoundException(String resource) : super('$resource no encontrado');
}

/// Excepción de autenticación
class AuthException extends BaseException {
  const AuthException(String message) : super(message);
  
  factory AuthException.unauthorized() {
    return const AuthException('No autorizado');
  }
  
  factory AuthException.invalidCredentials() {
    return const AuthException('Credenciales inválidas');
  }
  
  factory AuthException.expiredToken() {
    return const AuthException('Token expirado');
  }
}

/// Excepción de sincronización
class SyncException extends BaseException {
  const SyncException(String message) : super(message);
  
  factory SyncException.conflict() {
    return const SyncException('Conflicto de sincronización');
  }
}

/// Excepción desconocida
class UnknownException extends BaseException {
  const UnknownException(String message) : super(message);
  
  factory UnknownException.fromError(Object error) {
    return UnknownException('Error desconocido: ${error.toString()}');
  }
}

