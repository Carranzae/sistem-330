import 'package:get_it/get_it.dart';

/// Dependency Injector usando GetIt
final sl = GetIt.instance;

/// Inicializar todas las dependencias
Future<void> init() async {
  // ============================================
  // EXTERNAL DEPENDENCIES
  // ============================================
  
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  // Connectivity
  sl.registerLazySingleton(() => Connectivity());
  
  // ============================================
  // CORE
  // ============================================
  
  // Network
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfo(sl()));
  sl.registerLazySingleton(() => ApiClient(baseUrl: AppConfig.apiUrl));
  
  // Storage
  sl.registerLazySingleton(() => LocalStorage());
  sl.registerLazySingleton(() => SecureStorage());
  
  // Logger
  sl.registerLazySingleton(() => Logger());
  
  // ============================================
  // REPOSITORIES
  // ============================================
  
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remote: sl(),
      local: sl(),
      network: sl(),
    ),
  );
  
  sl.registerLazySingleton<SecurityRepository>(
    () => SecurityRepositoryImpl(
      remote: sl(),
      local: sl(),
    ),
  );
  
  // ============================================
  // USE CASES
  // ============================================
  
  // Products
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => AddProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl()));
  
  // Security
  sl.registerLazySingleton(() => GetSecurityAlertsUseCase(sl()));
  sl.registerLazySingleton(() => LogSecurityEventUseCase(sl()));
  
  // ============================================
  // PROVIDERS
  // ============================================
  
  sl.registerFactory(() => ProductProvider(
    getProducts: sl(),
    addProduct: sl(),
    updateProduct: sl(),
    deleteProduct: sl(),
  ));
  
  sl.registerFactory(() => SecurityProvider(
    getAlerts: sl(),
    logEvent: sl(),
  ));
}

