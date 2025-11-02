// Rutas específicas para RESTAURANTE / COMIDA
import 'package:go_router/go_router.dart';
import '../../../presentation/features/dashboard/pages/dashboard_page.dart';
import '../../../presentation/features/pos/pages/pos_page.dart';
import '../../../presentation/features/inventory/pages/inventory_page.dart';
import '../../../presentation/features/clients/pages/clients_page.dart';
import '../../../presentation/features/cash/pages/cash_page.dart';
import '../../../presentation/features/reports/pages/reports_page.dart';

final restauranteRoutes = GoRoute(
  path: '/restaurante',
  builder: (context, state) => const DashboardPage(),
  routes: [
    GoRoute(path: '/dashboard', name: 'restaurante_dashboard', builder: (context, state) => const DashboardPage()),
    GoRoute(path: '/pos', name: 'restaurante_pos', builder: (context, state) => const POSPage()),
    GoRoute(path: '/inventory', name: 'restaurante_inventory', builder: (context, state) => const InventoryPage()),
    GoRoute(path: '/clients', name: 'restaurante_clients', builder: (context, state) => const ClientsPage()),
    GoRoute(path: '/cash', name: 'restaurante_cash', builder: (context, state) => const CashPage()),
    GoRoute(path: '/reports', name: 'restaurante_reports', builder: (context, state) => const ReportsPage()),
  ],
);

