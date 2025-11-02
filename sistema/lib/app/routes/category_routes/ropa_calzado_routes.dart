// Rutas específicas para ROPA, CALZADO Y ACCESORIOS
import 'package:go_router/go_router.dart';
import '../../../presentation/features/dashboard/pages/dashboard_page.dart';
import '../../../presentation/features/pos/pages/pos_page.dart';
import '../../../presentation/features/inventory/pages/inventory_page.dart';
import '../../../presentation/features/inventory/pages/add_product_page.dart';
import '../../../presentation/features/clients/pages/clients_page.dart';
import '../../../presentation/features/cash/pages/cash_page.dart';
import '../../../presentation/features/reports/pages/reports_page.dart';

final ropaCalzadoRoutes = GoRoute(
  path: '/ropa_calzado',
  builder: (context, state) => const DashboardPage(),
  routes: [
    GoRoute(path: '/dashboard', name: 'ropa_calzado_dashboard', builder: (context, state) => const DashboardPage()),
    GoRoute(path: '/pos', name: 'ropa_calzado_pos', builder: (context, state) => const POSPage()),
    GoRoute(path: '/inventory', name: 'ropa_calzado_inventory', builder: (context, state) => const InventoryPage()),
    GoRoute(path: '/clients', name: 'ropa_calzado_clients', builder: (context, state) => const ClientsPage()),
    GoRoute(path: '/cash', name: 'ropa_calzado_cash', builder: (context, state) => const CashPage()),
    GoRoute(path: '/reports', name: 'ropa_calzado_reports', builder: (context, state) => const ReportsPage()),
  ],
);

