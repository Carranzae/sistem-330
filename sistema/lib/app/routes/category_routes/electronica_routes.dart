// Rutas específicas para ELECTRÓNICA Y TECNOLOGÍA
import 'package:go_router/go_router.dart';
import '../../../presentation/features/dashboard/pages/dashboard_page.dart';
import '../../../presentation/features/pos/pages/pos_page.dart';
import '../../../presentation/features/inventory/pages/inventory_page.dart';
import '../../../presentation/features/clients/pages/clients_page.dart';
import '../../../presentation/features/cash/pages/cash_page.dart';
import '../../../presentation/features/reports/pages/reports_page.dart';

final electronicaRoutes = GoRoute(
  path: '/electronica',
  builder: (context, state) => const DashboardPage(),
  routes: [
    GoRoute(path: '/dashboard', name: 'electronica_dashboard', builder: (context, state) => const DashboardPage()),
    GoRoute(path: '/pos', name: 'electronica_pos', builder: (context, state) => const POSPage()),
    GoRoute(path: '/inventory', name: 'electronica_inventory', builder: (context, state) => const InventoryPage()),
    GoRoute(path: '/clients', name: 'electronica_clients', builder: (context, state) => const ClientsPage()),
    GoRoute(path: '/cash', name: 'electronica_cash', builder: (context, state) => const CashPage()),
    GoRoute(path: '/reports', name: 'electronica_reports', builder: (context, state) => const ReportsPage()),
  ],
);

