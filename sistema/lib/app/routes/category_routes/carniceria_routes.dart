// Rutas específicas para CARNICERÍA / POLLERÍA
import 'package:go_router/go_router.dart';
import '../../../presentation/features/dashboard/pages/dashboard_page.dart';
import '../../../presentation/features/pos/pages/pos_page.dart';
import '../../../presentation/features/inventory/pages/inventory_page.dart';
import '../../../presentation/features/clients/pages/clients_page.dart';
import '../../../presentation/features/cash/pages/cash_page.dart';
import '../../../presentation/features/reports/pages/reports_page.dart';

final carniceriaRoutes = GoRoute(
  path: '/carniceria',
  builder: (context, state) => const DashboardPage(),
  routes: [
    GoRoute(path: '/dashboard', name: 'carniceria_dashboard', builder: (context, state) => const DashboardPage()),
    GoRoute(path: '/pos', name: 'carniceria_pos', builder: (context, state) => const POSPage()),
    GoRoute(path: '/inventory', name: 'carniceria_inventory', builder: (context, state) => const InventoryPage()),
    GoRoute(path: '/clients', name: 'carniceria_clients', builder: (context, state) => const ClientsPage()),
    GoRoute(path: '/cash', name: 'carniceria_cash', builder: (context, state) => const CashPage()),
    GoRoute(path: '/reports', name: 'carniceria_reports', builder: (context, state) => const ReportsPage()),
  ],
);

