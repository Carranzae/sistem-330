// Rutas específicas para ROPA, CALZADO Y ACCESORIOS
import 'package:go_router/go_router.dart';
import '../../../presentation/features/dashboard/pages/dashboard_page.dart';
import '../../../presentation/features/ropa_calzado/dashboard/pages/ropa_calzado_dashboard_page.dart';
import '../../../presentation/features/pos/pages/pos_page.dart';
import '../../../presentation/features/inventory/pages/inventory_page.dart';
import '../../../presentation/features/inventory/pages/add_product_page.dart';
import '../../../presentation/features/clients/pages/clients_page.dart';
import '../../../presentation/features/cash/pages/cash_page.dart';
import '../../../presentation/features/reports/pages/reports_page.dart';
// Nuevas importaciones para el módulo de ropa y calzado
import '../../../presentation/features/ropa_calzado/marketplace/pages/marketplace_page.dart';
import '../../../presentation/features/ropa_calzado/marketplace/pages/product_detail_page.dart';
import '../../../presentation/features/ropa_calzado/marketplace/pages/virtual_fitting_page.dart';
import '../../../presentation/features/ropa_calzado/marketplace/pages/checkout_page.dart';
import '../../../presentation/features/ropa_calzado/marketplace/pages/product_gallery_page.dart';
import '../../../presentation/features/ropa_calzado/inventory/pages/collection_manager_page.dart';
import '../../../presentation/features/ropa_calzado/inventory/pages/variant_manager_page.dart';

final ropaCalzadoRoutes = GoRoute(
  path: '/ropa_calzado',
  builder: (context, state) => const RopaCalzadoDashboardPage(),
  routes: [
    GoRoute(path: 'dashboard', name: 'ropa_calzado_dashboard', builder: (context, state) => const RopaCalzadoDashboardPage()),
    GoRoute(path: 'pos', name: 'ropa_calzado_pos', builder: (context, state) => const POSPage()),
    GoRoute(path: 'inventory', name: 'ropa_calzado_inventory', builder: (context, state) => const InventoryPage()),
    GoRoute(path: 'clients', name: 'ropa_calzado_clients', builder: (context, state) => const ClientsPage()),
    GoRoute(path: 'cash', name: 'ropa_calzado_cash', builder: (context, state) => const CashPage()),
    GoRoute(path: 'reports', name: 'ropa_calzado_reports', builder: (context, state) => const ReportsPage()),
    
    // Nuevas rutas para el marketplace y funcionalidades específicas de ropa y calzado
    GoRoute(path: 'marketplace', name: 'ropa_calzado_marketplace', builder: (context, state) => const MarketplacePage()),
    // Soporte de rutas anidadas dentro de marketplace
    GoRoute(path: 'marketplace/product/:id', name: 'ropa_calzado_marketplace_product_detail', builder: (context, state) {
      final productId = state.pathParameters['id']!;
      return ProductDetailPage(productId: productId);
    }),
    GoRoute(path: 'marketplace/virtual-fitting/:id', name: 'ropa_calzado_marketplace_virtual_fitting', builder: (context, state) {
      final productId = state.pathParameters['id']!;
      return VirtualFittingPage(productId: productId);
    }),
    GoRoute(path: 'marketplace/checkout', name: 'ropa_calzado_marketplace_checkout', builder: (context, state) => const CheckoutPage()),
    GoRoute(path: 'gallery', name: 'ropa_calzado_gallery', builder: (context, state) => const ProductGalleryPage()),
    GoRoute(path: 'product/:id', name: 'ropa_calzado_product_detail', builder: (context, state) {
      final productId = state.pathParameters['id']!;
      return ProductDetailPage(productId: productId);
    }),
    GoRoute(path: 'virtual-fitting/:id', name: 'ropa_calzado_virtual_fitting', builder: (context, state) {
      final productId = state.pathParameters['id']!;
      return VirtualFittingPage(productId: productId);
    }),
    GoRoute(path: 'checkout', name: 'ropa_calzado_checkout', builder: (context, state) => const CheckoutPage()),
    GoRoute(path: 'collections', name: 'ropa_calzado_collections', builder: (context, state) => const CollectionManagerPage()),
    GoRoute(path: 'variants', name: 'ropa_calzado_variants', builder: (context, state) => const VariantManagerPage()),
  ],
);

