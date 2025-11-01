import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/layouts/main_layout.dart';
import '../../../../app/providers/app_provider.dart';
import '../../../../core/services/pdf_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';

/// Módulo de Mi Score - Score Crediticio del Negocio
class MyScorePage extends StatefulWidget {
  const MyScorePage({super.key});

  @override
  State<MyScorePage> createState() => _MyScorePageState();
}

class _MyScorePageState extends State<MyScorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Datos simulados para el score
  final int _currentScore = 785; // Score actual (0-1000)
  
  // Factores dinámicos según la categoría
  List<ScoreFactor> get _factors {
    final category = Provider.of<AppProvider>(context, listen: false)
        .currentBusinessCategory;
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // Aumentado a 5 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    
    return MainLayout(
      businessCategory: appProvider.currentBusinessCategory,
      businessName: appProvider.currentBusinessName,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.star_rate_rounded,
                    color: Color(0xFFFFD700),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mi Score Crediticio',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Score basado en tu historial financiero',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Score principal
            Center(
              child: _buildScoreDisplay(),
            ),

            const SizedBox(height: 32),

            // Tabs
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFFFD700),
                labelColor: const Color(0xFFFFD700),
                unselectedLabelColor: const Color(0xFF6B7280),
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Factores'),
                  Tab(text: 'Ventas'),
                  Tab(text: 'Historial'),
                  Tab(text: 'Mejoras'),
                  Tab(text: 'Certificado'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contenido de tabs
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFactorsTab(),
                  _buildSalesTab(),
                  _buildHistoryTab(),
                  _buildImprovementsTab(),
                  _buildCertificateTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDisplay() {
    final scoreLevel = _getScoreLevel(_currentScore);
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scoreLevel.color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: scoreLevel.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Score circular
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _currentScore / 1000,
                  strokeWidth: 20,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(scoreLevel.color),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$_currentScore',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: scoreLevel.color,
                    ),
                  ),
                  Text(
                    scoreLevel.level,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Estadísticas rápidas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickStat('Cambio', '+12', Icons.arrow_upward, Colors.green),
              _buildQuickStat('Mes', 'Ene', Icons.calendar_month, Colors.blue),
              _buildQuickStat('Mejor', '825', Icons.star, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFactorsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Tu score se calcula según 6 factores clave',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Lista de factores
          ..._factors.map((factor) => _buildFactorCard(factor)),
        ],
      ),
    );
  }

  Widget _buildFactorCard(ScoreFactor factor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: factor.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(factor.icon, color: factor.color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      factor.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      factor.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildTrendIcon(factor.trend, factor.color),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Barra de progreso
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${factor.score}/${factor.maxScore}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: factor.color,
                    ),
                  ),
                  Text(
                    '${(factor.score / factor.maxScore * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: factor.score / factor.maxScore,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(factor.color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIcon(Trend trend, Color color) {
    IconData icon;
    Color trendColor;
    
    switch (trend) {
      case Trend.up:
        icon = Icons.arrow_upward_rounded;
        trendColor = Colors.green;
        break;
      case Trend.down:
        icon = Icons.arrow_downward_rounded;
        trendColor = Colors.red;
        break;
      case Trend.stable:
        icon = Icons.remove_rounded;
        trendColor = Colors.grey;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: trendColor, size: 20),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Icon(Icons.show_chart, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'Gráfico de Evolución',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Próximamente',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Sugerencias de mejora
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.orange[700], size: 24),
                    const SizedBox(width: 16),
                    const Text(
                      'Sugerencias para Mejorar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildImprovementCard(
            'Optimizar Rentabilidad',
            'Mejorar márgenes de ganancia',
            '+15 puntos estimados',
            Colors.orange,
            Icons.trending_up,
          ),
          _buildImprovementCard(
            'Aumentar Ventas',
            'Incrementar volumen de ventas mensuales',
            '+10 puntos estimados',
            Colors.green,
            Icons.point_of_sale,
          ),
          _buildImprovementCard(
            'Acortar Plazos de Pago',
            'Reducir días de crédito a clientes',
            '+8 puntos estimados',
            Colors.blue,
            Icons.schedule,
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementCard(
    String title,
    String description,
    String impact,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    impact,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Certificado
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700).withOpacity(0.2),
                  const Color(0xFFFFD700).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
            ),
            child: Column(
              children: [
                Icon(Icons.verified, color: Colors.amber[700], size: 64),
                const SizedBox(height: 16),
                const Text(
                  'CERTIFICADO DE SCORE',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: Color(0xFF78350F),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '$_currentScore',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: Colors.amber[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getScoreLevel(_currentScore).level,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF78350F),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha de Emisión',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Enero 2024',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Próxima Actualización',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Febrero 2024',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Botón descargar
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _downloadCertificate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Descargar Certificado PDF',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ScoreLevel _getScoreLevel(int score) {
    if (score >= 900) {
      return ScoreLevel('Excelente', Colors.green, 900);
    } else if (score >= 800) {
      return ScoreLevel('Muy Bueno', Colors.lightGreen, 800);
    } else if (score >= 700) {
      return ScoreLevel('Bueno', Colors.blue, 700);
    } else if (score >= 600) {
      return ScoreLevel('Regular', Colors.orange, 600);
    } else if (score >= 500) {
      return ScoreLevel('Necesita Mejora', Colors.deepOrange, 500);
    } else {
      return ScoreLevel('Bajo', Colors.red, 0);
    }
  }

  Widget _buildSalesTab() {
    // Datos simulados de ventas
    final totalVentas = 125430.50;
    final totalIngresos = 152000.00;
    final utilidadBruta = 26569.50;
    final margenGanancia = 17.48;
    final totalClientes = 245;
    final totalProductos = 1250;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            // Resumen de utilidades
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.green.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.trending_up, color: Colors.green.shade700, size: 24),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resumen de Utilidades',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Score por rentabilidad',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSalesMetric(
                          'Total Ventas',
                          totalVentas,
                          Icons.point_of_sale,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSalesMetric(
                          'Ingresos',
                          totalIngresos,
                          Icons.monetization_on,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSalesMetric(
                          'Utilidad Bruta',
                          utilidadBruta,
                          Icons.account_balance_wallet,
                          Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSalesMetric(
                          'Margen %',
                          margenGanancia,
                          Icons.percent,
                          Colors.orange,
                          isPercent: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Estadísticas adicionales
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estadísticas Adicionales',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildStatRow('Total de Clientes', '$totalClientes', Icons.people),
                  _buildStatRow('Total de Productos', '$totalProductos', Icons.inventory_2),
                  _buildStatRow('Promedio Venta', 'S/ ${(totalVentas / 245).toStringAsFixed(2)}', Icons.shopping_cart),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botón descargar certificado
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _downloadSalesCertificate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade600, Colors.amber.shade800],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Descargar Certificado de Ventas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesMetric(String label, double value, IconData icon, Color color, {bool isPercent = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            isPercent ? '$value%' : 'S/ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF6B7280), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadCertificate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generando certificado PDF...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _downloadSalesCertificate() async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final business = appProvider.currentBusiness;
      
      // Datos del negocio
      final nombreComercial = business?.nombreComercial ?? 'Mi Negocio';
      final ruc = business?.ruc ?? 'Sin RUC';
      final direccion = business?.direccionCompleta ?? 'Sin dirección';
      
      // Calcular fechas
      final now = DateTime.now();
      final fechaFin = DateFormat('dd/MM/yyyy').format(now);
      final fechaInicio = DateFormat('dd/MM/yyyy').format(
        now.subtract(const Duration(days: 30)),
      );
      
      // Datos simulados
      const score = 785;
      final scoreLevel = _getScoreLevel(score).level;
      const totalVentas = 125430.50;
      const totalIngresos = 152000.00;
      const utilidadBruta = 26569.50;
      const margenGanancia = 17.48;
      const totalClientes = 245;
      const totalProductos = 1250;
      
      // Generar PDF
      final pdfBytes = await PDFService.generateSalesScoreCertificatePDF(
        nombreComercial: nombreComercial,
        ruc: ruc,
        direccion: direccion,
        score: score,
        scoreLevel: scoreLevel,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        totalVentas: totalVentas,
        totalIngresos: totalIngresos,
        utilidadBruta: utilidadBruta,
        margenGanancia: margenGanancia,
        totalClientes: totalClientes,
        totalProductos: totalProductos,
      );
      
      // Cerrar loading
      if (mounted) Navigator.pop(context);
      
      // Mostrar PDF
      if (mounted) {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes,
        );
      }
    } catch (e) {
      // Cerrar loading
      if (mounted) Navigator.pop(context);
      
      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar certificado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Modelos
class ScoreFactor {
  final String title;
  final int score;
  final int maxScore;
  final String description;
  final Trend trend;
  final IconData icon;
  final Color color;

  ScoreFactor({
    required this.title,
    required this.score,
    required this.maxScore,
    required this.description,
    required this.trend,
    required this.icon,
    required this.color,
  });
}

class ScoreLevel {
  final String level;
  final Color color;
  final int minScore;

  ScoreLevel(this.level, this.color, this.minScore);
}

enum Trend {
  up,
  down,
  stable,
}

