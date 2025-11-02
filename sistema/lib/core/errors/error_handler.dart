import 'exceptions.dart';
import 'failures.dart';
import 'dart:convert';

/// Mapea excepciones a failures (domain layer)
class ErrorHandler {
  /// Convierte una excepción a un failure
  static Failure mapExceptionToFailure(BaseException exception) {
    if (exception is ServerException) {
      // Extraer código de estado si está disponible
      final message = exception.message;
      final match = RegExp(r'Error (\d+)').firstMatch(message);
      
      if (match != null) {
        final statusCode = int.parse(match.group(1)!);
        return ServerFailure.fromStatusCode(statusCode);
      }
      
      return ServerFailure(message);
    }
    
    if (exception is NetworkException) {
      return const NetworkFailure();
    }
    
    if (exception is CacheException) {
      return CacheFailure(exception.message);
    }
    
    if (exception is DatabaseException) {
      return CacheFailure('Error de base de datos: ${exception.message}');
    }
    
    if (exception is ValidationException) {
      return ValidationFailure(exception.message);
    }
    
    if (exception is NotFoundException) {
      return NotFoundFailure(exception.message);
    }
    
    if (exception is AuthException) {
      return AuthFailure(exception.message);
    }
    
    if (exception is SyncException) {
      return ServerFailure('Error de sincronización: ${exception.message}');
    }
    
    if (exception is UnknownException) {
      return UnknownFailure(exception.message);
    }
    
    return UnknownFailure('Error desconocido: ${exception.message}');
  }

  /// Obtiene un mensaje amigable para el usuario
  static String getFriendlyMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'No hay conexión a internet.\nVerifique su red e intente nuevamente.';
    }
    
    if (failure is ServerFailure) {
      return 'Error del servidor.\nPor favor, intente más tarde o contacte soporte.';
    }
    
    if (failure is ValidationFailure) {
      return failure.message;
    }
    
    if (failure is AuthFailure) {
      return failure.message;
    }
    
    if (failure is NotFoundFailure) {
      return failure.message;
    }
    
    if (failure is PermissionFailure) {
      return 'No tiene permisos para realizar esta acción.\nContacte a un administrador.';
    }
    
    if (failure is CacheFailure) {
      return 'Error al guardar datos localmente.\nLibere espacio o reinicie la aplicación.';
    }
    
    return failure.message;
  }

  /// Parsea error del backend PostgreSQL
  static BaseException parsePostgresError(dynamic error) {
    try {
      if (error is Map) {
        final message = error['message'] as String?;
        final code = error['code'] as String?;
        final statusCode = error['statusCode'] as int?;
        
        if (statusCode != null) {
          return ServerException.fromStatusCode(statusCode, message);
        }
        
        // Códigos de error de PostgreSQL
        switch (code) {
          case 'P0001': // Raise exception
            return const ValidationException('Error de validación');
          case '23505': // Unique violation
            return const ValidationException('El registro ya existe');
          case '23503': // Foreign key violation
            return const ValidationException('Violación de clave foránea');
          case '42P01': // Undefined table
            return const NotFoundException('Tabla no encontrada');
          case '42703': // Undefined column
            return const ValidationException('Columna no encontrada');
          default:
            return ServerException(message ?? 'Error desconocido');
        }
      }
      
      // Error de network
      if (error.toString().contains('SocketException') ||
          error.toString().contains('TimeoutException') ||
          error.toString().contains('NetworkException')) {
        return const NetworkException();
      }
      
      return UnknownException(error.toString());
    } catch (e) {
      return UnknownException('Error al parsear: ${e.toString()}');
    }
  }

  /// Obtiene el ícono apropiado según el tipo de error
  static String getErrorIcon(Failure failure) {
    if (failure is NetworkFailure) {
      return '📡';
    }
    if (failure is ServerFailure) {
      return '⚠️';
    }
    if (failure is AuthFailure) {
      return '🔒';
    }
    if (failure is ValidationFailure) {
      return '✏️';
    }
    if (failure is PermissionFailure) {
      return '🚫';
    }
    return '❌';
  }

  /// Determina si el error es recuperable
  static bool isRecoverable(Failure failure) {
    if (failure is NetworkFailure) {
      return true; // Se puede recuperar con conexión
    }
    if (failure is ValidationFailure) {
      return true; // El usuario puede corregir
    }
    if (failure is CacheFailure) {
      return true; // Se puede recuperar al liberar espacio
    }
    return false; // No recuperable
  }

  /// Log del error (para debugging)
  static void logError(Failure failure, {StackTrace? stackTrace}) {
    // TODO: Integrar con un servicio de logging (Sentry, Firebase Crashlytics)
    print('❌ Error: ${failure.message}');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }
}

