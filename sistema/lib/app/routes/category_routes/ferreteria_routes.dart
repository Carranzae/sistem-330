// Rutas específicas para FERRETERÍA / CONSTRUCCIÓN
import 'package:go_router/go_router.dart';
import '../../../presentation/features/dashboard/pages/dashboard_page.dart';
import '../../../presentation/features/pos/pages/pos_page.dart';
import '../../../presentation/features/inventory/pages/inventory_page.dart';
import '../../../presentation/features/clients/pages/clients_page.dart';
import '../../../presentation/features/cash/pages/cash_page.dart';
import '../../../presentation/features/reports/pages/reports_page.dart';

final ferreteriaRoutes = GoRoute(
  path: '/ferreteria',
  builder: (context, state) => const DashboardPage(),
  routes: [
    GoRoute(path: '/dashboard', name: 'ferreteria_dashboard', builder: (context, state) => const DashboardPage()),
    GoRoute(path: '/pos', name: 'ferreteria_pos', builder: (context, state) => const POSPage()),
    GoRoute(path: '/inventory', name: 'ferreteria_inventory', builder: (context, state) => const InventoryPage()),
    GoRoute(path: '/clients', name: 'ferreteria_clients', builder: (context, state) => const ClientsPage()),
    GoRoute(path: '/cash', name: 'ferreteria_cash', builder: (context, state) => const CashPage()),
    GoRoute(path: '/reports', name: 'ferreteria_reports', builder: (context, state) => const ReportsPage()),
  ],
);

