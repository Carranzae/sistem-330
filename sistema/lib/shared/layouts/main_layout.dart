import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _buildFooterMenuItem(
                  icon: Icons.logout,
                  label: 'Salir',
                  onTap: () {
                    // Lógica de logout
                  },
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
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _buildFooterMenuItem(
                    icon: Icons.logout,
                    label: 'Salir',
                    onTap: () {
                      // Lógica de logout
                    },
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
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF1F2937),
              size: 24,
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
}

