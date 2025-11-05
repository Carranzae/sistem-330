import 'package:flutter/material.dart';

/// Colores modernos del sistema
class AppColors {
  // Colores base
  static const primary = Color(0xFF6366F1);
  static const secondary = Color(0xFF8B5CF6);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
  
  // Grises modernos
  static const gray50 = Color(0xFFFAFAFA);
  static const gray100 = Color(0xFFF5F5F5);
  static const gray200 = Color(0xFFEEEEEE);
  static const gray300 = Color(0xFFE0E0E0);
  static const gray400 = Color(0xFFBDBDBD);
  static const gray500 = Color(0xFF9E9E9E);
  static const gray600 = Color(0xFF757575);
  static const gray700 = Color(0xFF616161);
  static const gray800 = Color(0xFF424242);
  static const gray900 = Color(0xFF212121);
  
  // Colores por categoría de negocio
  static const Map<String, Color> businessColors = {
    'abarrotes': Color(0xFFF59E0B),
    'ropa_calzado': Color(0xFFEC4899),
    'hogar_decoracion': Color(0xFF8B5CF6),
    'electronica': Color(0xFF3B82F6),
    'verduleria': Color(0xFF10B981),
    'papa_mayorista': Color(0xFFF97316),
    'carniceria': Color(0xFFEF4444),
    'ferreteria': Color(0xFF6366F1),
    'farmacia': Color(0xFF06B6D4),
    'restaurante': Color(0xFFFF6B6B),
    'mayorista': Color(0xFF9333EA),
    'otro': Color(0xFF64748B),
  };
}
