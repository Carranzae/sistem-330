// Rutas específicas para MAYORISTA / DISTRIBUIDOR
import 'package:go_router/go_router.dart';
import '../../../presentation/features/dashboard/pages/dashboard_page.dart';
import '../../../presentation/features/pos/pages/pos_page.dart';
import '../../../presentation/features/inventory/pages/inventory_page.dart';
import '../../../presentation/features/clients/pages/clients_page.dart';
import '../../../presentation/features/cash/pages/cash_page.dart';
import '../../../presentation/features/reports/pages/reports_page.dart';

final mayoristaRoutes = GoRoute(
  path: '/mayorista',
  builder: (context, state) => const DashboardPage(),
  routes: [
    GoRoute(path: '/dashboard', name: 'mayorista_dashboard', builder: (context, state) => const DashboardPage()),
    GoRoute(path: '/pos', name: 'mayorista_pos', builder: (context, state) => const POSPage()),
    GoRoute(path: '/inventory', name: 'mayorista_inventory', builder: (context, state) => const InventoryPage()),
    GoRoute(path: '/clients', name: 'mayorista_clients', builder: (context, state) => const ClientsPage()),
    GoRoute(path: '/cash', name: 'mayorista_cash', builder: (context, state) => const CashPage()),
    GoRoute(path: '/reports', name: 'mayorista_reports', builder: (context, state) => const ReportsPage()),
  ],
);

