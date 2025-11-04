# 🏢 ARQUITECTURA EMPRESARIAL NIVEL PRODUCCIÓN

## 📋 ÍNDICE

1. [Visión General](#visión-general)
2. [Arquitectura Completa](#arquitectura-completa)
3. [Patrones Empresariales](#patrones-empresariales)
4. [Estructura Detallada](#estructura-detallada)
5. [Flujos de Datos](#flujos-de-datos)
6. [Rutas y Navegación por Categoría](#rutas-y-navegación-por-categoría)
7. [Arquitectura de Base de Datos PostgreSQL Escalable](#arquitectura-de-base-de-datos-postgresql-escalable)
8. [Testing Empresarial](#testing-empresarial)
9. [DevOps & CI/CD](#devops--cicd)
10. [Seguridad Empresarial](#seguridad-empresarial)
11. [Monitorización](#monitorización)

---

## 🎯 VISIÓN GENERAL

Una arquitectura empresarial de alto nivel debe ser:

✅ **Escalable**: Manejar crecimiento exponencial de usuarios y datos
✅ **Mantenible**: Código limpio, documentado y fácil de modificar
✅ **Testeable**: Tests unitarios, integración y E2E
✅ **Resiliente**: Manejo de errores, fallbacks, offline-first
✅ **Segura**: Encriptación, autenticación, autorización robusta
✅ **Performante**: Optimización de queries, caching, lazy loading
✅ **Observable**: Logs, métricas, tracing, alertas
✅ **Desplegable**: CI/CD automatizado, múltiples entornos

---

## 🏗️ ARQUITECTURA COMPLETA (3 CAPAS)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                               │
│                         (Capa de Presentación)                          │
├─────────────────────────────────────────────────────────────────────────┤
│  📱 Pages                   🔘 Controllers          🎨 Widgets         │
│  - DashboardPage            - ProductController    - ProductCard        │
│  - POSPage                  - SaleController       - CartItem           │
│  - InventoryPage            - InventoryController  - LoadingIndicator   │
│                                                      - ErrorBoundary    │
├─────────────────────────────────────────────────────────────────────────┤
│                    🧩 State Management (Provider/Riverpod)              │
│                    📡 API Clients / Data Sources                        │
│                    🔒 Authentication & Authorization                    │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↕
┌─────────────────────────────────────────────────────────────────────────┐
│                          DOMAIN LAYER                                   │
│                       (Capa de Lógica de Negocio)                       │
├─────────────────────────────────────────────────────────────────────────┤
│  🏛️ Entities            🔨 Use Cases        📦 Value Objects           │
│  - Business              - GetProducts      - Price                     │
│  - Product               - AddProduct       - Stock                     │
│  - Sale                  - CreateSale       - Currency                  │
│  - Client                - AdjustStock      - Address                   │
│                          - GetSalesReport                                │
├─────────────────────────────────────────────────────────────────────────┤
│  🔌 Repository Interfaces  (Abstracciones)                              │
│  - ProductRepository                                                    │
│  - SaleRepository                                                       │
│  - ClientRepository                                                     │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↕
┌─────────────────────────────────────────────────────────────────────────┐
│                            DATA LAYER                                   │
│                         (Capa de Datos)                                 │
├─────────────────────────────────────────────────────────────────────────┤
│  📊 Models             🗄️ DataSources        🔄 Repositories           │
│  - ProductModel        - Remote            - ProductRepositoryImpl      │
│  - SaleModel             (PostgreSQL)      - SaleRepositoryImpl         │
│  - ClientModel         - Local             - ClientRepositoryImpl       │
│  - ProviderModel         (SQLite)          - Cache (Redis/Memory)       │
│                          - Cache                                      │
├─────────────────────────────────────────────────────────────────────────┤
│  🌐 External Services                                                   │
│  - PostgreSQL Database (Cloud: Railway/Neon/AWS RDS)                   │
│  - Redis Cache (Sesiones y caché en memoria)                          │
│  - SUNAT API (Facturación electrónica)                                 │
│  - Yape/Plin API (Pagos)                                               │
│  - S3/CloudFlare (Storage de archivos e imágenes)                     │
│  - Push Notifications (Firebase FCM)                                   │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↕
                        ┌──────────────────────┐
                        │   INFRASTRUCTURE     │
                        │  - CI/CD Pipeline    │
                        │  - Monitoring        │
                        │  - Logging           │
                        │  - Error Tracking    │
                        └──────────────────────┘
```

---

## 📁 ESTRUCTURA DETALLADA

```
lib/
│
├── 📄 main.dart                           # Punto de entrada
│
├── 🎯 app/                                # Configuración App
│   ├── bootstrap/                         # Configuración inicial
│   │   ├── app_initializer.dart          # Setup inicial
│   │   └── dependency_injection.dart     # DI setup
│   │
│   ├── config/                           # Configuración
│   │   ├── app_config.dart               # Config general
│   │   ├── environments/
│   │   │   ├── dev.dart                  # Dev config
│   │   │   ├── staging.dart              # Staging config
│   │   │   └── production.dart           # Prod config
│   │   ├── app_strings.dart              # Strings i18n
│   │   ├── app_colors.dart               # Colores
│   │   └── app_sizes.dart                # Dimensiones
│   │
│   ├── routes/                           # Navegación
│   │   ├── app_router.dart               # Router principal
│   │   ├── route_guards.dart             # Guards
│   │   ├── route_names.dart              # Nombres constantes
│   │   │
│   │   └── category_routes/              # Rutas por Categoría
│   │       ├── abarrotes_routes.dart     # 🛒 Abarrotes/Bodega
│   │       ├── ropa_calzado_routes.dart  # 👗 Ropa y Calzado
│   │       ├── hogar_decoracion_routes.dart # 🏠 Hogar
│   │       ├── electronica_routes.dart   # 📱 Electrónica
│   │       ├── verduleria_routes.dart    # 🥦 Verdulería
│   │       ├── papa_mayorista_routes.dart # 🥔 Papa/Tubérculos
│   │       ├── carniceria_routes.dart    # 🍖 Carnicería
│   │       ├── ferreteria_routes.dart    # 🔧 Ferretería
│   │       ├── farmacia_routes.dart      # 💊 Farmacia
│   │       ├── restaurante_routes.dart   # 🍕 Restaurante
│   │       ├── mayorista_routes.dart     # 📦 Mayorista
│   │       └── otro_routes.dart          # 🏪 General
│   │
│   └── themes/                           # Temas
│       ├── app_theme.dart                # Tema base
│       ├── light_theme.dart              # Tema claro
│       └── dark_theme.dart               # Tema oscuro
│
├── 🏛️ core/                              # CORE EMPRESARIAL
│   │
│   ├── 📦 errors/                        # Manejo de Errores
│   │   ├── exceptions.dart               # Custom exceptions
│   │   ├── failures.dart                 # Failure classes
│   │   ├── error_handler.dart            # Error handler
│   │   └── error_mapper.dart             # Mapeo de errores
│   │
│   ├── 🌐 network/                       # Networking
│   │   ├── api_client.dart               # Cliente HTTP
│   │   ├── api_interceptors.dart         # Interceptors
│   │   ├── network_info.dart             # Info de red
│   │   └── request_timeout.dart          # Timeouts
│   │
│   ├── 💾 storage/                       # Almacenamiento
│   │   ├── local_storage.dart            # SQLite wrapper
│   │   ├── secure_storage.dart           # Encriptado
│   │   ├── cache_manager.dart            # Caché memory
│   │   └── sync_manager.dart             # Sync offline
│   │
│   ├── 🔒 security/                      # Seguridad
│   │   ├── encryption_service.dart       # Encriptación
│   │   ├── token_manager.dart            # Token JWT
│   │   ├── biometric_auth.dart           # Biométrico
│   │   ├── threat_detection_service.dart # Detección amenazas
│   │   ├── audit_logger.dart             # Auditoría
│   │   └── intrusion_detection.dart      # Detección intrusión
│   │
│   ├── 🔄 di/                            # Dependency Injection
│   │   ├── injector.dart                 # GetIt/Injector
│   │   ├── modules/
│   │   │   ├── network_module.dart
│   │   │   ├── storage_module.dart
│   │   │   └── repository_module.dart
│   │   └── usecase_module.dart
│   │
│   ├── 📊 analytics/                     # Analíticas
│   │   ├── analytics_service.dart        # Eventos
│   │   ├── crashlytics_service.dart      # Crash reports
│   │   └── performance_monitor.dart      # Performance
│   │
│   ├── 🔔 notifications/                 # Notificaciones
│   │   ├── push_notification_service.dart
│   │   ├── local_notification_service.dart
│   │   └── notification_handler.dart
│   │
│   ├── 🧮 utils/                         # Utilidades
│   │   ├── date_formatters.dart
│   │   ├── currency_formatters.dart
│   │   ├── validators.dart
│   │   ├── extensions.dart               # Extensions
│   │   ├── logger.dart                   # Logging
│   │   ├── debounce.dart                 # Debounce/Throttle
│   │   └── image_processor.dart          # Procesar imágenes
│   │
│   └── 🔧 middlewares/                   # Middlewares
│       ├── error_middleware.dart
│       ├── loading_middleware.dart
│       └── auth_middleware.dart
│
├── 📊 data/                              # CAPA DE DATOS
│   │
│   ├── 📥 datasources/                   # Fuentes de Datos
│   │   ├── remote/                       # Remoto
│   │   │   ├── postgres_datasource.dart  # PostgreSQL Cloud
│   │   │   ├── api_datasource.dart       # REST API
│   │   │   ├── redis_datasource.dart     # Cache Redis
│   │   │   └── third_party_datasource.dart
│   │   │
│   │   └── local/                        # Local
│   │       ├── sqlite_datasource.dart    # SQLite offline
│   │       ├── shared_prefs_datasource.dart
│   │       └── cache_datasource.dart     # Cache en memoria
│   │
│   ├── 📋 models/                        # Modelos de Datos
│   │   ├── business_model.dart           # con fromJson/toJson
│   │   ├── product_model.dart            # + mapper to entity
│   │   ├── sale_model.dart
│   │   ├── client_model.dart
│   │   └── provider_model.dart
│   │
│   ├── 🔄 repositories/                  # Implementación Repositorios
│   │   ├── product_repository_impl.dart
│   │   ├── sale_repository_impl.dart
│   │   ├── client_repository_impl.dart
│   │   └── inventory_repository_impl.dart
│   │
│   └── 🗄️ database/                     # Base de Datos Local
│       ├── app_database.dart             # SQLite
│       ├── entities/
│       │   ├── product_entity.dart       # Tablas
│       │   ├── sale_entity.dart
│       │   └── cache_entity.dart
│       └── migrations/
│           └── migration_helper.dart     # Migrations
│
├── 🎓 domain/                            # CAPA DE DOMINIO
│   │
│   ├── 🏛️ entities/                      # Entidades Puras
│   │   ├── business.dart                 # Sin dependencias
│   │   ├── product.dart                  # Solo Dart
│   │   ├── sale.dart
│   │   ├── client.dart
│   │   └── provider.dart
│   │
│   ├── 📦 repositories/                  # Interfaces
│   │   ├── product_repository.dart       # Abstracciones
│   │   ├── sale_repository.dart
│   │   ├── client_repository.dart
│   │   └── inventory_repository.dart
│   │
│   ├── 🎯 usecases/                      # Casos de Uso
│   │   ├── products/
│   │   │   ├── get_products_usecase.dart
│   │   │   ├── add_product_usecase.dart
│   │   │   ├── update_product_usecase.dart
│   │   │   ├── delete_product_usecase.dart
│   │   │   └── search_products_usecase.dart
│   │   │
│   │   ├── sales/
│   │   │   ├── create_sale_usecase.dart
│   │   │   ├── get_sales_usecase.dart
│   │   │   ├── get_sale_by_id_usecase.dart
│   │   │   └── void_sale_usecase.dart
│   │   │
│   │   ├── inventory/
│   │   │   ├── adjust_stock_usecase.dart
│   │   │   ├── get_low_stock_usecase.dart
│   │   │   ├── sync_inventory_usecase.dart
│   │   │   └── bulk_update_usecase.dart
│   │   │
│   │   ├── financial/
│   │   │   ├── calculate_profit_usecase.dart
│   │   │   ├── generate_report_usecase.dart
│   │   │   └── export_data_usecase.dart
│   │   │
│   │   └── auth/
│   │       ├── login_usecase.dart
│   │       ├── logout_usecase.dart
│   │       └── refresh_token_usecase.dart
│   │
│   ├── 🎁 value_objects/                 # Value Objects
│   │   ├── price.dart                    # Inmutables
│   │   ├── stock.dart                    # Validados
│   │   ├── currency.dart
│   │   ├── email.dart
│   │   └── address.dart
│   │
│   └── 📋 validators/                    # Validadores
│       ├── product_validator.dart
│       ├── sale_validator.dart
│       └── business_validator.dart
│
├── 🎨 presentation/                      # CAPA DE PRESENTACIÓN
│   │
│   ├── 🧩 providers/                     # State Management
│   │   ├── global/                       # Globales
│   │   │   ├── app_provider.dart
│   │   │   ├── auth_provider.dart
│   │   │   ├── business_provider.dart
│   │   │   ├── theme_provider.dart
│   │   │   └── connectivity_provider.dart
│   │   │
│   │   └── features/                     # Por Feature
│   │       ├── product_provider.dart
│   │       ├── pos_provider.dart
│   │       ├── inventory_provider.dart
│   │       └── sale_provider.dart
│   │
│   ├── 🎭 features/                      # MÓDULOS DE NEGOCIO
│   │   │
│   │   ├── 🏠 dashboard/                 # Dashboard Base
│   │   │   ├── domain/
│   │   │   │   └── models/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── dashboard_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── dashboard_page.dart
│   │   │       └── widgets/
│   │   │           ├── metric_card.dart
│   │   │           ├── sales_chart.dart
│   │   │           └── quick_actions.dart
│   │   │
│   │   ├── 🏪 dashboards_by_category/    # Dashboards por Categoría
│   │   │   ├── abarrotes/
│   │   │   │   └── abarrotes_dashboard_page.dart
│   │   │   ├── ropa_calzado/
│   │   │   │   └── ropa_calzado_dashboard_page.dart
│   │   │   ├── hogar_decoracion/
│   │   │   │   └── hogar_decoracion_dashboard_page.dart
│   │   │   ├── electronica/
│   │   │   │   └── electronica_dashboard_page.dart
│   │   │   ├── verduleria/
│   │   │   │   └── verduleria_dashboard_page.dart
│   │   │   ├── papa_mayorista/
│   │   │   │   └── papa_mayorista_dashboard_page.dart
│   │   │   ├── carniceria/
│   │   │   │   └── carniceria_dashboard_page.dart
│   │   │   ├── ferreteria/
│   │   │   │   └── ferreteria_dashboard_page.dart
│   │   │   ├── farmacia/
│   │   │   │   └── farmacia_dashboard_page.dart
│   │   │   ├── restaurante/
│   │   │   │   └── restaurante_dashboard_page.dart
│   │   │   ├── mayorista/
│   │   │   │   └── mayorista_dashboard_page.dart
│   │   │   └── otro/
│   │   │       └── otro_dashboard_page.dart
│   │   │
│   │   ├── 💰 pos/                         # POS Base (Adaptable)
│   │   │   ├── domain/
│   │   │   │   └── models/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── pos_provider.dart
│   │   │       ├── pages/
│   │   │       │   └── pos_page.dart
│   │   │       └── widgets/
│   │   │           ├── product_card.dart
│   │   │           ├── cart_item.dart
│   │   │           ├── cart_summary.dart
│   │   │           └── payment_dialog.dart
│   │   │
│   │   ├── 🎯 pos_by_category/              # POS por Categoría
│   │   │   ├── abarrotes/
│   │   │   │   ├── qr_scanner_pos.dart      # Scanner QR
│   │   │   │   └── expiry_pos_widget.dart   # Control vencimientos
│   │   │   ├── verduleria/
│   │   │   │   └── weight_pos_widget.dart   # Venta por peso
│   │   │   ├── carniceria/
│   │   │   │   └── cuts_pos_widget.dart     # Tipos de cortes
│   │   │   ├── restaurante/
│   │   │   │   ├── table_pos_widget.dart    # Gestión de mesas
│   │   │   │   └── kitchen_pos_widget.dart  # Comandas cocina
│   │   │   └── farmacia/
│   │   │       └── prescription_pos_widget.dart # Recetas
│   │   │
│   │   ├── 📦 inventory/                    # Inventory Base
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── inventory_item.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── inventory_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_inventory_usecase.dart
│   │   │   │       ├── adjust_stock_usecase.dart
│   │   │   │       └── search_products_usecase.dart
│   │   │   │
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── inventory_model.dart
│   │   │   │   │   └── product_model.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── inventory_remote_datasource.dart
│   │   │   │   │   └── inventory_local_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── inventory_repository_impl.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── inventory_provider.dart
│   │   │       ├── pages/
│   │   │       │   ├── inventory_page.dart
│   │   │       │   ├── add_product_page.dart
│   │   │       │   ├── edit_product_page.dart
│   │   │       │   ├── stock_movements_page.dart
│   │   │       │   └── product_detail_page.dart
│   │   │       └── widgets/
│   │   │           ├── product_list_item.dart
│   │   │           ├── stock_alert_badge.dart
│   │   │           ├── qr_code_dialog.dart
│   │   │           ├── qr_scanner_widget.dart
│   │   │           └── category_selector.dart
│   │   │
│   │   ├── 🏷️ inventory_by_category/         # Inventory por Categoría
│   │   │   ├── abarrotes/
│   │   │   │   ├── expiry_alert_widget.dart   # Alertas vencimiento
│   │   │   │   └── barcode_generator.dart     # Generador QR/Barcode
│   │   │   ├── ropa_calzado/
│   │   │   │   ├── sizes_inventory_widget.dart # Control de tallas
│   │   │   │   └── variants_inventory.dart     # Variantes/colores
│   │   │   ├── electronica/
│   │   │   │   └── serial_inventory_widget.dart # Números serie
│   │   │   ├── verduleria/
│   │   │   │   ├── freshness_tracker.dart     # Control frescura
│   │   │   │   └── waste_tracker.dart         # Mermas
│   │   │   ├── farmacia/
│   │   │   │   ├── prescription_tracker.dart  # Recetas
│   │   │   │   └── controlled_meds_widget.dart # Medicamentos controlados
│   │   │   └── carniceria/
│   │   │       └── temp_control_widget.dart   # Control temperatura
│   │   │
│   │   ├── 📊 sales/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── sale.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── sale_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── create_sale_usecase.dart
│   │   │   │       ├── get_sales_usecase.dart
│   │   │   │       └── void_sale_usecase.dart
│   │   │   │
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── sale_model.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── sale_remote_datasource.dart
│   │   │   │   │   └── sale_local_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── sale_repository_impl.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── sale_provider.dart
│   │   │       ├── pages/
│   │   │       │   ├── sales_history_page.dart
│   │   │       │   └── sale_detail_page.dart
│   │   │       └── widgets/
│   │   │           └── sale_card.dart
│   │   │
│   │   ├── 👥 clients/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── client_provider.dart
│   │   │       ├── pages/
│   │   │       │   ├── clients_page.dart
│   │   │       │   ├── add_client_page.dart
│   │   │       │   └── client_detail_page.dart
│   │   │       └── widgets/
│   │   │           └── client_card.dart
│   │   │
│   │   ├── 💳 credits/                    # [Similar structure]
│   │   ├── 🛒 purchases/                  # [Similar structure]
│   │   ├── 📈 reports/                    # [Similar structure]
│   │   ├── ⭐ score/                      # [Similar structure]
│   │   ├── 🔔 notifications/              # [Similar structure]
│   │   ├── ⚙️ settings/                   # [Similar structure]
│   │   ├── 🔒 security/                   # Seguridad y Alertas
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── security_event.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── security_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_security_alerts_usecase.dart
│   │   │   │       ├── log_security_event_usecase.dart
│   │   │   │       ├── get_login_attempts_usecase.dart
│   │   │   │       └── block_suspicious_activity_usecase.dart
│   │   │   │
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── security_event_model.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── security_remote_datasource.dart
│   │   │   │   │   └── security_local_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── security_repository_impl.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── security_provider.dart
│   │   │       ├── pages/
│   │   │       │   ├── security_dashboard_page.dart
│   │   │       │   ├── security_alerts_page.dart
│   │   │       │   ├── login_attempts_page.dart
│   │   │       │   ├── ip_whitelist_page.dart
│   │   │       │   └── audit_logs_page.dart
│   │   │       └── widgets/
│   │   │           ├── threat_alert_card.dart
│   │   │           ├── login_map_widget.dart
│   │   │           ├── suspicious_activity_badge.dart
│   │   │           └── security_metrics_chart.dart
│   │   │
│   │   └── ❓ help/                       # [Similar structure]
│   │
│   └── 🎨 shared/                        # Componentes Compartidos
│       ├── widgets/
│       │   ├── buttons/
│       │   │   ├── primary_button.dart
│       │   │   ├── secondary_button.dart
│       │   │   ├── outline_button.dart
│       │   │   └── icon_button.dart
│       │   │
│       │   ├── inputs/
│       │   │   ├── custom_textfield.dart
│       │   │   ├── custom_dropdown.dart
│       │   │   ├── date_picker.dart
│       │   │   ├── time_picker.dart
│       │   │   └── search_bar.dart
│       │   │
│       │   ├── cards/
│       │   │   ├── info_card.dart
│       │   │   ├── metric_card.dart
│       │   │   ├── product_card.dart
│       │   │   └── action_card.dart
│       │   │
│       │   ├── dialogs/
│       │   │   ├── confirmation_dialog.dart
│       │   │   ├── loading_dialog.dart
│       │   │   ├── error_dialog.dart
│       │   │   └── success_dialog.dart
│       │   │
│       │   ├── layouts/
│       │   │   ├── main_layout.dart
│       │   │   ├── page_layout.dart
│       │   │   ├── responsive_layout.dart
│       │   │   └── scrollable_layout.dart
│       │   │
│       │   ├── loaders/
│       │   │   ├── skeleton_loader.dart
│       │   │   ├── shimmer_loader.dart
│       │   │   └── circular_loader.dart
│       │   │
│       │   ├── empty_states/
│       │   │   ├── empty_list_state.dart
│       │   │   └── empty_search_state.dart
│       │   │
│       │   └── error_widgets/
│       │       ├── error_message.dart
│       │       └── retry_widget.dart
│       │
│       └── constants/
│           ├── app_dimensions.dart
│           └── app_icons.dart
│
├── 🔧 generated/                         # Archivos Generados
│   ├── routes.dart                       # go_router_builder
│   └── di_injector.dart                  # Injectable
│
├── 📱 platform/                          # Platform-Specific
│   ├── android/
│   │   └── android_service.dart
│   ├── ios/
│   │   └── ios_service.dart
│   └── web/
│       └── web_service.dart
│
└── 🧪 test/                              # Tests
    ├── unit/                             # Unit tests
    ├── widget/                           # Widget tests
    ├── integration/                      # Integration tests
    ├── fixtures/                         # Test data
    └── mocks/                            # Mocks
```

---

## 🎯 PATRONES EMPRESARIALES APLICADOS

### 1. **CLEAN ARCHITECTURE** ✅
**Separación en 3 capas independientes**

```dart
// PRESENTATION → DOMAIN → DATA

// Domain NO conoce Presentation ni Data
// Presentation NO conoce Data
// Data implementa Domain

// Dependencias SOLO hacia adentro
```

---

### 2. **Dependency Injection (DI)** ✅
**Inversión de dependencias con GetIt**

```dart
// Setup DI
class DependencyInjection {
  static final GetIt getIt = GetIt.instance;

  static Future<void> init() async {
    // External
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerLazySingleton(() => sharedPreferences);

    // Core
    getIt.registerLazySingleton(() => NetworkInfo());
    getIt.registerLazySingleton(() => Logger());

    // Data Sources
    getIt.registerLazySingleton<PostgreSQLConnection>(
      () => PostgreSQLConnection(),
    );
    getIt.registerLazySingleton<RedisConnection>(
      () => RedisConnection(),
    );
    getIt.registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(postgres: getIt(), redis: getIt()),
    );
    getIt.registerLazySingleton<ProductLocalDataSource>(
      () => ProductLocalDataSourceImpl(db: getIt()),
    );

    // Repositories
    getIt.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(
        remote: getIt(),
        local: getIt(),
        network: getIt(),
      ),
    );

    // Use Cases
    getIt.registerLazySingleton(() => GetProductsUseCase(getIt()));
    getIt.registerLazySingleton(() => AddProductUseCase(getIt()));
    getIt.registerLazySingleton(() => UpdateProductUseCase(getIt()));

    // Providers
    getIt.registerLazySingleton(() => ProductProvider(
      getProducts: getIt(),
      addProduct: getIt(),
      updateProduct: getIt(),
    ));
  }
}
```

---

### 3. **Repository Pattern** ✅
**Abstracción de fuentes de datos**

```dart
// Domain Layer - Interface
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts(String businessId);
  Future<Either<Failure, Product>> addProduct(Product product);
  Future<Either<Failure, void>> updateProduct(Product product);
  Future<Either<Failure, void>> deleteProduct(String productId);
  
  // Offline support
  Future<Either<Failure, List<Product>>> getProductsOffline(String businessId);
  Future<Either<Failure, void>> syncPendingChanges();
}

// Data Layer - Implementation
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remote;
  final ProductLocalDataSource local;
  final NetworkInfo networkInfo;
  final AppDatabase database;

  ProductRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
    required this.database,
  });

  @override
  Future<Either<Failure, List<Product>>> getProducts(String businessId) async {
    try {
      // Strategy: Online-first with offline fallback
      if (await networkInfo.isConnected) {
        // Fetch from remote
        final products = await remote.getProducts(businessId);
        
        // Cache locally
        await local.saveProducts(products);
        
        // Convert Models to Entities
        return Right(products.map((m) => m.toEntity()).toList());
      } else {
        // Offline: fetch from local cache
        final localProducts = await local.getProducts(businessId);
        return Right(localProducts.map((m) => m.toEntity()).toList());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> addProduct(Product product) async {
    try {
      // Always save locally first (offline-first)
      final productModel = ProductModel.fromEntity(product);
      await local.saveProduct(productModel);

      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          final result = await remote.addProduct(productModel);
          await local.updateProduct(result);
          return Right(result.toEntity());
        } catch (e) {
          // Mark as pending sync
          await database.markProductAsPending(product.id);
          return Right(product); // Success local
        }
      } else {
        // Mark as pending sync
        await database.markProductAsPending(product.id);
        return Right(product);
      }
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
```

---

### 4. **Use Cases Pattern** ✅
**Encapsulan lógica de negocio**

```dart
// Base Use Case
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Implementation
class GetProductsUseCase implements UseCase<List<Product>, String> {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(String businessId) async {
    // Business logic validation
    if (businessId.isEmpty) {
      return const Left(ValidationFailure('Business ID required'));
    }

    if (businessId.length < 10) {
      return const Left(ValidationFailure('Invalid Business ID'));
    }

    // Call repository
    return await repository.getProducts(businessId);
  }
}

class AddProductUseCase implements UseCase<Product, AddProductParams> {
  final ProductRepository repository;
  final ProductValidator validator;

  AddProductUseCase(this.repository, this.validator);

  @override
  Future<Either<Failure, Product>> call(AddProductParams params) async {
    // Validate business rules
    final validation = validator.validate(params.product);
    if (!validation.isValid) {
      return Left(ValidationFailure(validation.errorMessage));
    }

    // Check duplicates
    final existing = await repository.getProducts(params.businessId);
    final hasDuplicate = existing.fold(
      (_) => false,
      (products) => products.any((p) => p.code == params.product.code),
    );

    if (hasDuplicate) {
      return const Left(ValidationFailure('Product code already exists'));
    }

    // Add product
    return await repository.addProduct(params.product);
  }
}

// Parameters class
class AddProductParams {
  final Product product;
  final String businessId;

  AddProductParams({required this.product, required this.businessId});
}
```

---

### 5. **Error Handling Empresarial** ✅
**Either + Failures Pattern**

```dart
// Failures
abstract class Failure implements Exception {
  final String message;
  final String? code;
  final String? details;

  const Failure(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

// Specific Failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.details});
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection');
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.details});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code, super.details});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(String resource) : super('$resource not found');
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code, super.details});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.code, super.details});
}

// Error Handler
class ErrorHandler {
  static String getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'Sin conexión a internet. Verificando datos offline...';
      case ServerFailure:
        return 'Error del servidor. Intente nuevamente.';
      case ValidationFailure:
        return failure.message;
      case NotFoundFailure:
        return failure.message;
      case PermissionFailure:
        return 'No tienes permisos para esta acción.';
      case CacheFailure:
        return 'Error al guardar localmente.';
      case UnexpectedFailure:
        return 'Ocurrió un error inesperado.';
      default:
        return 'Error desconocido';
    }
  }

  static void handleError(Failure failure, BuildContext context) {
    final message = getErrorMessage(failure);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}

// Global Error Boundary
class ErrorBoundary extends StatelessWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ErrorWidget.builder = (FlutterErrorDetails details) {
      // Log to analytics
      Analytics.logError(details.exceptionAsString());

      // Show user-friendly error
      return ErrorView(
        message: 'Algo salió mal',
        onRetry: () => context.go('/dashboard'),
      );
    };
  }
}
```

---

### 6. **Provider Pattern Empresarial** ✅
**State Management estructurado**

```dart
// Base Provider
abstract class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  Failure? _error;

  bool get isLoading => _isLoading;
  Failure? get error => _error;
  bool get hasError => _error != null;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(Failure? failure) {
    _error = failure;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Product Provider
class ProductProvider extends BaseProvider {
  final GetProductsUseCase getProducts;
  final AddProductUseCase addProduct;
  final UpdateProductUseCase updateProduct;
  final DeleteProductUseCase deleteProduct;

  List<Product> _products = [];
  Product? _selectedProduct;

  ProductProvider({
    required this.getProducts,
    required this.addProduct,
    required this.updateProduct,
    required this.deleteProduct,
  });

  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;

  Future<void> loadProducts(String businessId) async {
    setLoading(true);
    clearError();

    final result = await getProducts(businessId);

    result.fold(
      (failure) => setError(failure),
      (products) {
        _products = products;
        notifyListeners();
      },
    );

    setLoading(false);
  }

  Future<void> addNewProduct(Product product, String businessId) async {
    setLoading(true);

    final result = await addProduct(AddProductParams(
      product: product,
      businessId: businessId,
    ));

    result.fold(
      (failure) {
        setError(failure);
        setLoading(false);
      },
      (addedProduct) async {
        // Refresh list
        await loadProducts(businessId);
        setLoading(false);
      },
    );
  }

  Future<void> updateExistingProduct(Product product) async {
    setLoading(true);

    final result = await updateProduct(UpdateProductParams(product: product));

    result.fold(
      (failure) {
        setError(failure);
        setLoading(false);
      },
      (_) async {
        // Refresh list
        final index = _products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _products[index] = product;
          notifyListeners();
        }
        setLoading(false);
      },
    );
  }

  void selectProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  void filterProducts(String query) {
    // Implement filtering
    notifyListeners();
  }
}
```

---

## 🔄 FLUJO DE DATOS COMPLETO

```
┌─────────────────────────────────────────────────────────────┐
│  USER ACTION: "Agregar Producto"                            │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  UI (AddProductPage)                                        │
│  - User llena formulario                                    │
│  - Presiona "Guardar"                                       │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  Provider (ProductProvider)                                 │
│  - ProductProvider.addNewProduct(product, businessId)       │
│  - setLoading(true)                                         │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  Use Case (AddProductUseCase)                               │
│  1. Validar datos                                           │
│  2. Check business rules                                    │
│  3. Preparar entity                                         │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  Repository Interface (ProductRepository)                   │
│  - addProduct(Product entity)                               │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  Repository Implementation (ProductRepositoryImpl)          │
│  1. Network check                                           │
│  2. Save to local (SQLite) FIRST                           │
│  3. Mark as pending if offline                              │
│  4. Try upload to remote if online                          │
└─────────────────────────────────────────────────────────────┘
                           ↓
        ┌──────────────────┴──────────────────┐
        ↓                                     ↓
┌──────────────────────┐           ┌──────────────────────┐
│  Local (SQLite)      │           │  Remote (PostgreSQL) │
│  - product_cache     │           │  - products table    │
│  - pending_sync      │           │  - primary + replicas│
└──────────────────────┘           └──────────────────────┘
        ↓                                     ↓
┌─────────────────────────────────────────────────────────────┐
│  Cache Layer (Redis)                                        │
│  - Session cache                                            │
│  - Query results cache                                      │
└─────────────────────────────────────────────────────────────┘
        ↓                                     ↓
┌─────────────────────────────────────────────────────────────┐
│  Sync Manager (Background)                                  │
│  - Periodic sync                                            │
│  - Conflict resolution                                      │
│  - Error retry                                              │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  Provider Response                                          │
│  - Either<Failure, Product>                                 │
│  - Success: refresh list, show success                      │
│  - Error: show error message                                │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  UI Update                                                  │
│  - Loading indicator off                                    │
│  - Show success/error                                       │
│  - Refresh product list                                     │
└─────────────────────────────────────────────────────────────┘
```

---

## 🗺️ RUTAS Y NAVEGACIÓN POR CATEGORÍA

Cada categoría de negocio tiene paneles y rutas adaptadas a sus necesidades específicas.

### 📋 **RUTAS COMUNES** (Disponibles en TODAS las categorías)

```dart
// app/routes/route_names.dart
class RouteNames {
  // Auth
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  
  // Onboarding
  static const onboarding = '/onboarding';
  static const selectCategory = '/onboarding/category';
  static const businessData = '/onboarding/business';
  
  // Main App (Disponible después del onboarding)
  static const home = '/home';
  static const dashboard = '/dashboard';
  
  // Módulos Comunes
  static const clients = '/clients';
  static const addClient = '/clients/add';
  static const clientDetail = '/clients/:id';
  
  static const settings = '/settings';
  static const profile = '/settings/profile';
  static const notifications = '/notifications';
  static const help = '/help';
  
  // Security (Seguridad y Alertas)
  static const security = '/security';
  static const securityAlerts = '/security/alerts';
  static const loginAttempts = '/security/login-attempts';
  static const ipWhitelist = '/security/ip-whitelist';
  static const auditLogs = '/security/audit-logs';
  
  // Reports (Común)
  static const reports = '/reports';
  static const salesReport = '/reports/sales';
  static const inventoryReport = '/reports/inventory';
  
  // Navegación dinámica por categoría
  static String getCategoryHome(String category) => '/home/$category';
  static String getPOS(String category) => '/pos/$category';
  static String getInventory(String category) => '/inventory/$category';
}
```

---

### 🏪 **RUTAS POR CATEGORÍA DE NEGOCIO**

#### 🛒 **1. ABARROTES / BODEGA** (`abarrotes`)

```dart
// app/routes/category_routes/abarrotes_routes.dart
final abarrotesRoutes = GoRoute(
  path: '/abarrotes',
  builder: (context, state) => const MainLayout(
    category: 'abarrotes',
    child: AbarrotesDashboard(),
  ),
  routes: [
    // Dashboard
    GoRoute(
      path: '/dashboard',
      name: 'abarrotes_dashboard',
      builder: (context, state) => const AbarrotesDashboardPage(),
    ),
    
    // POS
    GoRoute(
      path: '/pos',
      name: 'abarrotes_pos',
      builder: (context, state) => const POSPage(category: 'abarrotes'),
    ),
    
    // Inventario
    GoRoute(
      path: '/inventory',
      name: 'abarrotes_inventory',
      builder: (context, state) => const InventoryPage(category: 'abarrotes'),
      routes: [
        GoRoute(
          path: '/add',
          name: 'add_product',
          builder: (context, state) => const AddProductPage(category: 'abarrotes'),
        ),
        GoRoute(
          path: '/edit/:id',
          name: 'edit_product',
          builder: (context, state) => AddProductPage(
            category: 'abarrotes',
            productId: state.pathParameters['id'],
          ),
        ),
        GoRoute(
          path: '/detail/:id',
          name: 'product_detail',
          builder: (context, state) => ProductDetailPage(
            category: 'abarrotes',
            productId: state.pathParameters['id'],
          ),
        ),
        GoRoute(
          path: '/qr-scanner',
          name: 'qr_scanner',
          builder: (context, state) => const QRScannerPage(),
        ),
        GoRoute(
          path: '/expiry-alerts',
          name: 'expiry_alerts',
          builder: (context, state) => const ExpiryAlertsPage(),
        ),
      ],
    ),
    
    // Ventas
    GoRoute(
      path: '/sales',
      name: 'abarrotes_sales',
      builder: (context, state) => const SalesPage(category: 'abarrotes'),
      routes: [
        GoRoute(
          path: '/history',
          name: 'sales_history',
          builder: (context, state) => const SalesHistoryPage(),
        ),
        GoRoute(
          path: '/detail/:id',
          name: 'sale_detail',
          builder: (context, state) => SaleDetailPage(
            saleId: state.pathParameters['id'],
          ),
        ),
      ],
    ),
    
    // Créditos y Fiados
    GoRoute(
      path: '/credits',
      name: 'abarrotes_credits',
      builder: (context, state) => const CreditsPage(category: 'abarrotes'),
      routes: [
        GoRoute(
          path: '/new',
          name: 'new_credit',
          builder: (context, state) => const NewCreditPage(),
        ),
        GoRoute(
          path: '/payments',
          name: 'credit_payments',
          builder: (context, state) => const CreditPaymentsPage(),
        ),
        GoRoute(
          path: '/overdue',
          name: 'overdue_credits',
          builder: (context, state) => const OverdueCreditsPage(),
        ),
      ],
    ),
    
    // Compras
    GoRoute(
      path: '/purchases',
      name: 'abarrotes_purchases',
      builder: (context, state) => const PurchasesPage(category: 'abarrotes'),
    ),
    
    // Proveedores
    GoRoute(
      path: '/providers',
      name: 'abarrotes_providers',
      builder: (context, state) => const ProvidersPage(),
    ),
    
    // Mi Score / Evaluación
    GoRoute(
      path: '/score',
      name: 'abarrotes_score',
      builder: (context, state) => const ScorePage(category: 'abarrotes'),
    ),
    
    // Clientes
    GoRoute(
      path: '/clients',
      name: 'abarrotes_clients',
      builder: (context, state) => const ClientsPage(category: 'abarrotes'),
    ),
    
    // Caja
    GoRoute(
      path: '/cash',
      name: 'abarrotes_cash',
      builder: (context, state) => const CashRegisterPage(category: 'abarrotes'),
      routes: [
        GoRoute(
          path: '/open',
          name: 'open_cash',
          builder: (context, state) => const OpenCashRegisterPage(),
        ),
        GoRoute(
          path: '/close',
          name: 'close_cash',
          builder: (context, state) => const CloseCashRegisterPage(),
        ),
        GoRoute(
          path: '/movements',
          name: 'cash_movements',
          builder: (context, state) => const CashMovementsPage(),
        ),
      ],
    ),
  ],
);
```

---

#### 👗 **2. ROPA, CALZADO Y ACCESORIOS** (`ropa_calzado`)

```dart
// app/routes/category_routes/ropa_calzado_routes.dart
final ropaCalzadoRoutes = GoRoute(
  path: '/ropa-calzado',
  builder: (context, state) => const MainLayout(
    category: 'ropa_calzado',
    child: RopaCalzadoDashboard(),
  ),
  routes: [
    // Dashboard específico
    GoRoute(
      path: '/dashboard',
      name: 'ropa_calzado_dashboard',
      builder: (context, state) => const RopaCalzadoDashboardPage(),
    ),
    
    // POS
    GoRoute(
      path: '/pos',
      name: 'ropa_calzado_pos',
      builder: (context, state) => const POSPage(category: 'ropa_calzado'),
    ),
    
    // Catálogo de productos
    GoRoute(
      path: '/catalog',
      name: 'ropa_calzado_catalog',
      builder: (context, state) => const ProductCatalogPage(category: 'ropa_calzado'),
      routes: [
        GoRoute(
          path: '/collections',
          name: 'collections',
          builder: (context, state) => const CollectionsPage(),
        ),
        GoRoute(
          path: '/variants/:id',
          name: 'product_variants',
          builder: (context, state) => ProductVariantsPage(
            productId: state.pathParameters['id'],
          ),
        ),
        GoRoute(
          path: '/tallas',
          name: 'manage_tallas',
          builder: (context, state) => const TallasManagementPage(),
        ),
      ],
    ),
    
    // Inventario
    GoRoute(
      path: '/inventory',
      name: 'ropa_calzado_inventory',
      builder: (context, state) => const InventoryPage(category: 'ropa_calzado'),
    ),
    
    // Ventas
    GoRoute(
      path: '/sales',
      name: 'ropa_calzado_sales',
      builder: (context, state) => const SalesPage(category: 'ropa_calzado'),
    ),
    
    // Marketplace (Opcional)
    GoRoute(
      path: '/marketplace',
      name: 'marketplace',
      builder: (context, state) => const MarketplacePage(),
    ),
  ],
);
```

---

#### 🏠 **3. HOGAR Y DECORACIÓN** (`hogar_decoracion`)

```dart
// app/routes/category_routes/hogar_decoracion_routes.dart
final hogarDecoracionRoutes = GoRoute(
  path: '/hogar-decoracion',
  builder: (context, state) => const MainLayout(
    category: 'hogar_decoracion',
    child: HogarDecoracionDashboard(),
  ),
  routes: [
    GoRoute(
      path: '/dashboard',
      name: 'hogar_decoracion_dashboard',
      builder: (context, state) => const HogarDecoracionDashboardPage(),
    ),
    GoRoute(
      path: '/catalogs',
      name: 'decor_catalogs',
      builder: (context, state) => const DecorCatalogsPage(),
    ),
    GoRoute(
      path: '/rooms',
      name: 'room_categories',
      builder: (context, state) => const RoomCategoriesPage(),
    ),
    GoRoute(
      path: '/showroom',
      name: 'virtual_showroom',
      builder: (context, state) => const VirtualShowroomPage(),
    ),
  ],
);
```

---

#### 📱 **4. ELECTRÓNICA Y TECNOLOGÍA** (`electronica`)

```dart
// app/routes/category_routes/electronica_routes.dart
final electronicaRoutes = GoRoute(
  path: '/electronica',
  builder: (context, state) => const MainLayout(
    category: 'electronica',
    child: ElectronicaDashboard(),
  ),
  routes: [
    GoRoute(
      path: '/dashboard',
      name: 'electronica_dashboard',
      builder: (context, state) => const ElectronicaDashboardPage(),
    ),
    GoRoute(
      path: '/serials',
      name: 'manage_serials',
      builder: (context, state) => const SerialManagementPage(),
    ),
    GoRoute(
      path: '/warranties',
      name: 'warranties',
      builder: (context, state) => const WarrantiesPage(),
    ),
    GoRoute(
      path: '/trade-in',
      name: 'trade_in',
      builder: (context, state) => const TradeInPage(),
    ),
    GoRoute(
      path: '/technical-support',
      name: 'tech_support',
      builder: (context, state) => const TechnicalSupportPage(),
    ),
  ],
);
```

---

#### 🥦 **5. VERDULERÍA / FRUTAS** (`verduleria`)

```dart
// app/routes/category_routes/verduleria_routes.dart
final verduleriaRoutes = GoRoute(
  path: '/verduleria',
  builder: (context, state) => const MainLayout(
    category: 'verduleria',
    child: VerduleriaDashboard(),
  ),
  routes: [
    GoRoute(
      path: '/dashboard',
      name: 'verduleria_dashboard',
      builder: (context, state) => const VerduleriaDashboardPage(),
    ),
    GoRoute(
      path: '/weight-sales',
      name: 'weight_sales',
      builder: (context, state) => const WeightSalesPage(),
    ),
    GoRoute(
      path: '/freshness-control',
      name: 'freshness',
      builder: (context, state) => const FreshnessControlPage(),
    ),
    GoRoute(
      path: '/waste',
      name: 'waste_tracking',
      builder: (context, state) => const WasteTrackingPage(),
    ),
  ],
);
```

---

#### 🥔 **6. VENTA DE PAPA / TUBÉRCULOS** (`papa_mayorista`)

```dart
// app/routes/category_routes/papa_mayorista_routes.dart
final papaMayoristaRoutes = GoRoute(
  path: '/papa-mayorista',
  builder: (context, state) => const MainLayout(
    category: 'papa_mayorista',
    child: PapaMayoristaDashboard(),
  ),
  routes: [
    GoRoute(
      path: '/dashboard',
      name: 'papa_mayorista_dashboard',
      builder: (context, state) => const PapaMayoristaDashboardPage(),
    ),
    GoRoute(
      path: '/bulk-sales',
      name: 'bulk_sales',
      builder: (context, state) => const BulkSalesPage(),
    ),
    GoRoute(
      path: '/accounts-receivable',
      name: 'accounts_receivable',
      builder: (context, state) => const AccountsReceivablePage(),
    ),
    GoRoute(
      path: '/suppliers',
      name: 'potato_suppliers',
      builder: (context, state) => const PotatoSuppliersPage(),
    ),
    GoRoute(
      path: '/harvest-seasons',
      name: 'harvest_seasons',
      builder: (context, state) => const HarvestSeasonsPage(),
    ),
  ],
);
```

---

#### 🍖 **7. CARNICERÍA / POLLERÍA** (`carniceria`)

```dart
// app/routes/category_routes/carniceria_routes.dart
final carniceriaRoutes = GoRoute(
  path: '/carniceria',
  builder: (context, state) => const MainLayout(
    category: 'carniceria',
    child: CarniceriaDashboard(),
  ),
  routes: [
    GoRoute(
      path: '/dashboard',
      name: 'carniceria_dashboard',
      builder: (context, state) => const CarniceriaDashboardPage(),
    ),
    GoRoute(
      path: '/cuts',
      name: 'meat_cuts',
      builder: (context, state) => const MeatCutsPage(),
    ),
    GoRoute(
      path: '/temperature-control',
      name: 'temp_control',
      builder: (context, state) => const TemperatureControlPage(),
    ),
    GoRoute(
      path: '/suppliers',
      name: 'slaughterhouses',
      builder: (context, state) => const SlaughterhousesPage(),
    ),
    GoRoute(
      path: '/processing',
      name: 'processing_dates',
      builder: (context, state) => const ProcessingDatesPage(),
    ),
  ],
);
```

---

#### 🔧 **8. FERRETERÍA / CONSTRUCCIÓN** (`ferreteria`)

```dart
// app/routes/category_routes/ferreteria_routes.dart
final ferreteriaRoutes = GoRoute(
  path: '/ferreteria',
  builder: (context, state) => const MainLayout(
    category: 'ferreteria',
    child: FerreteriaDashboard(),
  ),
  routes: [
    GoRoute(
      path: '/dashboard',
      name: 'ferreteria_dashboard',
      builder: (context, state) => const FerreteriaDashboardPage(),
    ),
    GoRoute(
      path: '/catalog',
      name: 'tools_catalog',
      builder: (context, state) => const ToolsCatalogPage(),
    ),
    GoRoute(
      path: '/projects',
      name: 'construction_projects',
      builder: (context, state) => const ConstructionProjectsPage(),
    ),
    GoRoute(
      path: '/specifications',
      name: 'technical_specs',
      builder: (context, state) => const TechnicalSpecsPage(),
    ),
  ],
);
```

---

#### 💊 **9. FARMACIA / BOTICA** (`farmacia`)

```dart
// app/routes/category_routes/farmacia_routes.dart
final farmaciaRoutes = GoRoute(
  path: '/farmacia',
  builder: (context, state) => const MainLayout(
    category: 'farmacia',
    child: FarmaciaDashboard(),
  ),
  routes: [
    GoRoute(
      path: '/dashboard',
      name: 'farmacia_dashboard',
      builder: (context, state) => const FarmaciaDashboardPage(),
    ),
    GoRoute(
      path: '/prescriptions',
      name: 'prescriptions',
      builder: (context, state) => const PrescriptionsPage(),
    ),
    GoRoute(
      path: '/expiry-control',
      name: 'medicine_expiry',
      builder: (context, state) => const MedicineExpiryControlPage(),
    ),
    GoRoute(
      path: '/controlled-meds',
      name: 'controlled_meds',
      builder: (context, state) => const ControlledMedicationsPage(),
    ),
    GoRoute(
      path: '/licensed-suppliers',
      name: 'licensed_suppliers',
      builder: (context, state) => const LicensedSuppliersPage(),
    ),
  ],
);
```

---

#### 🍕 **10. RESTAURANTE / COMIDA** (`restaurante`)

```dart
// app/routes/category_routes/restaurante_routes.dart
final restauranteRoutes = GoRoute(
  path: '/restaurante',
  builder: (context, state) => const MainLayout(
    category: 'restaurante',
    child: RestauranteDashboard(),
  ),
  routes: [
    GoRoute(
      path: '/dashboard',
      name: 'restaurante_dashboard',
      builder: (context, state) => const RestauranteDashboardPage(),
    ),
    GoRoute(
      path: '/tables',
      name: 'table_management',
      builder: (context, state) => const TableManagementPage(),
    ),
    GoRoute(
      path: '/orders',
      name: 'kitchen_orders',
      builder: (context, state) => const KitchenOrdersPage(),
    ),
    GoRoute(
      path: '/delivery',
      name: 'delivery_orders',
      builder: (context, state) => const DeliveryOrdersPage(),
    ),
    GoRoute(
      path: '/online-orders',
      name: 'online_orders',
      builder: (context, state) => const OnlineOrdersPage(),
    ),
  ],
);
```

---

#### 📦 **11. MAYORISTA / DISTRIBUIDOR** (`mayorista`)

```dart
// app/routes/category_routes/mayorista_routes.dart
final mayoristaRoutes = GoRoute(
  path: '/mayorista',
  builder: (context, state) => const MainLayout(
    category: 'mayorista',
    child: MayoristaDashboard(),
  ),
  routes: [
    GoRoute(
      path: '/dashboard',
      name: 'mayorista_dashboard',
      builder: (context, state) => const MayoristaDashboardPage(),
    ),
    GoRoute(
      path: '/b2b-sales',
      name: 'b2b_sales',
      builder: (context, state) => const B2BSalesPage(),
    ),
    GoRoute(
      path: '/large-orders',
      name: 'large_orders',
      builder: (context, state) => const LargeOrdersPage(),
    ),
    GoRoute(
      path: '/logistics',
      name: 'logistics_routes',
      builder: (context, state) => const LogisticsRoutesPage(),
    ),
    GoRoute(
      path: '/enterprise-clients',
      name: 'enterprise_clients',
      builder: (context, state) => const EnterpriseClientsPage(),
    ),
  ],
);
```

---

#### 🏪 **12. OTRO / GENERAL** (`otro`)

```dart
// app/routes/category_routes/otro_routes.dart
final otroRoutes = GoRoute(
  path: '/otro',
  builder: (context, state) => const MainLayout(
    category: 'otro',
    child: GeneralDashboard(),
  ),
  routes: [
    GoRoute(
      path: '/dashboard',
      name: 'general_dashboard',
      builder: (context, state) => const GeneralDashboardPage(),
    ),
    GoRoute(
      path: '/custom-config',
      name: 'custom_config',
      builder: (context, state) => const CustomConfigPage(),
    ),
  ],
);
```

---

### 🎯 **ROUTER PRINCIPAL** (Configuración con GoRouter)

```dart
// app/routes/app_router.dart
import 'package:go_router/go_router.dart';
import 'app/routes/category_routes/abarrotes_routes.dart';
import 'app/routes/category_routes/ropa_calzado_routes.dart';
// ... importar todas las categorías

class AppRouter {
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: _redirectLogic,
    refreshListenable: GoRouterRefreshStream(authStateChanges),
    routes: [
      // Auth Routes
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      
      // Onboarding Routes
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
        routes: [
          GoRoute(
            path: '/category',
            name: 'select_category',
            builder: (context, state) => const BusinessCategoryStep(),
          ),
          GoRoute(
            path: '/business',
            name: 'business_data',
            builder: (context, state) => const BusinessDataStep(),
          ),
        ],
      ),
      
      // Main App Routes - Por categoría
      GoRoute(
        path: '/home',
        redirect: (context, state) {
          final category = context.read<AppProvider>().currentBusinessCategory;
          return '/home/$category';
        },
      ),
      
      // RUTAS ESPECÍFICAS POR CATEGORÍA
      GoRoute(
        path: '/home/:category',
        redirect: (context, state) {
          final category = state.pathParameters['category']!;
          return '/home/$category/dashboard';
        },
      ),
      
      // Abarrotes
      abarrotesRoutes,
      
      // Ropa y Calzado
      ropaCalzadoRoutes,
      
      // Hogar y Decoración
      hogarDecoracionRoutes,
      
      // Electrónica
      electronicaRoutes,
      
      // Verdulería
      verduleriaRoutes,
      
      // Papa Mayorista
      papaMayoristaRoutes,
      
      // Carnicería
      carniceriaRoutes,
      
      // Ferretería
      ferreteriaRoutes,
      
      // Farmacia
      farmaciaRoutes,
      
      // Restaurante
      restauranteRoutes,
      
      // Mayorista
      mayoristaRoutes,
      
      // Otro/General
      otroRoutes,
      
      // Rutas globales (sin categoría específica)
      GoRoute(
        path: '/clients',
        name: 'clients',
        builder: (context, state) => const ClientsPage(),
        routes: [
          GoRoute(
            path: '/add',
            name: 'add_client',
            builder: (context, state) => const AddClientPage(),
          ),
          GoRoute(
            path: '/:id',
            name: 'client_detail',
            builder: (context, state) => ClientDetailPage(
              clientId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/business',
            name: 'business_settings',
            builder: (context, state) => const BusinessSettingsPage(),
          ),
        ],
      ),
      
      GoRoute(
        path: '/security',
        name: 'security',
        builder: (context, state) => const SecurityDashboardPage(),
        routes: [
          GoRoute(
            path: '/alerts',
            name: 'security_alerts',
            builder: (context, state) => const SecurityAlertsPage(),
          ),
          GoRoute(
            path: '/login-attempts',
            name: 'login_attempts',
            builder: (context, state) => const LoginAttemptsPage(),
          ),
          GoRoute(
            path: '/ip-whitelist',
            name: 'ip_whitelist',
            builder: (context, state) => const IPWhitelistPage(),
          ),
          GoRoute(
            path: '/audit-logs',
            name: 'audit_logs',
            builder: (context, state) => const AuditLogsPage(),
          ),
        ],
      ),
      
      GoRoute(
        path: '/help',
        name: 'help',
        builder: (context, state) => const HelpPage(),
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );

  static String? _redirectLogic(BuildContext context, GoRouterState state) {
    final authState = context.read<AuthProvider>().authState;
    final isAuthenticated = authState.isAuthenticated;
    final isOnboardingComplete = authState.isOnboardingComplete;
    
    // Lógica de redirección según autenticación y onboarding
    if (!isAuthenticated && state.fullPath != '/login') {
      return '/login';
    }
    
    if (isAuthenticated && !isOnboardingComplete && state.fullPath != '/onboarding') {
      return '/onboarding';
    }
    
    if (isAuthenticated && isOnboardingComplete && state.fullPath == '/login') {
      final category = context.read<AppProvider>().currentBusinessCategory;
      return '/home/$category/dashboard';
    }
    
    return null; // No redirect
  }
}
```

---

### 🛡️ **GUARDS Y MIDDLEWARE**

```dart
// app/routes/route_guards.dart
class RouteGuards {
  // Verificar autenticación
  static Future<bool> requireAuth(BuildContext context, GoRouterState state) async {
    final authState = context.read<AuthProvider>().authState;
    if (!authState.isAuthenticated) {
      context.go('/login');
      return false;
    }
    return true;
  }

  // Verificar que el negocio esté configurado
  static Future<bool> requireBusinessSetup(BuildContext context, GoRouterState state) async {
    final hasBusiness = context.read<AppProvider>().hasBusiness;
    if (!hasBusiness) {
      context.go('/onboarding');
      return false;
    }
    return true;
  }

  // Verificar permisos específicos
  static Future<bool> requirePermission(
    BuildContext context,
    String permission,
  ) async {
    final userRole = context.read<AuthProvider>().currentUser?.role;
    final hasPermission = await PermissionService.hasPermission(userRole, permission);
    
    if (!hasPermission) {
      context.go('/unauthorized');
      return false;
    }
    return true;
  }

  // Guard para categorías específicas
  static Future<bool> requireCategoryAccess(
    BuildContext context,
    String category,
  ) async {
    final currentCategory = context.read<AppProvider>().currentBusinessCategory;
    if (currentCategory != category) {
      // Redirigir al dashboard de la categoría activa
      context.go('/home/$currentCategory/dashboard');
      return false;
    }
    return true;
  }
}
```

---

### 🗄️ **ESQUEMA DE BASE DE DATOS POSTGRESQL**

```sql
-- =============================================================================
-- TABLA: usuarios (Users)
-- Descripción: Usuarios del sistema
-- =============================================================================
CREATE TABLE usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    nombre_completo TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    esta_activo BOOLEAN DEFAULT true,
    rol TEXT DEFAULT 'propietario',
    ultimo_acceso TIMESTAMPTZ,
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_usuarios_email ON usuarios(email);

-- =============================================================================
-- TABLA: negocios (Business)
-- Descripción: Almacena información de cada negocio por usuario
-- =============================================================================
CREATE TABLE negocios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    nombre_comercial TEXT NOT NULL,
    ruc TEXT,
    logo_url TEXT,
    pais TEXT NOT NULL DEFAULT 'Perú',
    departamento TEXT NOT NULL,
    provincia TEXT NOT NULL,
    distrito TEXT NOT NULL,
    direccion_completa TEXT NOT NULL,
    moneda TEXT NOT NULL DEFAULT 'PEN',
    rubro TEXT NOT NULL, -- abarrotes, ropa_calzado, etc.
    modelo_negocio TEXT NOT NULL, -- b2c, b2b, hibrido
    configuracion JSONB NOT NULL DEFAULT '{}',
    modulos_activos JSONB NOT NULL DEFAULT '[]',
    esta_activo BOOLEAN NOT NULL DEFAULT true,
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_actualizacion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT check_rubro_valido CHECK (
        rubro IN (
            'abarrotes', 'ropa_calzado', 'hogar_decoracion',
            'electronica', 'verduleria', 'papa_mayorista',
            'carniceria', 'ferreteria', 'farmacia',
            'restaurante', 'mayorista', 'otro'
        )
    )
);

-- Índices
CREATE INDEX idx_negocios_user_id ON negocios(user_id);
CREATE INDEX idx_negocios_rubro ON negocios(rubro);
CREATE INDEX idx_negocios_activo ON negocios(esta_activo);

-- =============================================================================
-- TABLA: productos (Products)
-- Descripción: Productos por negocio
-- =============================================================================
CREATE TABLE productos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    negocio_id UUID NOT NULL REFERENCES negocios(id) ON DELETE CASCADE,
    codigo_barras TEXT UNIQUE,
    codigo_qr TEXT UNIQUE,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    categoria TEXT NOT NULL,
    precio_venta NUMERIC(10, 2) NOT NULL,
    precio_compra NUMERIC(10, 2),
    stock INTEGER NOT NULL DEFAULT 0,
    stock_minimo INTEGER DEFAULT 5,
    unidad_medida TEXT NOT NULL DEFAULT 'unidad',
    atributos JSONB DEFAULT '{}', -- Campos específicos por categoría
    imagen_url TEXT,
    tiene_vencimiento BOOLEAN DEFAULT false,
    fecha_vencimiento DATE,
    esta_activo BOOLEAN NOT NULL DEFAULT true,
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_actualizacion TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_productos_negocio ON productos(negocio_id);
CREATE INDEX idx_productos_categoria ON productos(categoria);
CREATE INDEX idx_productos_codigo_barras ON productos(codigo_barras);
CREATE INDEX idx_productos_stock_bajo ON productos(stock) WHERE stock <= stock_minimo;
CREATE INDEX idx_productos_vencimiento ON productos(fecha_vencimiento) WHERE tiene_vencimiento = true;

-- =============================================================================
-- TABLA: ventas (Sales)
-- Descripción: Registro de ventas
-- =============================================================================
CREATE TABLE ventas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    negocio_id UUID NOT NULL REFERENCES negocios(id) ON DELETE CASCADE,
    cliente_id UUID REFERENCES clientes(id),
    numero_ticket TEXT UNIQUE NOT NULL,
    productos JSONB NOT NULL, -- [{id, nombre, cantidad, precio, subtotal}]
    subtotal NUMERIC(10, 2) NOT NULL,
    descuento NUMERIC(10, 2) DEFAULT 0,
    impuesto NUMERIC(10, 2) DEFAULT 0,
    total NUMERIC(10, 2) NOT NULL,
    metodo_pago TEXT NOT NULL, -- efectivo, yape, plin, tarjeta, credito
    estado TEXT NOT NULL DEFAULT 'completado', -- completado, anulado
    es_fiado BOOLEAN DEFAULT false,
    fecha_venta TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    creado_por UUID REFERENCES usuarios(id),
    CONSTRAINT check_metodo_pago_valido CHECK (
        metodo_pago IN ('efectivo', 'yape', 'plin', 'tarjeta', 'credito')
    )
);

-- Índices
CREATE INDEX idx_ventas_negocio ON ventas(negocio_id);
CREATE INDEX idx_ventas_cliente ON ventas(cliente_id);
CREATE INDEX idx_ventas_fecha ON ventas(fecha_venta DESC);
CREATE INDEX idx_ventas_fiado ON ventas(es_fiado) WHERE es_fiado = true;

-- =============================================================================
-- TABLA: clientes (Clients)
-- Descripción: Clientes por negocio
-- =============================================================================
CREATE TABLE clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    negocio_id UUID NOT NULL REFERENCES negocios(id) ON DELETE CASCADE,
    nombre_completo TEXT NOT NULL,
    tipo_documento TEXT DEFAULT 'dni',
    numero_documento TEXT,
    telefono TEXT,
    email TEXT,
    direccion TEXT,
    limites_credito NUMERIC(10, 2) DEFAULT 0,
    deuda_actual NUMERIC(10, 2) DEFAULT 0,
    puntos_acumulados INTEGER DEFAULT 0,
    es_moroso BOOLEAN DEFAULT false,
    fecha_ultima_compra DATE,
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_actualizacion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT check_documento_valido CHECK (
        tipo_documento IN ('dni', 'ce', 'ruc', 'passport')
    )
);

-- Índices
CREATE INDEX idx_clientes_negocio ON clientes(negocio_id);
CREATE INDEX idx_clientes_documento ON clientes(numero_documento);
CREATE INDEX idx_clientes_morosos ON clientes(es_moroso) WHERE es_moroso = true;

-- =============================================================================
-- TABLA: creditos (Credits/Fiados)
-- Descripción: Control de créditos y pagos
-- =============================================================================
CREATE TABLE creditos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    negocio_id UUID NOT NULL REFERENCES negocios(id) ON DELETE CASCADE,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    venta_id UUID REFERENCES ventas(id),
    monto_total NUMERIC(10, 2) NOT NULL,
    monto_pagado NUMERIC(10, 2) DEFAULT 0,
    saldo_pendiente NUMERIC(10, 2) NOT NULL,
    plazo_dias INTEGER NOT NULL DEFAULT 30,
    fecha_inicio DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_vencimiento DATE NOT NULL,
    estado TEXT NOT NULL DEFAULT 'pendiente', -- pendiente, pagado, vencido, cancelado
    descripcion TEXT,
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT check_estado_credito CHECK (
        estado IN ('pendiente', 'pagado', 'vencido', 'cancelado')
    )
);

-- Índices
CREATE INDEX idx_creditos_negocio ON creditos(negocio_id);
CREATE INDEX idx_creditos_cliente ON creditos(cliente_id);
CREATE INDEX idx_creditos_vencidos ON creditos(fecha_vencimiento) WHERE estado = 'pendiente';
CREATE INDEX idx_creditos_estado ON creditos(estado);

-- =============================================================================
-- TABLA: pagos_credito (Credit Payments)
-- Descripción: Pagos realizados contra créditos
-- =============================================================================
CREATE TABLE pagos_credito (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    credito_id UUID NOT NULL REFERENCES creditos(id) ON DELETE CASCADE,
    monto NUMERIC(10, 2) NOT NULL,
    metodo_pago TEXT NOT NULL,
    fecha_pago TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    observaciones TEXT,
    creado_por UUID REFERENCES usuarios(id)
);

-- Índices
CREATE INDEX idx_pagos_credito ON pagos_credito(credito_id);
CREATE INDEX idx_pagos_fecha ON pagos_credito(fecha_pago DESC);

-- =============================================================================
-- TABLA: proveedores (Suppliers)
-- Descripción: Proveedores por negocio
-- =============================================================================
CREATE TABLE proveedores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    negocio_id UUID NOT NULL REFERENCES negocios(id) ON DELETE CASCADE,
    nombre TEXT NOT NULL,
    ruc TEXT,
    contacto TEXT,
    telefono TEXT,
    email TEXT,
    direccion TEXT,
    productos_suministrados TEXT[],
    evaluacion INTEGER DEFAULT 5 CHECK (evaluacion BETWEEN 1 AND 5),
    fecha_ultima_compra DATE,
    esta_activo BOOLEAN DEFAULT true,
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_proveedores_negocio ON proveedores(negocio_id);

-- =============================================================================
-- TABLA: compras (Purchases)
-- Descripción: Registro de compras a proveedores
-- =============================================================================
CREATE TABLE compras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    negocio_id UUID NOT NULL REFERENCES negocios(id) ON DELETE CASCADE,
    proveedor_id UUID NOT NULL REFERENCES proveedores(id),
    numero_documento TEXT NOT NULL,
    tipo_documento TEXT NOT NULL, -- factura, boleta, guia
    total NUMERIC(10, 2) NOT NULL,
    fecha_compra DATE NOT NULL,
    fecha_vencimiento DATE,
    estado_pago TEXT NOT NULL DEFAULT 'pendiente', -- pendiente, pagado
    productos JSONB NOT NULL,
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_compras_negocio ON compras(negocio_id);
CREATE INDEX idx_compras_proveedor ON compras(proveedor_id);
CREATE INDEX idx_compras_estado ON compras(estado_pago);

-- =============================================================================
-- TABLA: caja (Cash Register)
-- Descripción: Control de caja registradora
-- =============================================================================
CREATE TABLE caja (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    negocio_id UUID NOT NULL REFERENCES negocios(id) ON DELETE CASCADE,
    apertura_turno TIMESTAMPTZ NOT NULL,
    cierre_turno TIMESTAMPTZ,
    monto_inicial NUMERIC(10, 2) NOT NULL,
    monto_final NUMERIC(10, 2),
    total_efectivo NUMERIC(10, 2) DEFAULT 0,
    total_yape NUMERIC(10, 2) DEFAULT 0,
    total_plin NUMERIC(10, 2) DEFAULT 0,
    total_tarjeta NUMERIC(10, 2) DEFAULT 0,
    total_credito NUMERIC(10, 2) DEFAULT 0,
    cantidad_ventas INTEGER DEFAULT 0,
    estado TEXT NOT NULL DEFAULT 'abierta', -- abierta, cerrada
    observaciones TEXT,
    cerrado_por UUID REFERENCES usuarios(id)
);

-- Índices
CREATE INDEX idx_caja_negocio ON caja(negocio_id);
CREATE INDEX idx_caja_estado ON caja(estado);
CREATE INDEX idx_caja_fecha ON caja(apertura_turno DESC);

-- =============================================================================
-- TABLA: movimientos_inventario (Inventory Movements)
-- Descripción: Registro de entradas/salidas de inventario
-- =============================================================================
CREATE TABLE movimientos_inventario (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    negocio_id UUID NOT NULL REFERENCES negocios(id) ON DELETE CASCADE,
    producto_id UUID NOT NULL REFERENCES productos(id) ON DELETE CASCADE,
    tipo_movimiento TEXT NOT NULL, -- entrada, salida, ajuste
    cantidad INTEGER NOT NULL,
    motivo TEXT,
    referencia TEXT, -- venta_id, compra_id, etc.
    fecha_movimiento TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    usuario_id UUID REFERENCES usuarios(id)
);

-- Índices
CREATE INDEX idx_movimientos_negocio ON movimientos_inventario(negocio_id);
CREATE INDEX idx_movimientos_producto ON movimientos_inventario(producto_id);
CREATE INDEX idx_movimientos_fecha ON movimientos_inventario(fecha_movimiento DESC);

-- =============================================================================
-- TABLA: notificaciones (Notifications)
-- Descripción: Notificaciones del sistema
-- =============================================================================
CREATE TABLE notificaciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    negocio_id UUID NOT NULL REFERENCES negocios(id) ON DELETE CASCADE,
    tipo_notificacion TEXT NOT NULL, -- stock_bajo, vencimiento, moroso, etc.
    titulo TEXT NOT NULL,
    mensaje TEXT NOT NULL,
    datos_adicionales JSONB DEFAULT '{}',
    leida BOOLEAN DEFAULT false,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_notificaciones_negocio ON notificaciones(negocio_id);
CREATE INDEX idx_notificaciones_leida ON notificaciones(leida);

-- =============================================================================
-- TABLA: seguridad_eventos (Security Events)
-- Descripción: Registro de eventos de seguridad e intentos de intrusión
-- =============================================================================
CREATE TABLE seguridad_eventos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    negocio_id UUID NOT NULL REFERENCES negocios(id) ON DELETE CASCADE,
    tipo_evento TEXT NOT NULL, -- login_intento, acceso_denegado, cambio_password, bloqueo_ip, etc.
    severidad TEXT NOT NULL, -- bajo, medio, alto, critico
    ip_address TEXT NOT NULL,
    user_agent TEXT,
    ubicacion TEXT, -- Ciudad, país
    usuario_id UUID REFERENCES usuarios(id),
    exito BOOLEAN NOT NULL,
    detalle TEXT,
    metadata JSONB DEFAULT '{}', -- Datos adicionales
    fecha_evento TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resuelto BOOLEAN DEFAULT false,
    resuelto_por UUID REFERENCES usuarios(id),
    fecha_resolucion TIMESTAMPTZ
);

-- Índices
CREATE INDEX idx_seguridad_negocio ON seguridad_eventos(negocio_id);
CREATE INDEX idx_seguridad_tipo ON seguridad_eventos(tipo_evento);
CREATE INDEX idx_seguridad_severidad ON seguridad_eventos(severidad);
CREATE INDEX idx_seguridad_ip ON seguridad_eventos(ip_address);
CREATE INDEX idx_seguridad_fecha ON seguridad_eventos(fecha_evento DESC);
CREATE INDEX idx_seguridad_no_resueltos ON seguridad_eventos(resuelto) WHERE resuelto = false;
CREATE INDEX idx_seguridad_criticos ON seguridad_eventos(severidad) WHERE severidad = 'critico';

-- =============================================================================
-- TABLA: ip_bloqueadas (Blocked IPs)
-- Descripción: IPs bloqueadas por actividad sospechosa
-- =============================================================================
CREATE TABLE ip_bloqueadas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ip_address TEXT NOT NULL UNIQUE,
    negocio_id UUID REFERENCES negocios(id) ON DELETE CASCADE,
    razon TEXT NOT NULL,
    fecha_bloqueo TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_desbloqueo TIMESTAMPTZ,
    bloqueado_por UUID REFERENCES usuarios(id),
    intentos_fallidos INTEGER DEFAULT 0
);

-- Índices
CREATE INDEX idx_ip_bloqueadas ON ip_bloqueadas(ip_address);
CREATE INDEX idx_ip_bloqueadas_activas ON ip_bloqueadas(fecha_desbloqueo) WHERE fecha_desbloqueo IS NULL;

-- =============================================================================
-- TABLA: intentos_login (Login Attempts)
-- Descripción: Registro de todos los intentos de login
-- =============================================================================
CREATE TABLE intentos_login (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL,
    ip_address TEXT NOT NULL,
    user_agent TEXT,
    exito BOOLEAN NOT NULL,
    razon_fallo TEXT,
    intento_numero INTEGER DEFAULT 1,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_intentos_email ON intentos_login(email);
CREATE INDEX idx_intentos_ip ON intentos_login(ip_address);
CREATE INDEX idx_intentos_fecha ON intentos_login(timestamp DESC);
CREATE INDEX idx_intentos_fallidos ON intentos_login(exito) WHERE exito = false;

-- =============================================================================
-- TABLA: auditoria (Audit Logs)
-- Descripción: Log completo de acciones críticas del sistema
-- =============================================================================
CREATE TABLE auditoria (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    negocio_id UUID NOT NULL REFERENCES negocios(id) ON DELETE CASCADE,
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    accion TEXT NOT NULL, -- crear, modificar, eliminar, exportar, etc.
    tabla_afectada TEXT NOT NULL, -- productos, ventas, configuracion, etc.
    registro_id TEXT,
    valores_anteriores JSONB,
    valores_nuevos JSONB,
    ip_address TEXT,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_auditoria_negocio ON auditoria(negocio_id);
CREATE INDEX idx_auditoria_usuario ON auditoria(usuario_id);
CREATE INDEX idx_auditoria_accion ON auditoria(accion);
CREATE INDEX idx_auditoria_tabla ON auditoria(tabla_afectada);
CREATE INDEX idx_auditoria_fecha ON auditoria(timestamp DESC);

-- =============================================================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE negocios ENABLE ROW LEVEL SECURITY;
ALTER TABLE productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE ventas ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE creditos ENABLE ROW LEVEL SECURITY;
ALTER TABLE pagos_credito ENABLE ROW LEVEL SECURITY;
ALTER TABLE proveedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE compras ENABLE ROW LEVEL SECURITY;
ALTER TABLE caja ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimientos_inventario ENABLE ROW LEVEL SECURITY;
ALTER TABLE notificaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE seguridad_eventos ENABLE ROW LEVEL SECURITY;
ALTER TABLE ip_bloqueadas ENABLE ROW LEVEL SECURITY;
ALTER TABLE intentos_login ENABLE ROW LEVEL SECURITY;
ALTER TABLE auditoria ENABLE ROW LEVEL SECURITY;

-- Políticas RLS: Usuarios solo pueden ver sus propios negocios
-- Usar sesiones de aplicación para identificar usuario actual
CREATE POLICY "Usuarios pueden ver sus propios negocios"
    ON negocios FOR SELECT
    USING (
        user_id = current_setting('app.current_user_id', true)::UUID
    );

CREATE POLICY "Usuarios pueden insertar sus propios negocios"
    ON negocios FOR INSERT
    WITH CHECK (
        user_id = current_setting('app.current_user_id', true)::UUID
    );

CREATE POLICY "Usuarios pueden actualizar sus propios negocios"
    ON negocios FOR UPDATE
    USING (
        user_id = current_setting('app.current_user_id', true)::UUID
    );

-- Política para productos
CREATE POLICY "Business access own products"
    ON productos FOR ALL
    USING (
        negocio_id IN (
            SELECT id FROM negocios 
            WHERE user_id = current_setting('app.current_user_id', true)::UUID
        )
    );

-- Políticas para seguridad (acceso solo a su negocio)
CREATE POLICY "business_access_own_security"
    ON seguridad_eventos FOR ALL
    USING (
        negocio_id IN (
            SELECT id FROM negocios 
            WHERE user_id = current_setting('app.current_user_id', true)::UUID
        )
    );

CREATE POLICY "business_access_own_audit"
    ON auditoria FOR ALL
    USING (
        negocio_id IN (
            SELECT id FROM negocios 
            WHERE user_id = current_setting('app.current_user_id', true)::UUID
        )
    );

-- Aplicar políticas similares para todas las demás tablas...
-- Nota: La app debe setear 'app.current_user_id' en cada sesión
```

---

### 🛡️ **MÓDULO DE SEGURIDAD Y ALERTAS**

El sistema incluye un módulo de seguridad integrado para detectar y alertar sobre posibles intentos de intrusión o actividad maliciosa.

#### **Funcionalidades:**

**1. Detección de Intrusión:**
```dart
// domain/usecases/log_security_event_usecase.dart
class LogSecurityEventUseCase {
  final SecurityRepository repository;
  
  Future<Either<Failure, void>> call(SecurityEvent event) async {
    // Registrar evento de seguridad
    await repository.logSecurityEvent(event);
    
    // Si es crítico, notificar inmediatamente
    if (event.severity == 'critico') {
      await repository.sendSecurityAlert(event);
    }
    
    // Verificar si IP debe bloquearse
    final attempts = await repository.getFailedAttempts(event.ipAddress);
    if (attempts >= 5) {
      await repository.blockIP(event.ipAddress, 'Múltiples intentos fallidos');
    }
    
    return const Right(null);
  }
}
```

**2. Alertas de Seguridad:**
```dart
// presentation/widgets/threat_alert_card.dart
class ThreatAlertCard extends StatelessWidget {
  final SecurityEvent event;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getSeverityColor(event.severity),
      child: ListTile(
        leading: Icon(_getSeverityIcon(event.severity)),
        title: Text(event.tipoEvento),
        subtitle: Text('IP: ${event.ipAddress}'),
        trailing: Text(event.fechaEvento.toString()),
      ),
    );
  }
  
  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critico': return Colors.red.shade900;
      case 'alto': return Colors.red.shade600;
      case 'medio': return Colors.orange.shade600;
      case 'bajo': return Colors.yellow.shade600;
      default: return Colors.grey;
    }
  }
}
```

**3. Tipos de Eventos Monitoreados:**
- 🔐 **Login Fallidos:** Múltiples intentos con contraseñas incorrectas
- 🚫 **Acceso Denegado:** Intento de acceder a recursos sin permisos
- 🔄 **Cambio de Credenciales:** Modificación de contraseñas/sesiones
- 📊 **Consultas Sospechosas:** Queries inusuales o excesivas
- 🌐 **IPs Anómalas:** Conexiones desde ubicaciones desconocidas
- 🔍 **Manipulación de Datos:** Intentos de modificar información crítica
- ⚠️ **Exportación Masiva:** Descarga excesiva de datos
- 💰 **Movimientos Financieros:** Operaciones sospechosas en caja/ventas

**4. Dashboard de Seguridad:**
```dart
// presentation/pages/security_dashboard_page.dart
class SecurityDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Métricas de seguridad
          Row(
            children: [
              _buildMetricCard('Alertas Hoy', '12', Colors.orange),
              _buildMetricCard('IPs Bloqueadas', '3', Colors.red),
              _buildMetricCard('Intentos Fallidos', '45', Colors.yellow),
              _buildMetricCard('Eventos Críticos', '2', Colors.red.shade900),
            ],
          ),
          
          // Gráfico de eventos por hora
          LineChart(securityEventsChart),
          
          // Mapa de ubicaciones
          WorldMap(loginLocations),
          
          // Alertas recientes
          Expanded(
            child: ListView.builder(
              itemCount: alerts.length,
              itemBuilder: (context, index) => ThreatAlertCard(alerts[index]),
            ),
          ),
        ],
      ),
    );
  }
}
```

**5. Bloqueo Automático:**
```dart
// Automatic IP blocking after 5 failed attempts
if (failedAttempts >= 5) {
  await securityRepository.blockIP(
    ipAddress: event.ipAddress,
    reason: 'Múltiples intentos de login fallidos',
    duration: Duration(hours: 24),
  );
  
  await notificationService.sendAlert(
    type: 'security_critical',
    title: 'IP Bloqueada',
    message: 'IP ${event.ipAddress} bloqueada por actividad sospechosa',
  );
}
```

---

### 🔄 **EJEMPLO DE NAVEGACIÓN DINÁMICA**

```dart
// presentation/shared/widgets/navigation_helper.dart
class NavigationHelper {
  // Navegar al dashboard según la categoría
  static void toDashboard(BuildContext context) {
    final category = context.read<AppProvider>().currentBusinessCategory;
    context.go('/home/$category/dashboard');
  }

  // Navegar al POS según la categoría
  static void toPOS(BuildContext context) {
    final category = context.read<AppProvider>().currentBusinessCategory;
    context.go('/home/$category/pos');
  }

  // Navegar a un módulo específico según la categoría
  static void toModule(BuildContext context, String module) {
    final category = context.read<AppProvider>().currentBusinessCategory;
    context.go('/home/$category/$module');
  }

  // Navegar a una ruta específica de categoría
  static void toCategoryRoute(BuildContext context, String route) {
    final category = context.read<AppProvider>().currentBusinessCategory;
    context.go('/home/$category$route');
  }
}

// Uso en el código
// NavigationHelper.toDashboard(context);
// NavigationHelper.toModule(context, 'credits');
// NavigationHelper.toCategoryRoute(context, '/credits/new');
```

---

## 🗄️ ARQUITECTURA DE BASE DE DATOS POSTGRESQL ESCALABLE

### 🎯 **VISIÓN ESTRATÉGICA**

**PostgreSQL es la base de datos elegida** para este sistema empresarial multi-negocio debido a su:
- ✅ **Robustez** industrial probada (Instagram, Spotify, Uber)
- ✅ **Escalabilidad** horizontal y vertical
- ✅ **JSONB** para configuraciones dinámicas por categoría
- ✅ **RLS** para seguridad multi-tenant
- ✅ **Open Source** con comunidad activa

---

### 📊 **ARQUITECTURA MULTI-CAPA**

```
┌─────────────────────────────────────────────────────────────┐
│                    APLICACIÓN FLUTTER                        │
│              (Mobile/Tablet/Desktop)                         │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ↓ HTTPS/REST
┌─────────────────────────────────────────────────────────────┐
│                  BACKEND API LAYER                           │
│         (Node.js/Dart - Express/Shelf)                       │
│  ┌────────────────┐  ┌─────────────────┐                   │
│  │ API Gateway    │  │ Load Balancer   │                   │
│  └────────────────┘  └─────────────────┘                   │
└───────────────────────┬─────────────────────────────────────┘
                        │
        ┌───────────────┴───────────────┐
        ↓                               ↓
┌──────────────────┐          ┌─────────────────────┐
│   CACHE LAYER    │          │   DATABASE LAYER    │
│     REDIS        │          │   PostgreSQL        │
│ - Session Store  │          │   Primary DB        │
│ - Query Cache    │          │   (Read/Write)      │
│ - Rate Limiting  │          └──────────┬──────────┘
└──────────────────┘                     │
                                         ↓
                            ┌────────────────────────────┐
                            │   READ REPLICAS            │
                            │   PostgreSQL               │
                            │   ┌─────┐  ┌─────┐         │
                            │   │ R1  │  │ R2  │  ...    │
                            │   └─────┘  └─────┘         │
                            └────────────────────────────┘
```

---

### 🚀 **ESTRATEGIA DE ESCALABILIDAD**

#### **FASE 1: Inicial (0-100 usuarios)** 💚

```
PostgreSQL Cloud (Railway/Neon)
├── Tier: Starter/Free
├── Storage: 5GB
├── RAM: 1-2GB
├── Backups: Diarios automáticos
└── Costo: $0-10/mes

Redis Cache (Opcional)
├── Tier: Free tier
├── RAM: 25MB
└── Propósito: Session cache
```

**Configuración:**
- ✅ 1 instancia PostgreSQL
- ✅ Connection pooling (20-50 conexiones)
- ✅ Índices básicos
- ✅ Backups automáticos

---

#### **FASE 2: Crecimiento (100-1,000 usuarios)** 💛

```
PostgreSQL Cloud (Railway/Neon Pro)
├── Tier: Pro
├── Storage: 50GB
├── RAM: 4-8GB
├── Read Replicas: 1
├── Connection pooling: PgBouncer
└── Costo: $20-40/mes

Redis Cache (Essentials)
├── Tier: Paid
├── RAM: 1GB
├── Persistence: AOF
└── Propósito: Cache + Sessions

CDN (CloudFlare)
├── Tier: Free
└── Propósito: Static assets
```

**Mejoras:**
- ✅ Read Replica para queries pesadas
- ✅ PgBouncer para pooling eficiente
- ✅ Redis para cache agresiva
- ✅ Monitoreo con Grafana
- ✅ Alertas automáticas

---

#### **FASE 3: Escala Media (1,000-10,000 usuarios)** 🟠

```
PostgreSQL Cloud (Neon/AWS RDS)
├── Tier: Business
├── Storage: 500GB
├── RAM: 16GB
├── Read Replicas: 2-3
├── Multi-AZ: Habilitado
└── Costo: $100-300/mes

Redis Cluster
├── Tier: Cluster Mode
├── Nodes: 3-6
├── RAM: 6GB total
└── Persistence: RDB + AOF

Load Balancer
├── Tier: Standard
├── Health checks
└── Auto-scaling

Search Engine (ElasticSearch)
├── Tier: Basic
├── RAM: 2GB
└── Propósito: Búsquedas full-text
```

**Mejoras:**
- ✅ Multi-AZ para alta disponibilidad
- ✅ Auto-failover automático
- ✅ Sharding por región
- ✅ ElasticSearch para búsquedas
- ✅ Metrics avanzadas

---

#### **FASE 4: Gran Escala (10,000+ usuarios)** 🔴

```
PostgreSQL Cluster (Citus/Greenplum)
├── Tier: Enterprise
├── Storage: Multi-TB
├── Nodes: 10-50+
├── Sharding: Por categoría/región
└── Costo: $1,000+/mes

Redis Enterprise
├── Tier: Enterprise
├── Global replication
├── Multi-region
└── Auto-failover

Microservicios
├── Auth Service
├── Inventory Service
├── Sales Service
├── Notifications Service
└── Reports Service

Message Queue (RabbitMQ/Kafka)
├── Tier: Standard
└── Propósito: Event sourcing
```

**Optimizaciones:**
- ✅ Sharding horizontal automático
- ✅ Read replicas por región
- ✅ CQRS pattern
- ✅ Event sourcing
- ✅ Microservicios independientes

---

### 🏗️ **OPTIMIZACIONES POSTGRESQL**

#### **1. Índices Estratégicos**

```sql
-- Índices básicos (crear al inicio)
CREATE INDEX idx_negocios_user_id ON negocios(user_id);
CREATE INDEX idx_productos_negocio ON productos(negocio_id);
CREATE INDEX idx_ventas_fecha ON ventas(fecha_venta DESC);
CREATE INDEX idx_ventas_cliente ON ventas(cliente_id);

-- Índices compuestos (optimización)
CREATE INDEX idx_productos_busqueda 
  ON productos(negocio_id, categoria, nombre) 
  WHERE esta_activo = true;

CREATE INDEX idx_ventas_rango_fecha 
  ON ventas(negocio_id, fecha_venta DESC) 
  WHERE estado = 'completado';

-- Índices JSONB (búsqueda en configuraciones)
CREATE INDEX idx_negocios_config 
  ON negocios USING GIN(configuracion);

CREATE INDEX idx_productos_atributos 
  ON productos USING GIN(atributos);

-- Índices funcionales (expresiones)
CREATE INDEX idx_clientes_nombre_lower 
  ON clientes(lower(nombre_completo));

-- Índices parciales (solo datos activos)
CREATE INDEX idx_creditos_pendientes 
  ON creditos(negocio_id, fecha_vencimiento) 
  WHERE estado = 'pendiente';
```

---

#### **2. Particionamiento de Tablas**

```sql
-- Particionar ventas por mes (archivado)
CREATE TABLE ventas (
    id UUID DEFAULT gen_random_uuid(),
    negocio_id UUID NOT NULL,
    fecha_venta TIMESTAMPTZ NOT NULL,
    total NUMERIC NOT NULL,
    -- otros campos...
    PRIMARY KEY (id, fecha_venta)
) PARTITION BY RANGE (fecha_venta);

-- Crear particiones mensuales
CREATE TABLE ventas_2024_01 PARTITION OF ventas
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE ventas_2024_02 PARTITION OF ventas
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Auto-crear particiones futuras (script)
-- Ejecutar mensualmente
```

**Beneficios:**
- ✅ **Query performance**: PostgreSQL consulta solo la partición necesaria
- ✅ **Mantenimiento**: Eliminar particiones viejas es rápido
- ✅ **Backups**: Backup incremental por partición
- ✅ **Indexing**: Índices más pequeños por partición

---

#### **3. Connection Pooling**

```dart
// data/datasources/postgres_datasource.dart
import 'package:postgres/postgres.dart';
import 'package:synchronized/synchronized.dart';

class PostgresDataSource {
  static PostgreSQLConnection? _connection;
  static final Lock _lock = Lock();
  
  // Pool configuration
  static const int maxConnections = 25;
  static const Duration idleTimeout = Duration(minutes: 10);
  static const Duration connectTimeout = Duration(seconds: 30);
  
  static Future<PostgreSQLConnection> getConnection() async {
    if (_connection == null || _connection!.isClosed) {
      await _lock.synchronized(() async {
        if (_connection == null || _connection!.isClosed) {
          _connection = PostgreSQLConnection(
            host: AppConfig.dbHost,
            port: AppConfig.dbPort,
            databaseName: AppConfig.dbName,
            username: AppConfig.dbUser,
            password: AppConfig.dbPassword,
            timeoutInSeconds: 30,
          );
          
          await _connection!.open();
          
          // Configurar pool
          await _connection!.execute('''
            SET max_connections = $maxConnections;
            SET idle_in_transaction_session_timeout = ${idleTimeout.inSeconds * 1000};
          ''');
        }
      });
    }
    return _connection!;
  }
}
```

**Mejores Prácticas:**
- ✅ **Pool size**: 20-50 conexiones máximo
- ✅ **Idle timeout**: 10 minutos
- ✅ **Connection timeout**: 30 segundos
- ✅ **Max lifetime**: 1 hora (rotar conexiones)
- ✅ **Health checks**: Verificar cada 5 minutos

---

#### **4. Read Replicas (Para Queries Pesadas)**

```dart
// data/datasources/postgres_replica_datasource.dart
class PostgresReplicaDataSource {
  static final List<PostgreSQLConnection> _replicas = [];
  static int _currentIndex = 0;
  
  static Future<List<Product>> getProducts(String businessId) async {
    // Usar réplica para SELECT queries
    final replica = _getReplica();
    final result = await replica.query('''
      SELECT * FROM productos 
      WHERE negocio_id = @businessId
      ORDER BY nombre
    ''', substitutionValues: {'businessId': businessId});
    
    return result.map((row) => Product.fromRow(row)).toList();
  }
  
  static PostgreSQLConnection _getReplica() {
    // Round-robin load balancing
    final replica = _replicas[_currentIndex];
    _currentIndex = (_currentIndex + 1) % _replicas.length;
    return replica;
  }
}
```

---

#### **5. Caching con Redis**

```dart
// data/datasources/redis_datasource.dart
import 'package:redis/redis.dart';

class RedisDataSource {
  late RedisConnection connection;
  
  // Cache products for 1 hour
  Future<List<Product>> getProductsCached(String businessId) async {
    final cacheKey = 'products:$businessId';
    
    // Try cache first
    final cached = await connection.get(cacheKey);
    if (cached != null) {
      return (json.decode(cached) as List)
          .map((item) => Product.fromJson(item))
          .toList();
    }
    
    // Cache miss: fetch from PostgreSQL
    final products = await postgresDataSource.getProducts(businessId);
    
    // Store in cache for 1 hour
    await connection.setex(cacheKey, 3600, json.encode(products));
    
    return products;
  }
  
  // Invalidate cache on update
  Future<void> invalidateProductsCache(String businessId) async {
    await connection.del('products:$businessId');
  }
}
```

**Estrategia de Cache:**
- ✅ **Cache-aside**: App maneja cache explícitamente
- ✅ **TTL**: 1 hora para datos dinámicos
- ✅ **Invalidation**: Eliminar al actualizar
- ✅ **Hot keys**: Cache permanente para lookup tables

---

### 📈 **MONITOREO Y OPTIMIZACIÓN**

```sql
-- Queries más lentas (ejecutar diariamente)
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    max_time
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

-- Tamaño de tablas
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Conexiones activas
SELECT 
    count(*) as total_connections,
    count(*) FILTER (WHERE state = 'active') as active,
    count(*) FILTER (WHERE state = 'idle') as idle
FROM pg_stat_activity;

-- Índices no utilizados
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans
FROM pg_stat_user_indexes
WHERE idx_scan = 0;
```

---

### 🔐 **SEGURIDAD MULTI-TENANT**

```sql
-- Habilitar RLS en todas las tablas
ALTER TABLE negocios ENABLE ROW LEVEL SECURITY;
ALTER TABLE productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE ventas ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE creditos ENABLE ROW LEVEL SECURITY;
ALTER TABLE pagos_credito ENABLE ROW LEVEL SECURITY;
ALTER TABLE proveedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE compras ENABLE ROW LEVEL SECURITY;
ALTER TABLE caja ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimientos_inventario ENABLE ROW LEVEL SECURITY;
ALTER TABLE notificaciones ENABLE ROW LEVEL SECURITY;

-- Políticas automáticas por negocio
CREATE POLICY "users_access_own_business"
    ON negocios FOR ALL
    USING (user_id = current_setting('app.current_user_id', true)::UUID);

CREATE POLICY "business_access_own_products"
    ON productos FOR ALL
    USING (
        negocio_id IN (
            SELECT id FROM negocios 
            WHERE user_id = current_setting('app.current_user_id', true)::UUID
        )
    );

CREATE POLICY "business_access_own_sales"
    ON ventas FOR ALL
    USING (
        negocio_id IN (
            SELECT id FROM negocios 
            WHERE user_id = current_setting('app.current_user_id', true)::UUID
        )
    );

-- Aplicar similar para clientes, creditos, etc.
```

**Configurar sesión de usuario en Backend:**

```dart
// core/services/postgres_session_manager.dart
class PostgresSessionManager {
  static Future<void> setCurrentUser(PostgreSQLConnection conn, String userId) async {
    await conn.execute(
      "SET app.current_user_id = @userId",
      substitutionValues: {'userId': userId},
    );
  }
  
  static Future<void> clearCurrentUser(PostgreSQLConnection conn) async {
    await conn.execute("RESET app.current_user_id");
  }
}

// Uso en repositorios
final conn = await PostgresDataSource.getConnection();
await PostgresSessionManager.setCurrentUser(conn, currentUser.id);
// Ejecutar queries...
await PostgresSessionManager.clearCurrentUser(conn);
```

---

### 🎯 **RECOMENDACIÓN FINAL**

```
ARQUITECTURA PRODUCCIÓN RECOMENDADA:
─────────────────────────────────────────────────

✅ PostgreSQL Cloud: Railway o Neon
✅ Redis Cache: Upstash o Redis Cloud
✅ Storage: S3 o CloudFlare R2
✅ CDN: CloudFlare (Free)
✅ Monitoring: Grafana + Prometheus
✅ Backups: Automáticos diarios (retener 30 días)

COSTO ESTIMADO:
- Fase 1: $10-30/mes
- Fase 2: $50-150/mes
- Fase 3: $200-500/mes
- Fase 4: $1,000+/mes

ESCALABILIDAD:
- Hasta 1M usuarios con arquitectura correcta
- 99.9% uptime garantizado
- Backup y restore en < 15 minutos
```

---

## 🧪 TESTING EMPRESARIAL

```
test/
├── unit/                                  # Unit Tests
│   ├── domain/
│   │   ├── entities/
│   │   │   └── product_test.dart
│   │   └── usecases/
│   │       ├── get_products_usecase_test.dart
│   │       └── add_product_usecase_test.dart
│   │
│   ├── data/
│   │   ├── models/
│   │   │   └── product_model_test.dart
│   │   └── repositories/
│   │       └── product_repository_impl_test.dart
│   │
│   └── presentation/
│       └── providers/
│           └── product_provider_test.dart
│
├── widget/                                # Widget Tests
│   └── features/
│       ├── inventory/
│       │   └── product_card_test.dart
│       └── pos/
│           └── cart_item_test.dart
│
├── integration/                           # Integration Tests
│   ├── flows/
│   │   ├── onboarding_flow_test.dart
│   │   ├── sales_flow_test.dart
│   │   └── inventory_flow_test.dart
│   │
│   └── end_to_end/
│       └── complete_business_flow_test.dart
│
├── fixtures/                              # Test Data
│   ├── product_fixtures.dart
│   ├── sale_fixtures.dart
│   └── client_fixtures.dart
│
└── mocks/                                 # Mocks
    ├── mock_product_repository.dart
    ├── mock_product_datasource.dart
    └── mock_network_info.dart
```

**Ejemplo de Test Unitario:**
```dart
// test/unit/domain/usecases/get_products_usecase_test.dart

void main() {
  late GetProductsUseCase usecase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    usecase = GetProductsUseCase(mockRepository);
  });

  test('should get products from repository', () async {
    // arrange
    final businessId = 'business_123';
    final products = [
      Product(id: '1', name: 'Product 1', price: 10.0),
      Product(id: '2', name: 'Product 2', price: 20.0),
    ];
    when(mockRepository.getProducts(businessId))
        .thenAnswer((_) async => Right(products));

    // act
    final result = await usecase(businessId);

    // assert
    expect(result, Right(products));
    verify(mockRepository.getProducts(businessId));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Failure when businessId is empty', () async {
    // act
    final result = await usecase('');

    // assert
    expect(result, Left(ValidationFailure('Business ID required')));
    verifyZeroInteractions(mockRepository);
  });
}
```

---

## 🚀 DEVOPS & CI/CD

```
.github/
├── workflows/
│   ├── ci.yml                             # Continuous Integration
│   │   ├── Run linting
│   │   ├── Run unit tests
│   │   ├── Run widget tests
│   │   ├── Build APK
│   │   └── Code coverage report
│   │
│   ├── cd.yml                             # Continuous Deployment
│   │   ├── Build release
│   │   ├── Run tests
│   │   ├── Deploy to staging
│   │   ├── Deploy to production
│   │   └── Create release tag
│   │
│   └── auto-release.yml                   # Auto deployment
│
└── CODEOWNERS                              # Code reviewers
```

---

## 🔐 SEGURIDAD EMPRESARIAL

```dart
// Security Layers

1. Authentication
   - JWT tokens
   - Refresh tokens
   - Biometric auth
   - Session management

2. Authorization
   - Role-Based Access Control (RBAC)
   - Permissions per module
   - Row Level Security (RLS)

3. Data Protection
   - Encryption at rest
   - Encryption in transit (HTTPS)
   - Secure storage
   - Data masking

4. API Security
   - Rate limiting
   - API keys rotation
   - Request validation
   - SQL injection prevention
```

---

## 📊 MONITORIZACIÓN Y OBSERVABILIDAD

```dart
// Analytics & Monitoring

1. Logging
   - Winston/Pino structured logs
   - Log levels (debug, info, warn, error)
   - Cloud logging (CloudWatch, Datadog)

2. Metrics
   - API response times
   - Error rates
   - User actions
   - Performance metrics

3. Error Tracking
   - Sentry integration
   - Crash reports
   - Error aggregation

4. APM (Application Performance Monitoring)
   - New Relic
   - Datadog
   - Firebase Performance

5. Real-time Alerts
   - PagerDuty
   - Slack notifications
   - Email alerts
```

---

## 📈 MÉTRICAS DE CALIDAD

```yaml
Code Quality:
  - Test Coverage: > 80%
  - Code Complexity: < 10
  - Duplication: < 3%
  - Linter Errors: 0
  - Technical Debt: < 5%

Performance:
  - API Response: < 200ms
  - App Startup: < 2s
  - Memory Usage: < 200MB
  - Crash Rate: < 0.1%

Security:
  - Vulnerabilities: 0 (Critical/High)
  - Security Score: > 95%
  - Compliance: ISO 27001
  - Penetration Test: Quarterly

Uptime:
  - Availability: > 99.9%
  - MTTR: < 1h
  - MTBF: > 720h
```

---

## 🎯 COMPARACIÓN: ACTUAL vs EMPRESARIAL

| Aspecto | Actual | Empresarial |
|---------|--------|-------------|
| **Arquitectura** | Feature-based simple | Clean Architecture 3-capas |
| **State Management** | Provider básico | Provider + Use Cases |
| **Error Handling** | Try-catch simple | Either + Failures |
| **Testing** | Sin tests | 80%+ coverage |
| **DI** | Manual | GetIt/Injectable |
| **Offline** | No soportado | Offline-first |
| **Logging** | Print debug | Structured logging |
| **Monitoreo** | No | APM + Analytics |
| **CI/CD** | Manual | Automatizado |
| **Documentación** | Básica | Completa |

---

## 📋 CHECKLIST DE MIGRACIÓN

### ✅ **Fase 1: Fundación**
- [ ] Crear estructura de carpetas
- [ ] Setup Dependency Injection
- [ ] Implementar Error Handling
- [ ] Crear base de Use Cases
- [ ] Setup logging estructurado

### ✅ **Fase 2: Migración por Capas**
- [ ] Migrar Domain Layer (Entities, Use Cases)
- [ ] Migrar Data Layer (Repositories, Models)
- [ ] Migrar Presentation Layer (Providers, Pages)

### ✅ **Fase 3: Features**
- [ ] Migrar feature: Products
- [ ] Migrar feature: Sales
- [ ] Migrar feature: Inventory
- [ ] Migrar feature: Clients

### ✅ **Fase 4: Testing**
- [ ] Unit tests (> 80% coverage)
- [ ] Widget tests
- [ ] Integration tests

### ✅ **Fase 5: DevOps**
- [ ] Setup CI/CD
- [ ] Automatizar builds
- [ ] Setup monitorización
- [ ] Implementar alertas

---

## 🎓 BENEFICIOS EMPRESARIALES

### 🚀 **Escalabilidad**
- Crecimiento exponencial sin problemas
- Múltiples equipos trabajando en paralelo
- Microservicios-ready

### 🛠️ **Mantenibilidad**
- Código limpio y organizado
- Fácil onboarding de nuevos devs
- Refactoring seguro

### ✅ **Calidad**
- Tests exhaustivos
- Cero bugs críticos
- Performance optimizada

### 🔒 **Seguridad**
- Multiple layers de seguridad
- Compliance empresarial
- Auditoría completa

### 📊 **Observabilidad**
- Visibilidad total del sistema
- Alertas proactivas
- Data-driven decisions

---

*Este documento establece la estructura empresarial estándar para aplicaciones de alto nivel en producción.*

---

## 🔗 RECURSOS ADICIONALES

- Clean Architecture: Robert C. Martin
- Design Patterns: Gang of Four
- Testing: TDD, BDD, DDD
- SOLID Principles
- DevOps Best Practices
- Security Standards (OWASP)

