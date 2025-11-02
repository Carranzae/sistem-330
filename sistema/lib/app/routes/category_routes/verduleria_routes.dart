// Rutas específicas para VERDULERÍA / FRUTAS
import 'package:go_router/go_router.dart';
import '../../../presentation/features/dashboard/pages/dashboard_page.dart';
import '../../../presentation/features/pos/pages/pos_page.dart';
import '../../../presentation/features/inventory/pages/inventory_page.dart';
import '../../../presentation/features/clients/pages/clients_page.dart';
import '../../../presentation/features/cash/pages/cash_page.dart';
import '../../../presentation/features/reports/pages/reports_page.dart';

final verduleriaRoutes = GoRoute(
  path: '/verduleria',
  builder: (context, state) => const DashboardPage(),
  routes: [
    GoRoute(path: '/dashboard', name: 'verduleria_dashboard', builder: (context, state) => const DashboardPage()),
    GoRoute(path: '/pos', name: 'verduleria_pos', builder: (context, state) => const POSPage()),
    GoRoute(path: '/inventory', name: 'verduleria_inventory', builder: (context, state) => const InventoryPage()),
    GoRoute(path: '/clients', name: 'verduleria_clients', builder: (context, state) => const ClientsPage()),
    GoRoute(path: '/cash', name: 'verduleria_cash', builder: (context, state) => const CashPage()),
    GoRoute(path: '/reports', name: 'verduleria_reports', builder: (context, state) => const ReportsPage()),
  ],
);

