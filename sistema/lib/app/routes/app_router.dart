import 'package:go_router/go_router.dart';

// Importar pantallas
import '../../presentation/features/auth/pages/login_page.dart';
import '../../presentation/features/onboarding/pages/onboarding_page.dart';
import '../../presentation/features/dashboard/pages/dashboard_page.dart';
import '../../presentation/features/pos/pages/pos_page.dart';
import '../../presentation/features/inventory/pages/inventory_page.dart';
import '../../presentation/features/clients/pages/clients_page.dart';
import '../../presentation/features/cash/pages/cash_page.dart';
import '../../presentation/features/reports/pages/reports_page.dart';
import '../../presentation/features/providers/pages/providers_page.dart';
import '../../presentation/features/documents/pages/billing_page.dart';
import '../../presentation/features/payments/pages/zipay_config_page.dart';
import '../../presentation/features/printer/pages/printer_config_page.dart';
import '../../presentation/features/financial/pages/financial_statement_page.dart';

// Nuevos módulos para abarrotes
import '../../presentation/features/purchases/pages/purchases_page.dart';
import '../../presentation/features/credits/pages/credits_page.dart';
import '../../presentation/features/score/pages/myscore_page.dart';
import '../../presentation/features/pronostics/pages/pronostics_page.dart';
import '../../presentation/features/notifications/pages/notifications_page.dart';
import '../../presentation/features/settings/pages/settings_page.dart';
import '../../presentation/features/help/pages/help_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/pos',
      builder: (context, state) => const POSPage(),
    ),
    GoRoute(
      path: '/inventory',
      builder: (context, state) => const InventoryPage(),
    ),
    GoRoute(
      path: '/clients',
      builder: (context, state) => const ClientsPage(),
    ),
    GoRoute(
      path: '/cash',
      builder: (context, state) => const CashPage(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsPage(),
    ),
    GoRoute(
      path: '/providers',
      builder: (context, state) => const ProvidersPage(),
    ),
    // Documentos (Boletas y Facturas)
    GoRoute(
      path: '/boletas',
      builder: (context, state) => const BillingPage(type: 'boleta'),
    ),
    GoRoute(
      path: '/facturas',
      builder: (context, state) => const BillingPage(type: 'factura'),
    ),
    // Financiero
    GoRoute(
      path: '/financial',
      builder: (context, state) => const FinancialStatementPage(),
    ),
    // Configuraciones
    GoRoute(
      path: '/config/zipay',
      builder: (context, state) => const ZipayConfigPage(),
    ),
    GoRoute(
      path: '/config/printer',
      builder: (context, state) => const PrinterConfigPage(),
    ),
    // Nuevos módulos para abarrotes
    GoRoute(
      path: '/purchases',
      builder: (context, state) => const PurchasesPage(),
    ),
    GoRoute(
      path: '/credits',
      builder: (context, state) => const CreditsPage(),
    ),
    GoRoute(
      path: '/myscore',
      builder: (context, state) => const MyScorePage(),
    ),
    GoRoute(
      path: '/pronostics',
      builder: (context, state) => const PronosticsPage(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpPage(),
    ),
  ],
);
