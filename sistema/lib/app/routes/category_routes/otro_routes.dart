// Rutas específicas para OTRO / GENERAL
import 'package:go_router/go_router.dart';
import '../../../presentation/features/dashboard/pages/dashboard_page.dart';
import '../../../presentation/features/pos/pages/pos_page.dart';
import '../../../presentation/features/inventory/pages/inventory_page.dart';
import '../../../presentation/features/clients/pages/clients_page.dart';
import '../../../presentation/features/cash/pages/cash_page.dart';
import '../../../presentation/features/reports/pages/reports_page.dart';

final otroRoutes = GoRoute(
  path: '/otro',
  builder: (context, state) => const DashboardPage(),
  routes: [
    GoRoute(path: '/dashboard', name: 'otro_dashboard', builder: (context, state) => const DashboardPage()),
    GoRoute(path: '/pos', name: 'otro_pos', builder: (context, state) => const POSPage()),
    GoRoute(path: '/inventory', name: 'otro_inventory', builder: (context, state) => const InventoryPage()),
    GoRoute(path: '/clients', name: 'otro_clients', builder: (context, state) => const ClientsPage()),
    GoRoute(path: '/cash', name: 'otro_cash', builder: (context, state) => const CashPage()),
    GoRoute(path: '/reports', name: 'otro_reports', builder: (context, state) => const ReportsPage()),
  ],
);

