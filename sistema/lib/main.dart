import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'app/config/app_config.dart';
import 'app/providers/app_provider.dart';
import 'app/routes/app_router.dart';
import 'features/credits/data/datasources/credit_local_data_source.dart';
import 'features/credits/data/repositories/credit_repository_impl.dart';
import 'features/credits/presentation/providers/credit_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase solo si las credenciales están configuradas
  if (AppConfig.supabaseUrl != 'TU_URL_SUPABASE' && 
      AppConfig.supabaseAnonKey != 'TU_ANON_KEY') {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
    } catch (e) {
      // Si falla la inicialización, continuar sin Supabase (modo demo)
      debugPrint('Warning: No se pudo inicializar Supabase: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(
          create: (_) => CreditProvider(
            creditRepository: CreditRepositoryImpl(
              localDataSource: CreditLocalDataSourceImpl(),
            ),
          )..fetchCredits(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Sistema Multi-Negocio',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
          ),
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
