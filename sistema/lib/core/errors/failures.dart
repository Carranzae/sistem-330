/// Failures - Representan errores de dominio
/// Son clases puras sin dependencias de frameworks

abstract class Failure {
  final String message;
  
  const Failure(this.message);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

/// Error de servidor
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
  
  factory ServerFailure.fromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return const ServerFailure('Solicitud incorrecta');
      case 401:
        return const ServerFailure('No autorizado');
      case 403:
        return const ServerFailure('Acceso denegado');
      case 404:
        return const ServerFailure('Recurso no encontrado');
      case 500:
        return const ServerFailure('Error del servidor');
      default:
        return ServerFailure('Error desconocido: $statusCode');
    }
  }
}

/// Error de red/conectividad
class NetworkFailure extends Failure {
  const NetworkFailure() : super('Sin conexión a internet');
}

/// Error de validación
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

/// Error de caché/local
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// Recurso no encontrado
class NotFoundFailure extends Failure {
  const NotFoundFailure(String resource) 
      : super('$resource no encontrado');
}

/// Error de autenticación
class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
  
  factory AuthFailure.unauthorized() {
    return const AuthFailure('No autorizado. Inicie sesión nuevamente.');
  }
  
  factory AuthFailure.invalidCredentials() {
    return const AuthFailure('Credenciales inválidas');
  }
}

/// Error de permisos insuficientes
class PermissionFailure extends Failure {
  const PermissionFailure(String message) : super(message);
  
  factory PermissionFailure.insufficient() {
    return const PermissionFailure('Permisos insuficientes');
  }
}

/// Error desconocido
class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(message);
}

