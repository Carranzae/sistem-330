import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Helper para manejo de errores
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return {};
      }
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Error en la petición');
      } catch (e) {
        throw Exception('Error en la petición');
      }
    }
  }

  // ==================== NEGOCIOS ====================
  
  // Obtener negocios
  static Future<List<dynamic>> getBusinesses() async {
    final response = await http.get(Uri.parse('$baseUrl/businesses'));
    final data = _handleResponse(response);
    return data['data'] ?? [];
  }

  // Crear negocio
  static Future<Map<String, dynamic>> createBusiness(Map<String, dynamic> businessData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/businesses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(businessData),
    );
    final data = _handleResponse(response);
    return data['data'] ?? {};
  }

  // ==================== PRODUCTOS ====================
  
  // Obtener todos los productos
  static Future<List<dynamic>> getProducts({String? businessId}) async {
    try {
      final uri = businessId != null && businessId.isNotEmpty
          ? Uri.parse('$baseUrl/products?businessId=$businessId')
          : Uri.parse('$baseUrl/products');
      
      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Tiempo de espera agotado'),
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      // Si hay error de conexión, retornar lista vacía
      // El código que llama manejará esto mostrando datos de muestra
      return [];
    }
  }

  // Obtener producto por ID
  static Future<Map<String, dynamic>> getProductById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/$id')).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Tiempo de espera agotado'),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(response.body);
          return data['data'] ?? {};
        } catch (e) {
          return {};
        }
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // Crear producto
  static Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(productData),
    );
    final data = _handleResponse(response);
    return data['data'] ?? {};
  }

  // Actualizar producto
  static Future<Map<String, dynamic>> updateProduct(String id, Map<String, dynamic> productData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(productData),
    );
    final data = _handleResponse(response);
    return data['data'] ?? {};
  }

  // Eliminar producto
  static Future<void> deleteProduct(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
    _handleResponse(response);
  }

  // ==================== VENTAS ====================
  
  // Obtener todas las ventas
  static Future<List<dynamic>> getSales({String? businessId}) async {
    try {
      final uri = businessId != null && businessId.isNotEmpty
          ? Uri.parse('$baseUrl/sales?businessId=$businessId')
          : Uri.parse('$baseUrl/sales');
      
      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Tiempo de espera agotado'),
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(response.body);
          return data['data'] ?? [];
        } catch (e) {
          return [];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Obtener venta por ID
  static Future<Map<String, dynamic>> getSaleById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/sales/$id'));
    final data = _handleResponse(response);
    return data['data'] ?? {};
  }

  // Crear venta
  static Future<Map<String, dynamic>> createSale(Map<String, dynamic> saleData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sales'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(saleData),
    );
    final data = _handleResponse(response);
    return data['data'] ?? {};
  }

  // Actualizar venta
  static Future<Map<String, dynamic>> updateSale(String id, Map<String, dynamic> saleData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/sales/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(saleData),
    );
    final data = _handleResponse(response);
    return data['data'] ?? {};
  }

  // Cancelar venta
  static Future<void> cancelSale(String id) async {
    final response = await http.put(Uri.parse('$baseUrl/sales/$id/cancel'));
    _handleResponse(response);
  }

  // ==================== CLIENTES ====================
  
  // Obtener todos los clientes
  static Future<List<dynamic>> getClients({String? businessId}) async {
    final uri = businessId != null 
        ? Uri.parse('$baseUrl/clients?businessId=$businessId')
        : Uri.parse('$baseUrl/clients');
    
    final response = await http.get(uri);
    final data = _handleResponse(response);
    return data['data'] ?? [];
  }

  // Crear cliente
  static Future<Map<String, dynamic>> createClient(Map<String, dynamic> clientData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clients'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(clientData),
    );
    final data = _handleResponse(response);
    return data['data'] ?? {};
  }

  // Actualizar cliente
  static Future<Map<String, dynamic>> updateClient(String id, Map<String, dynamic> clientData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/clients/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(clientData),
    );
    final data = _handleResponse(response);
    return data['data'] ?? {};
  }

  // ==================== DASHBOARD ====================
  
  // Obtener estadísticas del dashboard
  static Future<Map<String, dynamic>> getDashboardStats(String businessId) async {
    final response = await http.get(Uri.parse('$baseUrl/dashboard/stats?businessId=$businessId'));
    final data = _handleResponse(response);
    return data['data'] ?? {};
  }

  // Obtener alertas críticas
  static Future<List<dynamic>> getCriticalAlerts(String businessId) async {
    final response = await http.get(Uri.parse('$baseUrl/dashboard/alerts?businessId=$businessId'));
    final data = _handleResponse(response);
    return data['data'] ?? [];
  }

  // ==================== PRODUCTOS ESPECIALES ====================
  
  // Ajustar stock de un producto
  static Future<Map<String, dynamic>> adjustStock(String productId, Map<String, dynamic> stockData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$productId/stock'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(stockData),
    );
    final data = _handleResponse(response);
    return data['data'] ?? {};
  }

  // Obtener productos con stock bajo
  static Future<List<dynamic>> getLowStockProducts({String? businessId, int threshold = 10}) async {
    try {
      final uri = businessId != null && businessId.isNotEmpty
          ? Uri.parse('$baseUrl/products/low-stock/all?businessId=$businessId&threshold=$threshold')
          : Uri.parse('$baseUrl/products/low-stock/all?threshold=$threshold');
      
      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Tiempo de espera agotado'),
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      // Si hay error de conexión, retornar lista vacía
      return [];
    }
  }

  // ==================== MOVIMIENTOS DE INVENTARIO ====================
  
  // Obtener entradas de inventario
  static Future<List<dynamic>> getInventoryEntries({
    String? businessId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/inventory/entries');
      var queryParams = <String, String>{};
      
      if (businessId != null && businessId.isNotEmpty) queryParams['businessId'] = businessId;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      
      uri = uri.replace(queryParameters: queryParams);
      
      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Tiempo de espera agotado'),
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(response.body);
          return data['data'] ?? [];
        } catch (e) {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      // Si no hay endpoint o hay error de conexión, retornar lista vacía silenciosamente
      return [];
    }
  }

  // Obtener salidas de inventario
  static Future<List<dynamic>> getInventoryExits({
    String? businessId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/inventory/exits');
      var queryParams = <String, String>{};
      
      if (businessId != null && businessId.isNotEmpty) queryParams['businessId'] = businessId;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      
      uri = uri.replace(queryParameters: queryParams);
      
      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Tiempo de espera agotado'),
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(response.body);
          return data['data'] ?? [];
        } catch (e) {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      // Si no hay endpoint o hay error de conexión, retornar lista vacía silenciosamente
      return [];
    }
  }

  // Crear entrada de inventario
  static Future<Map<String, dynamic>> createInventoryEntry(Map<String, dynamic> entryData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/inventory/entries'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(entryData),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Tiempo de espera agotado'),
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(response.body);
          return data['data'] ?? {};
        } catch (e) {
          return {};
        }
      } else {
        return {};
      }
    } catch (e) {
      // Si no hay endpoint o hay error de conexión, retornar mapa vacío silenciosamente
      return {};
    }
  }

  // Crear salida de inventario
  static Future<Map<String, dynamic>> createInventoryExit(Map<String, dynamic> exitData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/inventory/exits'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(exitData),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Tiempo de espera agotado'),
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(response.body);
          return data['data'] ?? {};
        } catch (e) {
          return {};
        }
      } else {
        return {};
      }
    } catch (e) {
      // Si no hay endpoint o hay error de conexión, retornar mapa vacío silenciosamente
      return {};
    }
  }
}
