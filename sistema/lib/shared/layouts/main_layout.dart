import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/services/api_service.dart';
import '../../app/providers/app_provider.dart';

/// Layout principal con sidebar empresarial y header fijo
/// Muestra diferentes módulos según la categoría del negocio
class MainLayout extends StatefulWidget {
  final String businessCategory;
  final String businessName;
  final Widget child;
  
  const MainLayout({
    super.key,
    required this.businessCategory,
    required this.businessName,
    required this.child,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  
  // Estado de notificaciones
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  bool _isLoadingNotifications = false;

  // Módulos base comunes para todos los negocios
  List<Map<String, dynamic>> get _baseModules => [
    {
      'id': 'dashboard',
      'name': 'Dashboard',
      'icon': Icons.dashboard,
      'color': const Color(0xFF2563EB),
    },
    {
      'id': 'pos',
      'name': 'Punto de Venta',
      'icon': Icons.point_of_sale,
      'color': const Color(0xFF10B981),
    },
    {
      'id': 'inventory',
      'name': 'Inventario',
      'icon': Icons.inventory_2,
      'color': const Color(0xFFF59E0B),
    },
    {
      'id': 'clients',
      'name': 'Clientes',
      'icon': Icons.people,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'id': 'cash',
      'name': 'Caja',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFFEF4444),
    },
    {
      'id': 'reports',
      'name': 'Reportes',
      'icon': Icons.analytics,
      'color': const Color(0xFF06B6D4),
    },
  ];

  // Módulos adicionales según la categoría
  List<Map<String, dynamic>> get _categorySpecificModules {
    switch (widget.businessCategory) {
      case 'abarrotes':
        return [
          {
            'id': 'purchases',
            'name': 'Compras',
            'icon': Icons.shopping_cart,
            'color': const Color(0xFF8B5CF6),
          },
          {
            'id': 'credits',
            'name': 'Créditos',
            'icon': Icons.credit_card,
            'color': const Color(0xFFF59E0B),
          },
          {
            'id': 'myscore',
            'name': 'Mi Score',
            'icon': Icons.star_rate_rounded,
            'color': const Color(0xFFFFD700),
          },
          {
            'id': 'pronostics',
            'name': 'Pronósticos',
            'icon': Icons.trending_up,
            'color': const Color(0xFF14B8A6),
          },
          {
            'id': 'notifications',
            'name': 'Notificaciones',
            'icon': Icons.notifications,
            'color': const Color(0xFF06B6D4),
          },
          {
            'id': 'settings',
            'name': 'Configuración',
            'icon': Icons.settings,
            'color': const Color(0xFF64748B),
          },
          {
            'id': 'help',
            'name': 'Ayuda',
            'icon': Icons.help_outline,
            'color': const Color(0xFF10B981),
          },
        ];
      case 'verduleria':
      case 'papa_mayorista':
        return [
          {
            'id': 'harvest',
            'name': 'Cosechas',
            'icon': Icons.eco,
            'color': const Color(0xFF059669),
          },
          {
            'id': 'suppliers',
            'name': 'Proveedores',
            'icon': Icons.local_shipping,
            'color': const Color(0xFF7C3AED),
          },
        ];
      case 'carniceria':
        return [
          {
            'id': 'suppliers',
            'name': 'Proveedores',
            'icon': Icons.local_shipping,
            'color': const Color(0xFF7C3AED),
          },
          {
            'id': 'cuts',
            'name': 'Cortes',
            'icon': Icons.cut,
            'color': const Color(0xFFB91C1C),
          },
        ];
      case 'restaurante':
        return [
          {
            'id': 'orders',
            'name': 'Pedidos',
            'icon': Icons.restaurant_menu,
            'color': const Color(0xFFDC2626),
          },
          {
            'id': 'kitchen',
            'name': 'Cocina',
            'icon': Icons.kitchen,
            'color': const Color(0xFF7C2D12),
          },
        ];
      case 'farmacia':
        return [
          {
            'id': 'expiration',
            'name': 'Vencimientos',
            'icon': Icons.calendar_today,
            'color': const Color(0xFFDC2626),
          },
          {
            'id': 'recipes',
            'name': 'Recetas',
            'icon': Icons.medical_services,
            'color': const Color(0xFF0891B2),
          },
        ];
      default:
        return [];
    }
  }

  List<Map<String, dynamic>> get _allModules => [
    ..._baseModules,
    ..._categorySpecificModules,
  ];

  // Colores por categoría
  Color get _categoryColor {
    switch (widget.businessCategory) {
      case 'abarrotes':
        return const Color(0xFFF59E0B);
      case 'ropa_calzado':
        return const Color(0xFFEC4899);
      case 'hogar_decoracion':
        return const Color(0xFF8B5CF6);
      case 'electronica':
        return const Color(0xFF3B82F6);
      case 'verduleria':
        return const Color(0xFF10B981);
      case 'papa_mayorista':
        return const Color(0xFFF97316);
      case 'carniceria':
        return const Color(0xFFEF4444);
      case 'ferreteria':
        return const Color(0xFF6366F1);
      case 'farmacia':
        return const Color(0xFF06B6D4);
      case 'restaurante':
        return const Color(0xFFFF6B6B);
      case 'mayorista':
        return const Color(0xFF9333EA);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    // Recargar notificaciones cada 30 segundos
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadNotifications();
      }
    });
  }

  Future<void> _loadNotifications() async {
    if (_isLoadingNotifications) return;
    
    setState(() {
      _isLoadingNotifications = true;
    });

    try {
      // Obtener productos con stock bajo
      final lowStockProducts = await ApiService.getLowStockProducts();
      
      // Obtener todos los productos para verificar vencimientos
      final allProducts = await ApiService.getProducts();
      final now = DateTime.now();
      
      // Obtener clientes para verificar morosos
      final clients = await ApiService.getClients();
      
      final notifications = <Map<String, dynamic>>[];
      
      // Notificaciones de stock bajo
      for (var product in lowStockProducts) {
        notifications.add({
          'id': 'low_stock_${product['id']}',
          'type': 'low_stock',
          'title': 'Stock Bajo',
          'message': '${product['nombre']} tiene solo ${product['stock']} unidades',
          'priority': 'high',
          'timestamp': DateTime.now(),
          'read': false,
          'data': product,
        });
      }
      
      // Notificaciones de productos por vencer (30 días)
      for (var product in allProducts) {
        if (product['fecha_vencimiento'] != null) {
          try {
            final expirationDate = DateTime.parse(product['fecha_vencimiento']);
            final daysUntilExpiration = expirationDate.difference(now).inDays;
            
            if (daysUntilExpiration >= 0 && daysUntilExpiration <= 30) {
              notifications.add({
                'id': 'expiring_${product['id']}',
                'type': 'expiring',
                'title': 'Producto por Vencer',
                'message': '${product['nombre']} vence en $daysUntilExpiration días',
                'priority': daysUntilExpiration <= 7 ? 'high' : 'medium',
                'timestamp': DateTime.now(),
                'read': false,
                'data': product,
              });
            }
          } catch (e) {
            // Ignorar productos con fecha inválida
          }
        }
      }
      
      // Notificaciones de clientes morosos
      for (var client in clients) {
        if (client['credito_pendiente'] != null && 
            (client['credito_pendiente'] as num) > 0) {
          final pendingCredit = client['credito_pendiente'] as num;
          notifications.add({
            'id': 'delinquent_${client['id']}',
            'type': 'delinquent',
            'title': 'Cliente Moroso',
            'message': '${client['nombre']} ${client['apellido'] ?? ''} tiene S/ ${pendingCredit.toStringAsFixed(2)} pendiente',
            'priority': 'high',
            'timestamp': DateTime.now(),
            'read': false,
            'data': client,
          });
        }
      }
      
      // Ordenar por prioridad y fecha
      notifications.sort((a, b) {
        final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
        final priorityDiff = (priorityOrder[a['priority']] ?? 2) - 
                            (priorityOrder[b['priority']] ?? 2);
        if (priorityDiff != 0) return priorityDiff;
        return (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime);
      });
      
      setState(() {
        _notifications = notifications;
        _unreadCount = notifications.where((n) => !n['read']).length;
        _isLoadingNotifications = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingNotifications = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Diseño responsive:
        // - Móvil: < 600px (drawer lateral)
        // - Tablet: 600-1024px (sidebar reducido)
        // - Desktop: > 1024px (sidebar completo)
        final isMobile = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
        
        if (isMobile) {
          return _buildMobileLayout();
        } else if (isTablet) {
          return _buildTabletLayout();
        } else {
          return _buildDesktopLayout();
        }
      },
    );
  }

  // Layout móvil con drawer
  Widget _buildMobileLayout() {
    return Scaffold(
      drawer: Drawer(
        child: _buildSidebarContent(isMobile: true),
      ),
      appBar: _buildAppBar(),
      body: widget.child,
    );
  }

  // Layout tablet con sidebar más estrecho
  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar para tablet (más estrecho)
          _buildSidebarContent(isMobile: false, isTablet: true),
          // Contenido principal
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Layout desktop con sidebar fijo
  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _buildSidebarContent(isMobile: false),
          // Contenido principal
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Sidebar empresarial
  Widget _buildSidebarContent({required bool isMobile, bool isTablet = false}) {
    final sidebarWidth = isMobile ? 280.0 : (isTablet ? 80.0 : 280.0);
    Widget sidebar = Container(
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo y nombre del negocio
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _categoryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.businessName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _categoryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getCategoryName(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _categoryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Menú de navegación
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Módulos base
                  ..._baseModules.map((module) => _buildMenuItem(
                    module,
                    isSelected: _selectedIndex == _baseModules.indexOf(module),
                    onTap: () {
                      setState(() {
                        _selectedIndex = _baseModules.indexOf(module);
                      });
                      _navigateToModule(module['id'] as String);
                      if (isMobile) Navigator.pop(context);
                    },
                  )),
                  
                  // Separador si hay módulos específicos
                  if (_categorySpecificModules.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Color(0xFF374151),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'ESPECÍFICOS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9CA3AF),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Color(0xFF374151),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Módulos específicos
                    ..._categorySpecificModules.map((module) => _buildMenuItem(
                      module,
                      isSelected: _selectedIndex == _allModules.indexOf(module),
                      onTap: () {
                        setState(() {
                          _selectedIndex = _allModules.indexOf(module);
                        });
                        _navigateToModule(module['id'] as String);
                        if (isMobile) Navigator.pop(context);
                      },
                    )),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          // Footer con perfil y salida
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                _buildFooterMenuItem(
                  icon: Icons.settings,
                  label: 'Configuración',
                  onTap: () {
                    if (isMobile) Navigator.pop(context);
                    context.go('/settings');
                  },
                ),
                const SizedBox(height: 8),
                _buildFooterMenuItem(
                  icon: Icons.logout,
                  label: 'Salir',
                  onTap: () => _showLogoutDialog(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    
    // En móvil, eliminar el ancho fijo para que use el ancho del drawer
    if (isMobile) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
        ),
        child: Column(
          children: [
            // Logo y nombre del negocio
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _categoryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.businessName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getCategoryName(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _categoryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Menú de navegación
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Módulos base
                    ..._baseModules.map((module) => _buildMenuItem(
                      module,
                      isSelected: _selectedIndex == _baseModules.indexOf(module),
                      onTap: () {
                        setState(() {
                          _selectedIndex = _baseModules.indexOf(module);
                        });
                        _navigateToModule(module['id'] as String);
                        if (isMobile) Navigator.pop(context);
                      },
                    )),
                    
                    // Separador si hay módulos específicos
                    if (_categorySpecificModules.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Color(0xFF374151),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'ESPECÍFICOS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF9CA3AF),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Color(0xFF374151),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Módulos específicos
                      ..._categorySpecificModules.map((module) => _buildMenuItem(
                        module,
                        isSelected: _selectedIndex == _allModules.indexOf(module),
                        onTap: () {
                          setState(() {
                            _selectedIndex = _allModules.indexOf(module);
                          });
                          _navigateToModule(module['id'] as String);
                          if (isMobile) Navigator.pop(context);
                        },
                      )),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            // Footer con perfil y salida
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  _buildFooterMenuItem(
                    icon: Icons.settings,
                    label: 'Configuración',
                    onTap: () {
                      if (isMobile) Navigator.pop(context);
                      context.go('/settings');
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFooterMenuItem(
                    icon: Icons.logout,
                    label: 'Salir',
                    onTap: () => _showLogoutDialog(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    return sidebar;
  }

  // Item del menú
  Widget _buildMenuItem(
    Map<String, dynamic> module, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? (module['color'] as Color).withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: (module['color'] as Color).withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  module['icon'] as IconData,
                  color: isSelected
                      ? module['color'] as Color
                      : const Color(0xFF9CA3AF),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    module['name'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFFD1D5DB),
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: module['color'] as Color,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Item del footer
  Widget _buildFooterMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF9CA3AF),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFD1D5DB),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Header fijo para móvil
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(
        widget.businessName,
        style: const TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: _showNotificationsPanel,
            ),
            if (_unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    _unreadCount > 99 ? '99+' : '$_unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.businessName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getCategoryName(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Notificaciones y perfil
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showNotificationsPanel,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF1F2937),
                      size: 24,
                    ),
                    if (_unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            _unreadCount > 99 ? '99+' : '$_unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person,
              color: _categoryColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToModule(String moduleId) {
    final context = this.context;
    switch (moduleId) {
      case 'dashboard':
        context.go('/dashboard');
        break;
      case 'pos':
        context.go('/pos');
        break;
      case 'inventory':
        context.go('/inventory');
        break;
      case 'clients':
        context.go('/clients');
        break;
      case 'cash':
        context.go('/cash');
        break;
      case 'reports':
        context.go('/reports');
        break;
      case 'suppliers':
      case 'providers':
        context.go('/providers');
        break;
      case 'purchases':
        context.go('/purchases');
        break;
      case 'credits':
        context.go('/credits');
        break;
      case 'myscore':
        context.go('/myscore');
        break;
      case 'pronostics':
        context.go('/pronostics');
        break;
      case 'notifications':
        context.go('/notifications');
        break;
      case 'settings':
        context.go('/settings');
        break;
      case 'help':
        context.go('/help');
        break;
      // Agregar más casos según sea necesario
      default:
        context.go('/dashboard');
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.businessCategory) {
      case 'abarrotes':
        return Icons.store;
      case 'ropa_calzado':
        return Icons.checkroom;
      case 'hogar_decoracion':
        return Icons.home;
      case 'electronica':
        return Icons.smartphone;
      case 'verduleria':
        return Icons.eco;
      case 'papa_mayorista':
        return Icons.agriculture;
      case 'carniceria':
        return Icons.restaurant;
      case 'ferreteria':
        return Icons.build;
      case 'farmacia':
        return Icons.local_pharmacy;
      case 'restaurante':
        return Icons.restaurant_menu;
      case 'mayorista':
        return Icons.inventory_2;
      default:
        return Icons.category;
    }
  }

  String _getCategoryName() {
    switch (widget.businessCategory) {
      case 'abarrotes':
        return 'Abarrotes / Bodega';
      case 'ropa_calzado':
        return 'Ropa, Calzado y Accesorios';
      case 'hogar_decoracion':
        return 'Hogar y Decoración';
      case 'electronica':
        return 'Electrónica y Tecnología';
      case 'verduleria':
        return 'Verdulería / Frutas';
      case 'papa_mayorista':
        return 'Venta de Papa / Tubérculos';
      case 'carniceria':
        return 'Carnicería / Pollería';
      case 'ferreteria':
        return 'Ferretería / Construcción';
      case 'farmacia':
        return 'Farmacia / Botica';
      case 'restaurante':
        return 'Restaurante / Comida';
      case 'mayorista':
        return 'Mayorista / Distribuidor';
      default:
        return 'Otro / General';
    }
  }

  void _showNotificationsPanel() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    if (isMobile) {
      // Bottom sheet para móvil
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildNotificationsBottomSheet(),
      );
    } else {
      // Popup para desktop
      showDialog(
        context: context,
        builder: (context) => _buildNotificationsDialog(),
      );
    }
  }

  Widget _buildNotificationsBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const Text(
                      'Notificaciones',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (_unreadCount > 0)
                      TextButton(
                        onPressed: _markAllAsRead,
                        child: const Text('Marcar todas como leídas'),
                      ),
                    TextButton(
                      onPressed: () {
                        context.go('/notifications');
                        Navigator.pop(context);
                      },
                      child: const Text('Ver todas'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Lista de notificaciones
              Expanded(
                child: _buildNotificationsList(scrollController),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationsDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        height: 600,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Text(
                    'Notificaciones',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (_unreadCount > 0)
                    TextButton(
                      onPressed: _markAllAsRead,
                      child: const Text('Marcar todas como leídas'),
                    ),
                  TextButton(
                    onPressed: () {
                      context.go('/notifications');
                      Navigator.pop(context);
                    },
                    child: const Text('Ver todas'),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Lista de notificaciones
            Expanded(
              child: _buildNotificationsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList([ScrollController? scrollController]) {
    if (_isLoadingNotifications) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay notificaciones',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: _notifications.length > 10 ? 10 : _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final isRead = notification['read'] as bool;
    final type = notification['type'] as String;
    final priority = notification['priority'] as String;
    
    Color priorityColor;
    IconData typeIcon;
    
    switch (type) {
      case 'low_stock':
        priorityColor = const Color(0xFFF59E0B);
        typeIcon = Icons.inventory_2;
        break;
      case 'expiring':
        priorityColor = const Color(0xFFEF4444);
        typeIcon = Icons.calendar_today;
        break;
      case 'delinquent':
        priorityColor = const Color(0xFFDC2626);
        typeIcon = Icons.warning;
        break;
      default:
        priorityColor = const Color(0xFF6B7280);
        typeIcon = Icons.info;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : priorityColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead ? Colors.grey[200]! : priorityColor.withOpacity(0.2),
              width: isRead ? 1 : 2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(typeIcon, color: priorityColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: priorityColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(notification['timestamp'] as DateTime),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Marcar como leída
    setState(() {
      notification['read'] = true;
      _unreadCount = _notifications.where((n) => !n['read']).length;
    });

    final type = notification['type'] as String;
    final data = notification['data'] as Map<String, dynamic>;

    // Navegar según el tipo de notificación
    switch (type) {
      case 'low_stock':
      case 'expiring':
        context.go('/inventory');
        break;
      case 'delinquent':
        context.go('/clients');
        break;
    }

    // Cerrar el panel si está abierto
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
      _unreadCount = 0;
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Color(0xFFEF4444)),
            SizedBox(width: 12),
            Text('Confirmar Salida'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas salir de la sesión?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    // Cerrar drawer si está abierto (móvil)
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Limpiar estado de la aplicación
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.clearBusiness();
    appProvider.setBusinessConfigurations({});
    appProvider.clearError();

    // Navegar a la pantalla de login
    context.go('/');
    
    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('Sesión cerrada correctamente'),
            ),
          ],
        ),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

