import 'dart:io';
import 'package:http/http.dart' as http;
import '../errors/exceptions.dart';

/// Cliente HTTP empresarial
class ApiClient {
  final String baseUrl;
  final Map<String, String> headers;
  final Duration timeout;

  ApiClient({
    required this.baseUrl,
    Map<String, String>? headers,
    Duration? timeout,
  })  : headers = headers ?? {},
        timeout = timeout ?? const Duration(seconds: 30);

  /// GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? customHeaders,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );

      final response = await http
          .get(uri, headers: {...headers, ...?customHeaders})
          .timeout(timeout);

      _handleResponse(response);
      return response;
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on HttpException {
      throw ServerException('Error en el servidor');
    } catch (e) {
      throw UnexpectedException('Error inesperado: $e');
    }
  }

  /// POST request
  Future<http.Response> post(
    String endpoint, {
    Object? body,
    Map<String, String>? customHeaders,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {...headers, ...?customHeaders},
            body: body,
          )
          .timeout(timeout);

      _handleResponse(response);
      return response;
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on HttpException {
      throw ServerException('Error en el servidor');
    } catch (e) {
      throw UnexpectedException('Error inesperado: $e');
    }
  }

  /// Manejo centralizado de respuestas
  void _handleResponse(http.Response response) {
    if (response.statusCode >= 500) {
      throw ServerException('Error del servidor');
    } else if (response.statusCode >= 400) {
      throw ClientException('Error en la solicitud');
    }
  }
}

