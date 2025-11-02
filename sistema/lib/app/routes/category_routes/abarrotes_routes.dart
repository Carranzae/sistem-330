// Rutas específicas para ABARROTES / BODEGA
// Por ahora mantienen compatibilidad con estructura actual
// TODO: Migrar a Clean Architecture cuando esté implementado

// Nota: Estas rutas necesitan las páginas específicas creadas
// Actualmente usan las páginas existentes en features/

import 'package:go_router/go_router.dart';
import '../../../presentation/features/dashboard/pages/dashboard_page.dart';
import '../../../presentation/features/pos/pages/pos_page.dart';
import '../../../presentation/features/inventory/pages/inventory_page.dart';
import '../../../presentation/features/inventory/pages/add_product_page.dart';
import '../../../presentation/features/clients/pages/clients_page.dart';
import '../../../presentation/features/cash/pages/cash_page.dart';
import '../../../presentation/features/purchases/pages/purchases_page.dart';
import '../../../presentation/features/credits/pages/credits_page.dart';
import '../../../presentation/features/providers/pages/providers_page.dart';
import '../../../presentation/features/score/pages/myscore_page.dart';
import '../../../presentation/features/reports/pages/reports_page.dart';

/// Rutas específicas para categoría Abarrotes/Bodega
/// PATH: /abarrotes/dashboard, /abarrotes/pos, etc.
final abarrotesRoutes = GoRoute(
  path: '/abarrotes',
  builder: (context, state) {
    // TODO: Crear AbarrotesDashboardPage específico
    return const DashboardPage(); // Temporal
  },
  routes: [
    // Dashboard específico de abarrotes
    GoRoute(
      path: '/dashboard',
      name: 'abarrotes_dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    
    // POS de abarrotes
    GoRoute(
      path: '/pos',
      name: 'abarrotes_pos',
      builder: (context, state) => const POSPage(),
    ),
    
    // Inventario de abarrotes
    GoRoute(
      path: '/inventory',
      name: 'abarrotes_inventory',
      builder: (context, state) => const InventoryPage(),
      routes: [
        GoRoute(
          path: '/add',
          name: 'abarrotes_add_product',
          builder: (context, state) => const AddProductPage(),
        ),
      ],
    ),
    
    // Clientes
    GoRoute(
      path: '/clients',
      name: 'abarrotes_clients',
      builder: (context, state) => const ClientsPage(),
    ),
    
    // Caja
    GoRoute(
      path: '/cash',
      name: 'abarrotes_cash',
      builder: (context, state) => const CashPage(),
    ),
    
    // Compras
    GoRoute(
      path: '/purchases',
      name: 'abarrotes_purchases',
      builder: (context, state) => const PurchasesPage(),
    ),
    
    // Créditos y Fiados
    GoRoute(
      path: '/credits',
      name: 'abarrotes_credits',
      builder: (context, state) => const CreditsPage(),
    ),
    
    // Proveedores
    GoRoute(
      path: '/providers',
      name: 'abarrotes_providers',
      builder: (context, state) => const ProvidersPage(),
    ),
    
    // Mi Score
    GoRoute(
      path: '/score',
      name: 'abarrotes_score',
      builder: (context, state) => const MyScorePage(),
    ),
    
    // Reportes
    GoRoute(
      path: '/reports',
      name: 'abarrotes_reports',
      builder: (context, state) => const ReportsPage(),
    ),
  ],
);
