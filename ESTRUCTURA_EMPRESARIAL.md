# 🏢 Estructura Empresarial - Sistema Multi-Negocio

## 📁 NUEVA ESTRUCTURA RECOMENDADA

```
lib/
├── core/                              # Core compartido entre todos los módulos
│   ├── config/
│   │   ├── app_config.dart           # Configuración global
│   │   └── environments/
│   │       ├── dev.dart
│   │       ├── staging.dart
│   │       └── prod.dart
│   │
│   ├── constants/
│   │   ├── api_endpoints.dart
│   │   ├── app_strings.dart
│   │   ├── app_colors.dart
│   │   └── dimensions.dart
│   │
│   ├── errors/
│   │   ├── exceptions.dart
│   │   ├── failures.dart
│   │   └── error_handler.dart
│   │
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── network_info.dart
│   │   └── interceptors.dart
│   │
│   ├── storage/
│   │   ├── local_storage.dart
│   │   ├── secure_storage.dart
│   │   └── cache_manager.dart
│   │
│   ├── utils/
│   │   ├── date_formatters.dart
│   │   ├── currency_formatters.dart
│   │   ├── validators.dart
│   │   ├── extensions.dart
│   │   └── logger.dart
│   │
│   ├── di/                             # Dependency Injection
│   │   └── injector.dart
│   │
│   ├── routes/
│   │   ├── app_router.dart
│   │   └── route_names.dart
│   │
│   └── themes/
│       ├── app_theme.dart
│       ├── light_theme.dart
│       └── dark_theme.dart
│
├── data/                               # Capa de Datos
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── local_datasource.dart
│   │   │   └── db_helper.dart         # SQLite
│   │   └── remote/
│   │       ├── remote_datasource.dart
│   │       └── supabase_datasource.dart
│   │
│   ├── models/                         # Models de datos
│   │   ├── business_model.dart
│   │   ├── product_model.dart
│   │   ├── sale_model.dart
│   │   ├── client_model.dart
│   │   └── provider_model.dart
│   │
│   ├── repositories/
│   │   └── [feature]_repository_impl.dart
│   │
│   └── migrations/
│       └── migration_helper.dart
│
├── domain/                             # Capa de Dominio (Lógica de Negocio)
│   ├── entities/                       # Entidades puras
│   │   ├── business.dart
│   │   ├── product.dart
│   │   ├── sale.dart
│   │   ├── client.dart
│   │   └── provider.dart
│   │
│   ├── repositories/                   # Interfaces de repositorios
│   │   ├── business_repository.dart
│   │   ├── product_repository.dart
│   │   ├── sale_repository.dart
│   │   ├── client_repository.dart
│   │   └── provider_repository.dart
│   │
│   ├── usecases/                       # Casos de uso
│   │   ├── business/
│   │   │   ├── get_business_usecase.dart
│   │   │   └── update_business_usecase.dart
│   │   ├── products/
│   │   │   ├── get_products_usecase.dart
│   │   │   ├── add_product_usecase.dart
│   │   │   ├── update_product_usecase.dart
│   │   │   └── delete_product_usecase.dart
│   │   ├── sales/
│   │   │   ├── create_sale_usecase.dart
│   │   │   └── get_sales_usecase.dart
│   │   ├── inventory/
│   │   │   ├── adjust_stock_usecase.dart
│   │   │   └── get_low_stock_usecase.dart
│   │   └── financial/
│   │       ├── get_sales_by_period_usecase.dart
│   │       └── generate_statement_usecase.dart
│   │
│   └── value_objects/                  # Value Objects
│       ├── price.dart
│       ├── stock.dart
│       └── currency.dart
│
├── presentation/                       # Capa de Presentación
│   ├── features/
│   │   ├── auth/
│   │   │   ├── domain/
│   │   │   │   └── models/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── auth_provider.dart
│   │   │       ├── pages/
│   │   │       │   ├── login_page.dart
│   │   │       │   └── register_page.dart
│   │   │       └── widgets/
│   │   │
│   │   ├── onboarding/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── onboarding_provider.dart
│   │   │       ├── pages/
│   │   │       │   ├── onboarding_page.dart
│   │   │       │   ├── register_step.dart
│   │   │       │   ├── business_data_step.dart
│   │   │       │   ├── business_category_step.dart
│   │   │       │   ├── configuration_step.dart
│   │   │       │   └── confirmation_step.dart
│   │   │       └── widgets/
│   │   │
│   │   ├── dashboard/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── dashboard_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── dashboard_page.dart
│   │   │       └── widgets/
│   │   │           ├── metric_card.dart
│   │   │           ├── quick_action_card.dart
│   │   │           └── sales_chart.dart
│   │   │
│   │   ├── pos/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── pos_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── pos_page.dart
│   │   │       └── widgets/
│   │   │           ├── product_card.dart
│   │   │           ├── cart_item.dart
│   │   │           └── payment_dialog.dart
│   │   │
│   │   ├── inventory/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── inventory_provider.dart
│   │   │       ├── pages/
│   │   │       │   ├── inventory_page.dart
│   │   │       │   ├── add_product_page.dart
│   │   │       │   ├── edit_product_page.dart
│   │   │       │   └── movements_page.dart
│   │   │       └── widgets/
│   │   │           ├── product_list_item.dart
│   │   │           ├── stock_alert_badge.dart
│   │   │           ├── qr_code_dialog.dart
│   │   │           └── qr_scanner_page.dart
│   │   │
│   │   ├── sales/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── sales_provider.dart
│   │   │       ├── pages/
│   │   │       │   ├── sales_history_page.dart
│   │   │       │   └── sale_detail_page.dart
│   │   │       └── widgets/
│   │   │           └── sale_card.dart
│   │   │
│   │   ├── clients/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── clients_provider.dart
│   │   │       ├── pages/
│   │   │       │   ├── clients_page.dart
│   │   │       │   ├── add_client_page.dart
│   │   │       │   └── client_detail_page.dart
│   │   │       └── widgets/
│   │   │           └── client_card.dart
│   │   │
│   │   ├── providers/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── providers_provider.dart
│   │   │       └── pages/
│   │   │           ├── providers_page.dart
│   │   │           └── add_provider_page.dart
│   │   │
│   │   ├── financial/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── financial_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── financial_statement_page.dart
│   │   │       └── widgets/
│   │   │           ├── statement_chart.dart
│   │   │           └── period_selector.dart
│   │   │
│   │   ├── documents/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── documents_provider.dart
│   │   │       ├── pages/
│   │   │       │   ├── billing_page.dart
│   │   │       │   └── document_history_page.dart
│   │   │       └── widgets/
│   │   │
│   │   ├── payments/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── payments_provider.dart
│   │   │       └── pages/
│   │   │           └── zipay_config_page.dart
│   │   │
│   │   └── printer/
│   │       └── presentation/
│   │           ├── providers/
│   │           │   └── printer_provider.dart
│   │           └── pages/
│   │               └── printer_config_page.dart
│   │
│   ├── shared/
│   │   ├── widgets/
│   │   │   ├── buttons/
│   │   │   │   ├── primary_button.dart
│   │   │   │   ├── secondary_button.dart
│   │   │   │   └── icon_button.dart
│   │   │   ├── inputs/
│   │   │   │   ├── custom_textfield.dart
│   │   │   │   ├── custom_dropdown.dart
│   │   │   │   └── date_picker.dart
│   │   │   ├── cards/
│   │   │   │   ├── info_card.dart
│   │   │   │   └── metric_card.dart
│   │   │   ├── dialogs/
│   │   │   │   ├── confirmation_dialog.dart
│   │   │   │   └── loading_dialog.dart
│   │   │   ├── layouts/
│   │   │   │   ├── main_layout.dart
│   │   │   │   ├── responsive_layout.dart
│   │   │   │   └── page_layout.dart
│   │   │   └── loaders/
│   │   │       ├── skeleton_loader.dart
│   │   │       └── shimmer_loader.dart
│   │   │
│   │   └── providers/
│   │       └── global_providers/
│   │           ├── theme_provider.dart
│   │           ├── language_provider.dart
│   │           └── connectivity_provider.dart
│   │
│   └── providers/
│       ├── auth_provider.dart
│       ├── business_provider.dart
│       └── app_provider.dart
│
├── app/
│   ├── main.dart
│   ├── providers/
│   │   └── app_provider.dart
│   └── routes/
│       └── app_router.dart
│
└── generated/                          # Archivos generados
    └── routes.dart
```

## 🎯 PRINCIPIOS DE LA NUEVA ARQUITECTURA

### 1. CLEAN ARCHITECTURE
**Separación de Responsabilidades:**

```
┌─────────────────────────────────────────────────────────┐
│              PRESENTATION LAYER                         │
│  (UI, Widgets, Providers/Controllers, ViewModels)      │
│  - Solo maneja la UI                                    │
│  - Llama a Use Cases                                    │
│  - No conoce fuentes de datos                           │
└─────────────────────────────────────────────────────────┘
                          ↓ ↑
┌─────────────────────────────────────────────────────────┐
│              DOMAIN LAYER                               │
│  (Entities, Use Cases, Repository Interfaces)          │
│  - Contiene lógica de negocio pura                     │
│  - Independiente de frameworks                          │
│  - No conoce UI ni base de datos                       │
│  - Define qué necesita (interfaces)                     │
└─────────────────────────────────────────────────────────┘
                          ↓ ↑
┌─────────────────────────────────────────────────────────┐
│              DATA LAYER                                 │
│  (Models, DataSources, Repository Implementations)     │
│  - Implementa interfaces del Domain                     │
│  - Maneja datos locales (SQLite)                       │
│  - Maneja datos remotos (Supabase/API)                 │
│  - Convierte Models ↔ Entities                         │
└─────────────────────────────────────────────────────────┘
```

### 2. DEPENDENCY INJECTION (DI)
**Beneficios:**
- ✅ Testeable (mock fácil de dependencias)
- ✅ Desacoplado
- ✅ Flexible

**Implementación:**
```dart
// Manual (simple)
class ProductProvider extends ChangeNotifier {
  final GetProductsUseCase _getProducts;
  final AddProductUseCase _addProduct;
  
  ProductProvider(this._getProducts, this._addProduct);
}

// Con get_it (recomendado)
final getIt = GetIt.instance;

void setupDependencies() {
  // Repository
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      local: ProductLocalDataSourceImpl(),
      remote: ProductRemoteDataSourceImpl(),
    ),
  );
  
  // Use Cases
  getIt.registerFactory(() => GetProductsUseCase(getIt()));
  getIt.registerFactory(() => AddProductUseCase(getIt()));
  
  // Providers
  getIt.registerFactory(() => ProductProvider(
    getIt(),
    getIt(),
  ));
}
```

### 3. REPOSITORY PATTERN
**Abstracción de fuentes de datos:**

```dart
// Domain Layer - Interface
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts(String businessId);
  Future<Either<Failure, Product>> addProduct(Product product);
  Future<Either<Failure, void>> updateProduct(Product product);
  Future<Either<Failure, void>> deleteProduct(String productId);
}

// Data Layer - Implementación
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remote;
  final ProductLocalDataSource local;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Product>>> getProducts(String businessId) async {
    try {
      // 1. Intentar remoto si hay internet
      if (await networkInfo.isConnected) {
        final products = await remote.getProducts(businessId);
        await local.saveProducts(products);
        return Right(products.map((m) => m.toEntity()).toList());
      }
      // 2. Fallback a local
      final localProducts = await local.getProducts(businessId);
      return Right(localProducts.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

### 4. USE CASES (CU)
**Encapsulan lógica de negocio:**

```dart
class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<Product>>> execute(String businessId) async {
    if (businessId.isEmpty) {
      return Left(ValidationFailure('businessId requerido'));
    }
    return await repository.getProducts(businessId);
  }
}

class AddProductUseCase {
  final ProductRepository repository;
  final ProductValidator validator;

  AddProductUseCase(this.repository, this.validator);

  Future<Either<Failure, Product>> execute(Product product) async {
    final validation = validator.validate(product);
    if (!validation.isValid) {
      return Left(ValidationFailure(validation.error));
    }
    return await repository.addProduct(product);
  }
}
```

### 5. ERROR HANDLING
**Manejo estructurado de errores:**

```dart
// Errors/Failures
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  NetworkFailure() : super('Sin conexión a internet');
}

class ValidationFailure extends Failure {
  ValidationFailure(super.message);
}

class NotFoundFailure extends Failure {
  NotFoundFailure(String resource) : super('$resource no encontrado');
}

// Either Pattern
typedef Result<T> = Either<Failure, T>;

// Uso en UI
class ProductProvider extends ChangeNotifier {
  Future<void> loadProducts() async {
    final result = await _getProducts.execute(_businessId);
    
    result.fold(
      (failure) => _handleError(failure),
      (products) => _handleSuccess(products),
    );
  }
  
  void _handleError(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        showSnackBar('Sin conexión. Mostrando datos offline.');
        break;
      case ServerFailure:
        showSnackBar('Error del servidor. Intente más tarde.');
        break;
      default:
        showSnackBar(failure.message);
    }
  }
}
```

### 6. OFFLINE-FIRST
**Funcionalidad sin internet:**

```dart
// Sync Manager
class SyncManager {
  final ProductRepository repository;
  final NetworkInfo networkInfo;

  Future<void> syncData() async {
    if (!await networkInfo.isConnected) {
      return; // Nada que sincronizar
    }

    // 1. Obtener cambios locales pendientes
    final pendingChanges = await repository.getPendingSync();
    
    // 2. Subir cambios al servidor
    for (final change in pendingChanges) {
      await repository.uploadChange(change);
    }

    // 3. Bajar últimos cambios del servidor
    await repository.downloadLatest();
    
    // 4. Resolver conflictos si los hay
    await repository.resolveConflicts();
  }
}
```

## 🔄 FLUJO DE DATOS

```
USER ACTION (UI)
       ↓
   [Provider/ViewModel]
       ↓
   [Use Case]
       ↓
[Repository Interface]
       ↓
┌──────────────┬──────────────┐
│   Remote     │    Local     │
│  DataSource  │  DataSource  │
│  (Supabase)  │   (SQLite)   │
└──────────────┴──────────────┘
       ↓              ↓
   [Entity]  ←  [Model] →  [Entity]
       ↓
   [Provider] (actualiza estado)
       ↓
   [UI] (se re-renderiza)
```

## 📊 BENEFICIOS DE ESTA ESTRUCTURA

### ✅ Escalabilidad
- Nuevos features sin afectar existentes
- Equipos paralelos por módulo
- Crecimiento ilimitado

### ✅ Mantenibilidad
- Responsabilidades claras
- Fácil navegación
- Código auto-documentado

### ✅ Testeabilidad
- Mocks sencillos
- Tests aislados
- Cobertura alta

### ✅ Performance
- Offline-first
- Caché local
- Sincronización eficiente

### ✅ Seguridad
- Validaciones centralizadas
- Errores manejados
- Datos encriptados

## 🚀 PLAN DE MIGRACIÓN

### FASE 1: Setup Base
1. Crear nueva estructura de carpetas
2. Implementar DI con get_it
3. Crear base de errores y failures
4. Setup SQLite

### FASE 2: Migrar Feature por Feature
1. Products (prioridad alta)
2. Inventory
3. Sales
4. Clients

### FASE 3: Integrar
1. Providers separados
2. Offline sync
3. Error handling global

### FASE 4: Optimizar
1. Performance
2. Testing
3. Documentación

---

**¿Empezamos con la refactorización?** 🎯

