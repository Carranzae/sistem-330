// Rutas específicas para HOGAR Y DECORACIÓN
import 'package:go_router/go_router.dart';
import '../../../presentation/features/dashboard/pages/dashboard_page.dart';
import '../../../presentation/features/pos/pages/pos_page.dart';
import '../../../presentation/features/inventory/pages/inventory_page.dart';
import '../../../presentation/features/clients/pages/clients_page.dart';
import '../../../presentation/features/cash/pages/cash_page.dart';
import '../../../presentation/features/reports/pages/reports_page.dart';

final hogarDecoracionRoutes = GoRoute(
  path: '/hogar_decoracion',
  builder: (context, state) => const DashboardPage(),
  routes: [
    GoRoute(path: '/dashboard', name: 'hogar_decoracion_dashboard', builder: (context, state) => const DashboardPage()),
    GoRoute(path: '/pos', name: 'hogar_decoracion_pos', builder: (context, state) => const POSPage()),
    GoRoute(path: '/inventory', name: 'hogar_decoracion_inventory', builder: (context, state) => const InventoryPage()),
    GoRoute(path: '/clients', name: 'hogar_decoracion_clients', builder: (context, state) => const ClientsPage()),
    GoRoute(path: '/cash', name: 'hogar_decoracion_cash', builder: (context, state) => const CashPage()),
    GoRoute(path: '/reports', name: 'hogar_decoracion_reports', builder: (context, state) => const ReportsPage()),
  ],
);

