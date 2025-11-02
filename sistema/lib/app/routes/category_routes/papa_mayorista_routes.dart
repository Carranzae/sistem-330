// Rutas específicas para VENTA DE PAPA / TUBÉRCULOS
import 'package:go_router/go_router.dart';
import '../../../presentation/features/dashboard/pages/dashboard_page.dart';
import '../../../presentation/features/pos/pages/pos_page.dart';
import '../../../presentation/features/inventory/pages/inventory_page.dart';
import '../../../presentation/features/clients/pages/clients_page.dart';
import '../../../presentation/features/cash/pages/cash_page.dart';
import '../../../presentation/features/reports/pages/reports_page.dart';

final papaMayoristaRoutes = GoRoute(
  path: '/papa_mayorista',
  builder: (context, state) => const DashboardPage(),
  routes: [
    GoRoute(path: '/dashboard', name: 'papa_mayorista_dashboard', builder: (context, state) => const DashboardPage()),
    GoRoute(path: '/pos', name: 'papa_mayorista_pos', builder: (context, state) => const POSPage()),
    GoRoute(path: '/inventory', name: 'papa_mayorista_inventory', builder: (context, state) => const InventoryPage()),
    GoRoute(path: '/clients', name: 'papa_mayorista_clients', builder: (context, state) => const ClientsPage()),
    GoRoute(path: '/cash', name: 'papa_mayorista_cash', builder: (context, state) => const CashPage()),
    GoRoute(path: '/reports', name: 'papa_mayorista_reports', builder: (context, state) => const ReportsPage()),
  ],
);

