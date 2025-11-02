// Rutas específicas para FARMACIA / BOTICA
import 'package:go_router/go_router.dart';
import '../../../presentation/features/dashboard/pages/dashboard_page.dart';
import '../../../presentation/features/pos/pages/pos_page.dart';
import '../../../presentation/features/inventory/pages/inventory_page.dart';
import '../../../presentation/features/clients/pages/clients_page.dart';
import '../../../presentation/features/cash/pages/cash_page.dart';
import '../../../presentation/features/reports/pages/reports_page.dart';

final farmaciaRoutes = GoRoute(
  path: '/farmacia',
  builder: (context, state) => const DashboardPage(),
  routes: [
    GoRoute(path: '/dashboard', name: 'farmacia_dashboard', builder: (context, state) => const DashboardPage()),
    GoRoute(path: '/pos', name: 'farmacia_pos', builder: (context, state) => const POSPage()),
    GoRoute(path: '/inventory', name: 'farmacia_inventory', builder: (context, state) => const InventoryPage()),
    GoRoute(path: '/clients', name: 'farmacia_clients', builder: (context, state) => const ClientsPage()),
    GoRoute(path: '/cash', name: 'farmacia_cash', builder: (context, state) => const CashPage()),
    GoRoute(path: '/reports', name: 'farmacia_reports', builder: (context, state) => const ReportsPage()),
  ],
);

