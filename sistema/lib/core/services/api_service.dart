import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Obtener negocios
  static Future<List<dynamic>> getBusinesses() async {
    final response = await http.get(Uri.parse('$baseUrl/businesses'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener negocios');
    }
  }

  // Crear negocio
  static Future<void> createBusiness(Map<String, dynamic> businessData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/businesses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(businessData),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear negocio');
    }
  }

  // Obtener productos
  static Future<List<dynamic>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener productos');
    }
  }

  // Crear venta
  static Future<void> createSale(Map<String, dynamic> saleData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sales'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(saleData),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear venta');
    }
  }
}
