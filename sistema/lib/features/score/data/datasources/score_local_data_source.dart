import 'package:flutter/material.dart';
import '../../domain/entities/score_factor.dart';

abstract class ScoreLocalDataSource {
  Future<List<ScoreFactor>> getScoreFactors(String category);
}

class ScoreLocalDataSourceImpl implements ScoreLocalDataSource {
  @override
  Future<List<ScoreFactor>> getScoreFactors(String category) async {
    // Simulamos una llamada asíncrona a una base de datos local
    await Future.delayed(const Duration(milliseconds: 200));
    return _getFactorsByCategory(category);
  }

  // Método que retorna factores según la categoría
  List<ScoreFactor> _getFactorsByCategory(String category) {
    switch (category) {
      case 'abarrotes':
        return _getAbarrotesFactors();
      case 'farmacia':
        return _getFarmaciaFactors();
      case 'verduleria':
      case 'papa_mayorista':
        return _getVerduleriaFactors();
      case 'carniceria':
        return _getCarniceriaFactors();
      case 'restaurante':
        return _getRestauranteFactors();
      case 'electronica':
        return _getElectronicaFactors();
      case 'ropa_calzado':
        return _getRopaFactors();
      case 'ferreteria':
        return _getFerreteriaFactors();
      case 'hogar_decoracion':
        return _getHogarFactors();
      case 'mayorista':
        return _getMayoristaFactors();
      default:
        return _getDefaultFactors();
    }
  }

  // --- Toda la lógica de datos simulados que estaba en la UI ---

  // Factores para Abarrotes/Bodega
  List<ScoreFactor> _getAbarrotesFactors() {
    return [
      ScoreFactor(
        title: 'Rotación de Stock',
        score: 85,
        maxScore: 100,
        description: 'Velocidad de venta de productos',
        trend: Trend.up,
        icon: Icons.refresh,
        color: Colors.green,
      ),
      ScoreFactor(
        title: 'Control de Vencimientos',
        score: 92,
        maxScore: 100,
        description: 'Productos frescos y vigentes',
        trend: Trend.up,
        icon: Icons.calendar_today,
        color: Colors.blue,
      ),
      ScoreFactor(
        title: 'Margen de Ganancia',
        score: 75,
        maxScore: 100,
        description: 'Rentabilidad por producto',
        trend: Trend.stable,
        icon: Icons.attach_money,
        color: Colors.purple,
      ),
      ScoreFactor(
        title: 'Clientes Recurrentes',
        score: 88,
        maxScore: 100,
        description: 'Fidelidad del barrio',
        trend: Trend.up,
        icon: Icons.people,
        color: Colors.teal,
      ),
      ScoreFactor(
        title: 'Gestión de Créditos',
        score: 70,
        maxScore: 100,
        description: 'Control de fiados',
        trend: Trend.stable,
        icon: Icons.credit_card,
        color: Colors.orange,
      ),
      ScoreFactor(
        title: 'Nivel de Inventario',
        score: 82,
        maxScore: 100,
        description: 'Stock óptimo',
        trend: Trend.up,
        icon: Icons.inventory_2,
        color: Colors.indigo,
      ),
    ];
  }

  // Factores para Farmacia
  List<ScoreFactor> _getFarmaciaFactors() {
    return [
      ScoreFactor(
        title: 'Control de Fechas',
        score: 95,
        maxScore: 100,
        description: 'Vigencia de medicamentos',
        trend: Trend.up,
        icon: Icons.medical_services,
        color: Colors.red,
      ),
      ScoreFactor(
        title: 'Prescripciones Válidas',
        score: 88,
        maxScore: 100,
        description: 'Cumplimiento normativo',
        trend: Trend.stable,
        icon: Icons.assignment,
        color: Colors.blue,
      ),
      ScoreFactor(
        title: 'Diversidad de Productos',
        score: 80,
        maxScore: 100,
        description: 'Catálogo completo',
        trend: Trend.up,
        icon: Icons.medication,
        color: Colors.green,
      ),
      ScoreFactor(
        title: 'Atención al Cliente',
        score: 85,
        maxScore: 100,
        description: 'Calidad de servicio',
        trend: Trend.up,
        icon: Icons.local_pharmacy,
        color: Colors.purple,
      ),
      ScoreFactor(
        title: 'Rentabilidad',
        score: 75,
        maxScore: 100,
        description: 'Margen de ganancia',
        trend: Trend.stable,
        icon: Icons.trending_up,
        color: Colors.orange,
      ),
      ScoreFactor(
        title: 'Clientes Frecuentes',
        score: 90,
        maxScore: 100,
        description: 'Fidelidad de pacientes',
        trend: Trend.up,
        icon: Icons.people,
        color: Colors.teal,
      ),
    ];
  }

  // Factores para Verdulería
  List<ScoreFactor> _getVerduleriaFactors() {
    return [
      ScoreFactor(
        title: 'Frescura de Productos',
        score: 85,
        maxScore: 100,
        description: 'Calidad de frutas/verduras',
        trend: Trend.up,
        icon: Icons.eco,
        color: Colors.green,
      ),
      ScoreFactor(
        title: 'Rotación Rápida',
        score: 88,
        maxScore: 100,
        description: 'Velocidad de venta diaria',
        trend: Trend.up,
        icon: Icons.speed,
        color: Colors.blue,
      ),
      ScoreFactor(
        title: 'Proveedores Confiables',
        score: 82,
        maxScore: 100,
        description: 'Suministro constante',
        trend: Trend.stable,
        icon: Icons.local_shipping,
        color: Colors.orange,
      ),
      ScoreFactor(
        title: 'Gestión de Pérdidas',
        score: 70,
        maxScore: 100,
        description: 'Reducción de merma',
        trend: Trend.up,
        icon: Icons.warning,
        color: Colors.red,
      ),
      ScoreFactor(
        title: 'Venta por Peso',
        score: 92,
        maxScore: 100,
        description: 'Precisión en medición',
        trend: Trend.up,
        icon: Icons.scale,
        color: Colors.purple,
      ),
      ScoreFactor(
        title: 'Clientes del Barrio',
        score: 90,
        maxScore: 100,
        description: 'Fidelidad local',
        trend: Trend.up,
        icon: Icons.store,
        color: Colors.teal,
      ),
    ];
  }

  // Factores para Carnicería
  List<ScoreFactor> _getCarniceriaFactors() {
    return [
      ScoreFactor(
        title: 'Cadena de Frío',
        score: 95,
        maxScore: 100,
        description: 'Conservación adecuada',
        trend: Trend.up,
        icon: Icons.ac_unit,
        color: Colors.blue,
      ),
      ScoreFactor(
        title: 'Higiéne y Sanidad',
        score: 98,
        maxScore: 100,
        description: 'Estándares sanitarios',
        trend: Trend.up,
        icon: Icons.cleaning_services,
        color: Colors.green,
      ),
      ScoreFactor(
        title: 'Diversidad de Cortes',
        score: 82,
        maxScore: 100,
        description: 'Variedad de productos',
        trend: Trend.stable,
        icon: Icons.cut,
        color: Colors.red,
      ),
      ScoreFactor(
        title: 'Proveedores Certificados',
        score: 90,
        maxScore: 100,
        description: 'Origen confiable',
        trend: Trend.up,
        icon: Icons.verified,
        color: Colors.purple,
      ),
      ScoreFactor(
        title: 'Rentabilidad',
        score: 80,
        maxScore: 100,
        description: 'Margen por corte',
        trend: Trend.stable,
        icon: Icons.attach_money,
        color: Colors.orange,
      ),
      ScoreFactor(
        title: 'Rotación Diaria',
        score: 85,
        maxScore: 100,
        description: 'Venta fresca diaria',
        trend: Trend.up,
        icon: Icons.schedule,
        color: Colors.teal,
      ),
    ];
  }

  // Factores para Restaurante
  List<ScoreFactor> _getRestauranteFactors() {
    return [
      ScoreFactor(
        title: 'Calidad de Comida',
        score: 92,
        maxScore: 100,
        description: 'Satisfacción del cliente',
        trend: Trend.up,
        icon: Icons.restaurant_menu,
        color: Colors.red,
      ),
      ScoreFactor(
        title: 'Tiempo de Preparación',
        score: 85,
        maxScore: 100,
        description: 'Eficiencia en cocina',
        trend: Trend.stable,
        icon: Icons.timer,
        color: Colors.orange,
      ),
      ScoreFactor(
        title: 'Atención al Cliente',
        score: 88,
        maxScore: 100,
        description: 'Servicio de calidad',
        trend: Trend.up,
        icon: Icons.soup_kitchen,
        color: Colors.blue,
      ),
      ScoreFactor(
        title: 'Control de Costos',
        score: 75,
        maxScore: 100,
        description: 'Gestión de inventario',
        trend: Trend.down,
        icon: Icons.receipt_long,
        color: Colors.green,
      ),
      ScoreFactor(
        title: 'Reservas y Pedidos',
        score: 82,
        maxScore: 100,
        description: 'Demanda y ocupación',
        trend: Trend.up,
        icon: Icons.local_dining,
        color: Colors.purple,
      ),
      ScoreFactor(
        title: 'Rentabilidad por Plato',
        score: 80,
        maxScore: 100,
        description: 'Margen de ganancia',
        trend: Trend.stable,
        icon: Icons.account_balance,
        color: Colors.indigo,
      ),
    ];
  }

  // Factores para Electrónica
  List<ScoreFactor> _getElectronicaFactors() {
    return [
      ScoreFactor(
        title: 'Tecnología Actualizada',
        score: 78,
        maxScore: 100,
        description: 'Productos de última generación',
        trend: Trend.up,
        icon: Icons.phone_android,
        color: Colors.blue,
      ),
      ScoreFactor(
        title: 'Soporte Técnico',
        score: 85,
        maxScore: 100,
        description: 'Servicio post-venta',
        trend: Trend.up,
        icon: Icons.support_agent,
        color: Colors.green,
      ),
      ScoreFactor(
        title: 'Garantías Activas',
        score: 88,
        maxScore: 100,
        description: 'Cobertura de productos',
        trend: Trend.up,
        icon: Icons.verified_user,
        color: Colors.purple,
      ),
      ScoreFactor(
        title: 'Diversidad de Marcas',
        score: 82,
        maxScore: 100,
        description: 'Catálogo variado',
        trend: Trend.stable,
        icon: Icons.stars,
        color: Colors.orange,
      ),
      ScoreFactor(
        title: 'Financiamiento',
        score: 70,
        maxScore: 100,
        description: 'Opciones de pago',
        trend: Trend.up,
        icon: Icons.credit_card,
        color: Colors.teal,
      ),
      ScoreFactor(
        title: 'Tasa de Devolución',
        score: 90,
        maxScore: 100,
        description: 'Bajo nivel de retornos',
        trend: Trend.up,
        icon: Icons.undo,
        color: Colors.red,
      ),
    ];
  }

  // Factores para Ropa y Calzado
  List<ScoreFactor> _getRopaFactors() {
    return [
      ScoreFactor(
        title: 'Variedad de Tallas',
        score: 88,
        maxScore: 100,
        description: 'Cobertura completa',
        trend: Trend.up,
        icon: Icons.checkroom,
        color: Colors.pink,
      ),
      ScoreFactor(
        title: 'Temporada de Moda',
        score: 82,
        maxScore: 100,
        description: 'Productos actuales',
        trend: Trend.stable,
        icon: Icons.shopping_bag,
        color: Colors.purple,
      ),
      ScoreFactor(
        title: 'Control de Stock',
        score: 85,
        maxScore: 100,
        description: 'Gestión de inventario',
        trend: Trend.up,
        icon: Icons.inventory_2,
        color: Colors.blue,
      ),
      ScoreFactor(
        title: 'Prueba y Cambio',
        score: 80,
        maxScore: 100,
        description: 'Política flexible',
        trend: Trend.up,
        icon: Icons.swap_horiz,
        color: Colors.green,
      ),
      ScoreFactor(
        title: 'Marcas Reconocidas',
        score: 75,
        maxScore: 100,
        description: 'Diversidad de proveedores',
        trend: Trend.stable,
        icon: Icons.label,
        color: Colors.orange,
      ),
      ScoreFactor(
        title: 'Cliente Frecuente',
        score: 90,
        maxScore: 100,
        description: 'Fidelidad',
        trend: Trend.up,
        icon: Icons.people,
        color: Colors.teal,
      ),
    ];
  }

  // Factores para Ferretería
  List<ScoreFactor> _getFerreteriaFactors() {
    return [
      ScoreFactor(
        title: 'Asesoramiento Técnico',
        score: 88,
        maxScore: 100,
        description: 'Conocimiento de productos',
        trend: Trend.up,
        icon: Icons.build_circle,
        color: Colors.indigo,
      ),
      ScoreFactor(
        title: 'Variedad de Herramientas',
        score: 85,
        maxScore: 100,
        description: 'Catálogo amplio',
        trend: Trend.up,
        icon: Icons.hardware,
        color: Colors.blue,
      ),
      ScoreFactor(
        title: 'Materiales de Calidad',
        score: 90,
        maxScore: 100,
        description: 'Productos duraderos',
        trend: Trend.up,
        icon: Icons.construction,
        color: Colors.green,
      ),
      ScoreFactor(
        title: 'Servicio a Maestros',
        score: 82,
        maxScore: 100,
        description: 'Clientes profesionales',
        trend: Trend.stable,
        icon: Icons.engineering,
        color: Colors.orange,
      ),
      ScoreFactor(
        title: 'Venta al Detalle/Mayor',
        score: 80,
        maxScore: 100,
        description: 'Flexibilidad comercial',
        trend: Trend.up,
        icon: Icons.shopping_cart,
        color: Colors.purple,
      ),
      ScoreFactor(
        title: 'Rentabilidad',
        score: 78,
        maxScore: 100,
        description: 'Margen por producto',
        trend: Trend.stable,
        icon: Icons.attach_money,
        color: Colors.teal,
      ),
    ];
  }

  // Factores para Hogar y Decoración
  List<ScoreFactor> _getHogarFactors() {
    return [
      ScoreFactor(
        title: 'Tendencias Actuales',
        score: 85,
        maxScore: 100,
        description: 'Estilos modernos',
        trend: Trend.up,
        icon: Icons.home,
        color: Colors.amber,
      ),
      ScoreFactor(
        title: 'Diversidad de Productos',
        score: 88,
        maxScore: 100,
        description: 'Catálogo variado',
        trend: Trend.up,
        icon: Icons.shopping_basket,
        color: Colors.blue,
      ),
      ScoreFactor(
        title: 'Atención al Cliente',
        score: 90,
        maxScore: 100,
        description: 'Asesoría personalizada',
        trend: Trend.up,
        icon: Icons.person_search,
        color: Colors.green,
      ),
      ScoreFactor(
        title: 'Ofertas y Promociones',
        score: 82,
        maxScore: 100,
        description: 'Estrategia comercial',
        trend: Trend.stable,
        icon: Icons.local_offer,
        color: Colors.orange,
      ),
      ScoreFactor(
        title: 'Delivery/Instalación',
        score: 75,
        maxScore: 100,
        description: 'Servicios adicionales',
        trend: Trend.up,
        icon: Icons.delivery_dining,
        color: Colors.purple,
      ),
      ScoreFactor(
        title: 'Clientes Recurrentes',
        score: 88,
        maxScore: 100,
        description: 'Fidelidad',
        trend: Trend.up,
        icon: Icons.favorite,
        color: Colors.red,
      ),
    ];
  }

  // Factores para Mayorista
  List<ScoreFactor> _getMayoristaFactors() {
    return [
      ScoreFactor(
        title: 'Volumen de Ventas',
        score: 90,
        maxScore: 100,
        description: 'Cantidad vendida',
        trend: Trend.up,
        icon: Icons.production_quantity_limits,
        color: Colors.green,
      ),
      ScoreFactor(
        title: 'Red de Distribución',
        score: 85,
        maxScore: 100,
        description: 'Alcance territorial',
        trend: Trend.up,
        icon: Icons.local_shipping,
        color: Colors.blue,
      ),
      ScoreFactor(
        title: 'Créditos y Plazos',
        score: 80,
        maxScore: 100,
        description: 'Gestión de pagos',
        trend: Trend.stable,
        icon: Icons.payments,
        color: Colors.purple,
      ),
      ScoreFactor(
        title: 'Clientes Institucionales',
        score: 92,
        maxScore: 100,
        description: 'Relaciones B2B',
        trend: Trend.up,
        icon: Icons.business,
        color: Colors.orange,
      ),
      ScoreFactor(
        title: 'Logística Eficiente',
        score: 88,
        maxScore: 100,
        description: 'Control de entregas',
        trend: Trend.up,
        icon: Icons.inventory,
        color: Colors.indigo,
      ),
      ScoreFactor(
        title: 'Rentabilidad B2B',
        score: 85,
        maxScore: 100,
        description: 'Márgenes mayoristas',
        trend: Trend.stable,
        icon: Icons.trending_up,
        color: Colors.teal,
      ),
    ];
  }

  // Factores por defecto
  List<ScoreFactor> _getDefaultFactors() {
    return [
      ScoreFactor(
        title: 'Historial de Ventas',
        score: 85,
        maxScore: 100,
        description: 'Volumen y consistencia',
        trend: Trend.up,
        icon: Icons.point_of_sale,
        color: Colors.green,
      ),
      ScoreFactor(
        title: 'Ingresos Recurrentes',
        score: 78,
        maxScore: 100,
        description: 'Estabilidad mensual',
        trend: Trend.up,
        icon: Icons.trending_up,
        color: Colors.blue,
      ),
      ScoreFactor(
        title: 'Cumplimiento de Pago',
        score: 92,
        maxScore: 100,
        description: 'Pagos puntuales',
        trend: Trend.stable,
        icon: Icons.credit_card,
        color: Colors.purple,
      ),
      ScoreFactor(
        title: 'Rentabilidad',
        score: 68,
        maxScore: 100,
        description: 'Margen de ganancia',
        trend: Trend.down,
        icon: Icons.attach_money,
        color: Colors.orange,
      ),
      ScoreFactor(
        title: 'Clientes Recurrentes',
        score: 82,
        maxScore: 100,
        description: 'Fidelidad',
        trend: Trend.up,
        icon: Icons.people,
        color: Colors.teal,
      ),
      ScoreFactor(
        title: 'Gestión de Inventario',
        score: 75,
        maxScore: 100,
        description: 'Rotación y control',
        trend: Trend.stable,
        icon: Icons.inventory,
        color: Colors.indigo,
      ),
    ];
  }
}
