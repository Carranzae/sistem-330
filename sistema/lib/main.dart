import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/providers/app_provider.dart';
import 'app/routes/app_router.dart';
import 'features/credits/data/datasources/credit_local_data_source.dart';
import 'features/credits/data/repositories/credit_repository_impl.dart';
import 'features/credits/presentation/providers/credit_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Inicializar PostgreSQL connection pool cuando se implemente
  
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
