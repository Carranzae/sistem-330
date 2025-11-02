import 'package:dartz/dartz.dart';

/// Clase base para todos los tipos de errores/Fallos
abstract class Failure {
  final String message;
  const Failure(this.message);
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Failure &&
    runtimeType == other.runtimeType &&
    message == other.message;
  
  @override
  int get hashCode => message.hashCode;
}

/// Errores de servidor
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

/// Errores de red/conectividad
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Error de conexión']) : super(message);
}

/// Errores de validación
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

/// Errores de autenticación
class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

/// Errores inesperados
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(String message) : super(message);
}

/// Errores de caché
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// Errores de permisos
class PermissionFailure extends Failure {
  const PermissionFailure(String message) : super(message);
}
