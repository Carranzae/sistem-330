# Sistema Multi-Negocio Inteligente

## 📋 Descripción
Este proyecto es un sistema de gestión multi-negocio diseñado para adaptarse automáticamente al tipo de negocio del usuario. Incluye un frontend desarrollado en **Flutter** y un backend en **Node.js** con **Supabase** como base de datos.

---

## 📂 Estructura del Proyecto

```
/workspaces/sistem-330/
├── backend/                # Backend en Node.js
│   ├── index.js            # Archivo principal del servidor
│   ├── package.json        # Dependencias del backend
│   └── .env                # Variables de entorno
├── sistema/                # Frontend en Flutter
│   ├── lib/                # Código fuente de Flutter
│   ├── pubspec.yaml        # Dependencias del frontend
│   └── assets/             # Recursos estáticos
└── README.md               # Documentación del proyecto
```

---

## 🚀 Configuración del Proyecto

### 1. Backend
#### Requisitos:
- Node.js (v18+)
- Supabase configurado con las tablas necesarias.

#### Instalación:
1. Navega al directorio del backend:
   ```bash
   cd backend
   ```
2. Instala las dependencias:
   ```bash
   npm install
   ```
3. Crea un archivo `.env` en el directorio `backend` con las siguientes variables:
   ```
   SUPABASE_URL=https://<TU_SUPABASE_URL>
   SUPABASE_ANON_KEY=<TU_SUPABASE_ANON_KEY>
   ```
4. Inicia el servidor:
   ```bash
   npm run dev
   ```

El servidor estará disponible en `http://localhost:3000`.

---

### 2. Frontend
#### Requisitos:
- Flutter SDK (v3.0+)

#### Instalación:
1. Navega al directorio del frontend:
   ```bash
   cd sistema
   ```
2. Instala las dependencias:
   ```bash
   flutter pub get
   ```
3. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

La aplicación se ejecutará en el emulador o dispositivo conectado.

---

## 🛠️ Funcionalidades

### Backend
- **Negocios**:
  - Crear y listar negocios.
- **Productos**:
  - Crear y listar productos.
- **Ventas**:
  - Registrar ventas y listar historial.
- **Clientes**:
  - Crear y listar clientes.

### Frontend
- **Onboarding**:
  - Registro de negocio y configuración específica por rubro.
- **POS**:
  - Punto de venta con carrito de compras.
- **Dashboard**:
  - Panel adaptativo según el rubro del negocio.

---

## 🗂️ Tablas en Supabase

### Tabla: `negocios`
```sql
CREATE TABLE negocios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre_comercial TEXT NOT NULL,
    ruc TEXT,
    pais TEXT NOT NULL,
    direccion_completa TEXT NOT NULL,
    rubro TEXT NOT NULL,
    modelo_negocio TEXT NOT NULL,
    configuracion JSONB,
    modulos_activos JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Tabla: `productos`
```sql
CREATE TABLE productos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    precio NUMERIC NOT NULL,
    stock INTEGER NOT NULL,
    atributos JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Tabla: `ventas`
```sql
CREATE TABLE ventas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID REFERENCES clientes(id),
    productos JSONB NOT NULL,
    total NUMERIC NOT NULL,
    metodo_pago TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Tabla: `clientes`
```sql
CREATE TABLE clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre_completo TEXT NOT NULL,
    tipo_documento TEXT,
    numero_documento TEXT,
    telefono TEXT,
    email TEXT,
    direccion TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 🌐 Endpoints del Backend

### Negocios
- **GET** `/api/businesses`: Listar negocios.
- **POST** `/api/businesses`: Crear un negocio.

### Productos
- **GET** `/api/products`: Listar productos.
- **POST** `/api/products`: Crear un producto.

### Ventas
- **GET** `/api/sales`: Listar ventas.
- **POST** `/api/sales`: Registrar una venta.

### Clientes
- **GET** `/api/clients`: Listar clientes.
- **POST** `/api/clients`: Crear un cliente.

---

## 🧪 Testing

### Backend
1. Usa herramientas como **Postman** o **cURL** para probar los endpoints.
2. Verifica que las respuestas sean correctas y que los datos se guarden en Supabase.

### Frontend
1. Ejecuta la aplicación en un emulador o dispositivo físico.
2. Prueba los flujos principales:
   - Registro de negocio.
   - Punto de venta.
   - Dashboard.

---

## 📞 Soporte
Si tienes preguntas o problemas, contacta al equipo de desarrollo.

///
# 📋 PROMPT PARA DESARROLLO DE SOFTWARE MULTI-NEGOCIO

## 🎯 OBJETIVO PRINCIPAL
Desarrolla una aplicación móvil (Android/iOS) usando **Flutter** para un sistema de gestión multi-negocio inteligente que se adapta automáticamente al tipo de negocio del usuario peruano.

---

## 📱 ESPECIFICACIONES TÉCNICAS

### Stack Tecnológico OBLIGATORIO
- **Framework:** Flutter (Dart)
- **Backend:** Supabase (PostgreSQL + Auth + Storage + Realtime)
- **Base de datos:** PostgreSQL con JSONB para configuraciones dinámicas
- **Autenticación:** Supabase Auth (Email/Password + OAuth: Google, Apple, Facebook)
- **Almacenamiento:** Supabase Storage para imágenes (logos, productos)
- **Estado:** Provider o Riverpod
- **Navegación:** GoRouter o Navigator 2.0

### Plataformas Soportadas
- ✅ Android (minSDK 21)
- ✅ iOS (iOS 12+)

---

## 🚀 FASE 1: ONBOARDING INTELIGENTE (PRIORIDAD MÁXIMA)

### PASO 1: Pantalla de Autenticación
```dart
// Componentes necesarios:
- TextField para email
- TextField para contraseña (obscureText: true)
- Botón "Registrarme"
- Divisor visual "O continuar con"
- Botones de OAuth: Google, Apple (iOS), Facebook
- Validación de email en tiempo real
- Manejo de errores de Supabase
```

**Funcionalidad:**
- Crear usuario en `auth.users` de Supabase
- Redirigir a PASO 2 al completar registro exitoso

---

### PASO 2: Datos del Negocio
```dart
// Formulario con campos:
- TextField: Nombre comercial (obligatorio)
- TextField: RUC (opcional, 11 dígitos)
- Botón: Buscar en API SUNAT (si tiene RUC, autocompletar datos)
- ImagePicker: Logo del negocio (opcional)
- Dropdown: País (default: Perú)
- Dropdown en cascada: Departamento → Provincia → Distrito
- TextField: Dirección exacta
- Dropdown: Moneda (default: PEN - S/)
```

**Datos a guardar en tabla `negocios`:**
```sql
nombre_comercial, ruc, logo_url, pais, departamento, 
provincia, distrito, direccion_completa, moneda
```

---

### PASO 3: Selección de Rubro (LA PREGUNTA CLAVE)
```dart
// Grid de Cards interactivos con:
- Icono representativo del rubro
- Nombre del rubro
- Selección única (radio button)

// Lista de rubros:
1. 🛒 Abarrotes / Bodega
2. 👗 Ropa, Calzado y Accesorios
3. 🏠 Hogar y Decoración
4. 📱 Electrónica y Tecnología
5. 🥦 Verdulería / Frutas
6. 🥔 Venta de Papa / Tubérculos
7. 🍖 Carnicería / Pollería
8. 🔧 Ferretería / Construcción
9. 💊 Farmacia / Botica
10. 🍕 Restaurante / Comida
11. 📦 Mayorista / Distribuidor
12. 🏪 Otro / General
```

**Guardar en campo:** `negocios.rubro`

---

### PASO 4: Modelo de Negocio
```dart
// RadioListTile con 3 opciones:

1. ( ) B2C - Al por MENOR
   Descripción: "Vendes directo al consumidor final"
   Ejemplo: "Cliente entra a tu tienda y compra"

2. ( ) B2B - Al por MAYOR  
   Descripción: "Vendes a otras empresas/revendedores"
   Ejemplo: "Vendes sacos de papa a bodegas"

3. ( ) HIBRIDO - AMBOS
   Descripción: "Tienes clientes finales Y mayoristas"
```

**Guardar en campo:** `negocios.modelo_negocio`

---

### PASO 5: Configuración Específica por Rubro

**Implementar lógica condicional:**

```dart
// Si rubro == 'abarrotes':
- [✓] Manejo productos con fecha de vencimiento
- [✓] Uso lector de códigos de barra
- [ ] Vendo a crédito (fío)
- [ ] Recibo pagos con Yape/Plin

// Si rubro == 'ropa_calzado':
- [✓] Manejo tallas y colores
- [ ] Quiero vender en marketplace online
- [ ] Vendo por temporada (colecciones)
- [ ] Recibo pagos con Yape/Plin

// Si rubro == 'papa_mayorista':
- [✓] Vendo por peso (Kg/Sacos/Toneladas)
- [✓] Manejo cuentas por cobrar (crédito)
- [✓] Tengo proveedores fijos
- [ ] Recibo pagos con Yape/Plin

// Si rubro == 'electronica':
- [✓] Registro números de serie/IMEI
- [✓] Control de garantías
- [ ] Servicio técnico
- [ ] Marketplace online

// Si rubro == 'verduleria':
- [✓] Venta por peso
- [✓] Control de frescura/vencimientos
- [✓] Registro de mermas
- [ ] Pedidos a proveedores
```

**Guardar en campo JSONB:** `negocios.configuracion`

---

### PASO 6: Módulos Opcionales (Monetización)
```dart
// CheckboxListTile para cada módulo:

[ ] 📄 Facturación Electrónica SUNAT
    Precio: S/ 29/mes | 14 días gratis
    
[ ] 💳 Integración Yape/Plin
    Precio: S/ 19/mes | 14 días gratis
    
[ ] 🚚 Control de Delivery
    Precio: S/ 15/mes | 14 días gratis
    
[ ] 👥 Multi-usuario/Empleados
    Precio: S/ 25/mes | Hasta 5 usuarios
    
[ ] 🛒 Marketplace/Tienda Online
    Precio: S/ 39/mes | Solo B2C
```

**Guardar en campo JSONB:** `negocios.modulos_activos`

---

### PASO 7: Pantalla de Confirmación
```dart
// Mostrar resumen:
✅ Negocio: [nombre_comercial]
✅ Rubro: [rubro]
✅ Modelo: [B2C/B2B/HIBRIDO]
✅ Configuraciones activas: [lista]
✅ Módulos opcionales: [lista]

// Botón: [Ir al Dashboard →]
```

---

## 📊 FASE 2: DASHBOARD DINÁMICO (CORE)

### Lógica de Adaptación
```dart
// El dashboard debe cambiar según:
1. negocios.rubro
2. negocios.modelo_negocio  
3. negocios.configuracion
4. negocios.modulos_activos

// Ejemplo de widgets condicionales:
if (configuracion['maneja_vencimientos'] == true) {
  mostrar_widget_productos_por_vencer();
}

if (modelo_negocio == 'B2B' || modelo_negocio == 'HIBRIDO') {
  mostrar_widget_cuentas_por_cobrar();
}

if (modulos_activos['marketplace'] == true) {
  mostrar_widget_pedidos_online();
}
```

### Widgets del Dashboard (Adaptativos)

#### 1️⃣ Header Superior
```dart
- Avatar del negocio (logo)
- Nombre del negocio
- Botón de notificaciones
- Botón de configuración
```

#### 2️⃣ Tarjeta de Ventas del Día
```dart
// Para TODOS los rubros:
- Ventas de hoy: S/ XXX.XX
- Meta diaria: S/ XXX.XX (%)
- Productos vendidos: X
- Gráfico de barras simple
```

#### 3️⃣ Widgets Condicionales por Rubro

**Si rubro == 'abarrotes':**
```dart
Widget: Productos por Vencer (próximos 7 días)
- Lista de productos con:
  • Nombre del producto
  • Cantidad
  • Fecha de vencimiento (color rojo si ≤3 días)
```

**Si rubro == 'ropa_calzado':**
```dart
Widget: Productos Más Vendidos Hoy
- Lista con:
  • Nombre del producto
  • Talla/Color
  • Unidades vendidas
  • Foto miniatura
```

**Si rubro == 'papa_mayorista' o modelo == 'B2B':**
```dart
Widget: Cuentas por Cobrar Urgentes
- Lista de clientes con deuda próxima a vencer:
  • Nombre del cliente
  • Monto: S/ XXX
  • Vence: [fecha]
  • Botón: [Cobrar ahora]
```

**Si configuracion['venta_por_peso'] == true:**
```dart
Widget: Peso Vendido Hoy
- Total en Kg/Ton vendidos hoy
- Comparación con ayer
```

#### 4️⃣ Widget de Stock Bajo (TODOS)
```dart
- Lista de productos con stock ≤ stock_minimo
- Mostrar:
  • Nombre del producto
  • Stock actual
  • Stock mínimo
  • Botón: [Reabastecer]
```

#### 5️⃣ Botones de Acción Rápida
```dart
// Siempre visibles:
- [🛍️ Nueva Venta] → POS
- [📦 Inventario]
- [💰 Caja]
- [📈 Reportes]

// Condicionales:
if (modulos_activos['marketplace']) {
  - [🛒 Pedidos Online]
}

if (modelo_negocio == 'B2B' || modelo_negocio == 'HIBRIDO') {
  - [💵 Cuentas por Cobrar]
}

if (configuracion['maneja_proveedores']) {
  - [🚚 Proveedores]
}
```

---

## 🛍️ FASE 3: MÓDULO POS (PUNTO DE VENTA)

### Pantalla Principal del POS
```dart
// Layout en 2 columnas (tablet) o vertical (móvil):

// COLUMNA IZQUIERDA: Búsqueda y Productos
- TextField: Buscar por nombre/código
- Botón: Lector de código de barras (si configurado)
- Grid de productos (Cards con):
  • Foto del producto
  • Nombre
  • Precio
  • Stock disponible
  • Botón [+] para agregar

// COLUMNA DERECHA: Carrito de Venta
- Lista de productos agregados:
  • Nombre
  • Cantidad (+ / -)
  • Precio unitario
  • Subtotal
  • Botón [X] eliminar

- Resumen:
  • Subtotal: S/ XXX
  • IGV (18%): S/ XXX
  • Descuento: S/ XXX
  • TOTAL: S/ XXX

- Selector de cliente (si B2B o venta a crédito)
- Selector de método de pago:
  • Efectivo
  • Yape
  • Plin
  • Tarjeta
  • Crédito (si activado)

- Botón grande: [COBRAR S/ XXX]
```

### Lógica Especial por Rubro

**Si venta_por_peso == true:**
```dart
// Al agregar producto, mostrar diálogo:
- TextField: Peso en Kg
- Calcular precio: peso * precio_por_kg
```

**Si maneja_tallas_colores == true:**
```dart
// Al agregar producto, mostrar diálogo:
- Dropdown: Seleccionar talla
- ColorPicker: Seleccionar color
- Validar stock por variante
```

**Si maneja_garantias == true:**
```dart
// Para electrónica:
- Al vender, registrar:
  • Número de serie/IMEI
  • Fecha de compra
  • Duración de garantía (meses)
```

### Flujo de Cobro
```dart
1. Usuario presiona [COBRAR]
2. Si método == 'EFECTIVO':
   - Mostrar diálogo: "¿Con cuánto paga?"
   - Calcular vuelto
3. Si método == 'YAPE' o 'PLIN':
   - Mostrar QR del negocio
   - Esperar confirmación manual
   - (Si módulo Yape activo: detectar notificación automáticamente)
4. Si método == 'CREDITO':
   - Validar que cliente esté seleccionado
   - Registrar deuda en tabla cuentas_por_cobrar
5. Generar comprobante:
   - Si facturación_electronica == true: Boleta/Factura SUNAT
   - Sino: Ticket simple
6. Imprimir (opcional) o enviar por WhatsApp
7. Actualizar stock de productos
8. Registrar venta en tabla ventas
9. Actualizar caja
10. Mostrar pantalla de éxito
```

---

## 📦 FASE 4: MÓDULO INVENTARIO

### Pantalla Lista de Productos
```dart
// Header:
- TextField: Buscar producto
- Dropdown: Filtrar por categoría
- Botón: [+ Agregar Producto]

// Lista de productos (ListView o DataTable):
- Columnas:
  • Código
  • Nombre
  • Categoría
  • Stock actual
  • Precio venta
  • Acciones: [Ver] [Editar] [Eliminar]

// Indicadores visuales:
- Stock bajo: fondo amarillo
- Sin stock: fondo rojo
- Producto próximo a vencer: ícono ⚠️ (si aplica)
```

### Formulario Agregar/Editar Producto

**Campos Base (TODOS):**
```dart
- TextField: Código/SKU (autogenerado o manual)
- TextField: Nombre del producto
- TextField: Descripción
- Dropdown: Categoría
- NumberField: Precio de compra
- NumberField: Precio de venta
- NumberField: Stock inicial
- NumberField: Stock mínimo (para alertas)
- Dropdown: Unidad de medida (UND, KG, LT, SACO, etc.)
- ImagePicker: Fotos del producto (múltiples)
```

**Campos Dinámicos por Rubro:**

```dart
// Si rubro == 'ropa_calzado':
+ TextField: Talla (S, M, L, XL)
+ ColorPicker: Color
+ TextField: Material
+ TextField: Marca
+ Checkbox: ¿Crear variantes automáticamente?

// Si rubro == 'abarrotes':
+ DatePicker: Fecha de vencimiento
+ TextField: Número de lote
+ TextField: Código de barras (EAN-13)
+ Checkbox: ¿Habilitar lector de código?

// Si rubro == 'papa_mayorista':
+ NumberField: Peso por saco/unidad (Kg)
+ Dropdown: Calidad (Primera, Segunda, Tercera)
+ TextField: Origen/Procedencia
+ DatePicker: Fecha de cosecha

// Si rubro == 'electronica':
+ TextField: Número de serie/IMEI
+ NumberField: Garantía (meses)
+ TextField: Marca
+ TextField: Modelo
+ Checkbox: ¿Requiere servicio técnico?

// Si rubro == 'verduleria':
+ DatePicker: Fecha de ingreso
+ NumberField: Días de frescura estimada
+ Checkbox: ¿Producto perecible?
```

**Guardar en:** `productos.atributos` (JSONB)

---

## 💰 FASE 5: MÓDULO CAJA

### Pantalla de Caja
```dart
// Estado de Caja:
- Indicador: [ABIERTA] o [CERRADA]
- Saldo actual: S/ XXX.XX
- Fecha/hora de apertura

// Si caja CERRADA:
- Botón grande: [ABRIR CAJA]
- Diálogo al abrir:
  • Monto inicial: S/ ___
  • Usuario responsable: [Dropdown]
  • Botón: [Confirmar Apertura]

// Si caja ABIERTA:

### Tabs:
1. Movimientos del Día
2. Ingresos
3. Egresos
4. Cerrar Caja

### Tab 1: Movimientos del Día
- Lista de todas las transacciones:
  • Hora
  • Tipo (Venta, Ingreso, Egreso)
  • Descripción
  • Monto
  • Método de pago
- Total en caja: S/ XXX
```

### Tab 2: Registrar Ingreso
```dart
- NumberField: Monto
- TextField: Concepto/Descripción
- Dropdown: Categoría (Venta, Préstamo, Otros)
- Botón: [Registrar Ingreso]
```

### Tab 3: Registrar Egreso
```dart
- NumberField: Monto
- TextField: Concepto/Descripción  
- Dropdown: Categoría (Compra, Pago proveedor, Gasto, Otros)
- ImagePicker: Foto del comprobante (opcional)
- Botón: [Registrar Egreso]
```

### Tab 4: Cerrar Caja
```dart
// Resumen del día:
- Saldo inicial: S/ XXX
- Total ingresos: S/ XXX
- Total egresos: S/ XXX
- Saldo esperado: S/ XXX

// Conteo físico:
- Billetes de S/ 200: [___]
- Billetes de S/ 100: [___]
- Billetes de S/ 50: [___]
- Billetes de S/ 20: [___]
- Billetes de S/ 10: [___]
- Monedas: [___]
- Total contado: S/ XXX

// Diferencia:
- Sobrante/Faltante: S/ XXX (rojo si falta)

// Botón: [CERRAR CAJA]
- Confirmar cierre
- Generar reporte PDF
- Enviar por email (opcional)
```

---

## 📈 FASE 6: MÓDULO REPORTES

### Pantalla de Reportes
```dart
// Selector de rango de fechas:
- DateRangePicker: Desde - Hasta
- Botones rápidos: [Hoy] [Ayer] [Esta semana] [Este mes]

// Grid de tarjetas de reportes:
```

### Reportes Básicos (TODOS)
```dart
1. 📊 Ventas por Período
   - Gráfico de líneas/barras
   - Total vendido: S/ XXX
   - Productos vendidos: X unidades
   - Ticket promedio: S/ XXX
   - Botón: [Descargar PDF] [Compartir]

2. 💰 Utilidades
   - Costo total: S/ XXX
   - Ingreso total: S/ XXX
   - Utilidad bruta: S/ XXX
   - Margen: XX%

3. 📦 Productos Más Vendidos
   - Ranking top 10:
     • Nombre
     • Unidades vendidas
     • Ingreso generado

4. 📉 Productos con Poco Movimiento
   - Lista de productos que no se venden
   - Sugerencia: Crear promoción o descontinuar
```

### Reportes Específicos por Rubro

**Si rubro == 'abarrotes':**
```dart
5. 📅 Productos Próximos a Vencer
   - Lista con fecha de vencimiento
   - Valor en stock en riesgo
   - Sugerencia: Precio promocional
```

**Si modelo == 'B2B' o 'HIBRIDO':**
```dart
6. 💵 Cuentas por Cobrar
   - Total por cobrar: S/ XXX
   - Vencidas: S/ XXX
   - Por vencer (7 días): S/ XXX
   - Lista de clientes morosos
```

**Si configuracion['maneja_proveedores']:**
```dart
7. 🚚 Cuentas por Pagar
   - Total por pagar: S/ XXX
   - Próximos pagos (15 días)
   - Lista de proveedores
```

---

## 👥 FASE 7: MÓDULO CLIENTES (Si B2B o Venta a Crédito)

### Tabla: clientes
```sql
CREATE TABLE clientes (
    id UUID PRIMARY KEY,
    negocio_id UUID REFERENCES negocios,
    
    -- Datos básicos
    tipo_documento VARCHAR(20), -- DNI, RUC, CE
    numero_documento VARCHAR(20),
    nombre_completo VARCHAR(255),
    razon_social VARCHAR(255), -- Si es RUC
    
    -- Contacto
    telefono VARCHAR(20),
    email VARCHAR(255),
    direccion TEXT,
    
    -- Financiero (si vende a crédito)
    limite_credito DECIMAL(10,2) DEFAULT 0,
    credito_usado DECIMAL(10,2) DEFAULT 0,
    credito_disponible DECIMAL(10,2) DEFAULT 0,
    
    -- Estadísticas
    total_compras DECIMAL(10,2) DEFAULT 0,
    ultima_compra TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Funcionalidades
```dart
- Lista de clientes
- Agregar/Editar cliente
- Ver historial de compras
- Ver deudas pendientes
- Botón: [Cobrar deuda]
- Botón: [WhatsApp]
```

---

## 🚚 FASE 8: MÓDULO PROVEEDORES

### Tabla: proveedores
```sql
CREATE TABLE proveedores (
    id UUID PRIMARY KEY,
    negocio_id UUID REFERENCES negocios,
    
    -- Datos básicos
    ruc VARCHAR(11),
    razon_social VARCHAR(255),
    nombre_contacto VARCHAR(255),
    
    -- Contacto
    telefono VARCHAR(20),
    email VARCHAR(255),
    direccion TEXT,
    
    -- Financiero
    dias_credito INTEGER DEFAULT 0, -- Días que te da de crédito
    monto_deuda DECIMAL(10,2) DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Funcionalidades
```dart
- Lista de proveedores
- Agregar/Editar proveedor
- Registrar compras/pedidos
- Ver deudas pendientes
- Botón: [Nuevo pedido]
```

---

## 💳 FASE 9: INTEGRACIÓN YAPE/PLIN (MÓDULO OPCIONAL)

### Tabla: pagos_digitales
```sql
CREATE TABLE pagos_digitales (
    id UUID PRIMARY KEY,
    negocio_id UUID REFERENCES negocios,
    
    -- Datos del pago
    plataforma VARCHAR(20), -- YAPE, PLIN
    monto DECIMAL(10,2),
    fecha_hora TIMESTAMPTZ,
    numero_operacion VARCHAR(50),
    nombre_remitente VARCHAR(255),
    
    -- Conciliación
    estado VARCHAR(20), -- PENDIENTE, ASOCIADO, RECHAZADO
    venta_id UUID REFERENCES ventas,
    
    -- Metadata
    notificacion_raw JSONB,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Implementación Android
```dart
// 1. Solicitar permisos:
<uses-permission android:name="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"/>

// 2. Crear NotificationListenerService:
class YapePlInListenerService extends NotificationListenerService {
  @override
  void onNotificationPosted(StatusBarNotification sbn) {
    // Filtrar notificaciones de Yape/Plin:
    if (sbn.packageName == 'com.yape' || sbn.packageName == 'com.plin') {
      // Extraer datos:
      String titulo = sbn.notification.extras.getString("android.title");
      String texto = sbn.notification.extras.getString("android.text");
      
      // Parsear monto y remitente
      // Enviar a Supabase
    }
  }
}

// 3. Pantalla de Conciliación:
- Lista de pagos Yape/Plin sin asociar
- Por cada pago:
  • Monto: S/ XX
  • De: [Nombre]
  • Fecha: [fecha]
  • Botón: [Asociar a venta]
    → Buscar venta pendiente con monto igual
    → Asociar y marcar como pagada
```

### Implementación iOS
```dart
// iOS no permite Notification Listener
// Alternativa: Shortcuts + Automation

// 1. El usuario debe crear un Shortcut manual
// 2. Configurar: "Cuando reciba notificación de Yape"
// 3. Ejecutar: "Enviar datos a webhook de la app"
// 4. La app recibe el webhook y procesa el pago

// Instrucciones dentro de la app:
- Video tutorial paso a paso
- Link a guía de configuración
```

---

## 📄 FASE 10: FACTURACIÓN ELECTRÓNICA SUNAT (MÓDULO OPCIONAL)

### Requisitos Previos
```dart
// El usuario debe tener:
1. Certificado digital (.pfx)
2. Clave SOL de SUNAT
3. RUC del negocio

// Guardar en tabla negocios:
- certificado_digital_url (Supabase Storage)
- clave_sol_encrypted (cifrado)
- sunat_usuario
- sunat_endpoint (producción o beta)
```

### Tabla: comprobantes_electronicos
```sql
CREATE TABLE comprobantes_electronicos (
    id UUID PRIMARY KEY,
    negocio_id UUID REFERENCES negocios,
    venta_id UUID REFERENCES ventas,
    
    -- Tipo de comprobante
    tipo VARCHAR(20), -- BOLETA, FACTURA, NOTA_CREDITO, NOTA_DEBITO
    serie VARCHAR(4), -- B001, F001
    correlativo INTEGER,
    
    -- Datos SUNAT
    xml_firmado TEXT,
    xml_respuesta_sunat TEXT,
    codigo_hash VARCHAR(255),
    codigo_qr TEXT,
    
    -- Estado
    estado VARCHAR(20), -- GENERADO, ENVIADO, ACEPTADO, RECHAZADO
    mensaje_sunat TEXT,
    
    -- PDF
    pdf_url TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Flujo de Emisión
```dart
1. Después de cobrar venta, preguntar:
   "¿Desea comprobante electrónico?"
   [ ] Boleta
   [ ] Factura
   [ ] Ticket (sin valor tributario)

2. Si eligió Boleta/Factura:
   - Solicitar DNI/RUC del cliente
   - Buscar en API SUNAT (si es RUC)
   - Validar datos

3. Generar XML según formato SUNAT 2.1
4. Firmar XML con certificado digital
5. Enviar a SUNAT vía API REST
6. Recibir CDR (Constancia de Recepción)
7. Generar PDF con QR
8. Enviar por email/WhatsApp al cliente
9. Guardar en base de datos

// Usar paquete:
// - xml (para generar XML)
// - pointycastle (para firmar)
// - http (para enviar a SUNAT)
```

---

## 🛒 FASE 11: MARKETPLACE/TIENDA ONLINE (MÓDULO OPCIONAL)

### Funcionalidades
```dart
1. Subdominio personalizado:
   - tunegocio.omnitienda.pe
   - Configuración automática en Supabase Edge Functions

2. Catálogo Público:
   - Lista de productos con fotos
   - Búsqueda y filtros
   - Carrito de compras

3. Pedidos Online:
   - Cliente selecciona productos
   - Elige: Recojo en tienda o Delivery
   - Paga: Yape/Plin/Transferencia (sin pasarela)
   - Envía comprobante de pago
   
4. Panel Admin (dentro de la app):
   - Ver pedidos pendientes
   - Aprobar pago (después de verificar)
   - Marcar como "Listo para recoger" o "Enviado"
   - Notificar al cliente por WhatsApp/SMS

5. Integración con Redes Sociales:
   - Compartir catálogo en Facebook/Instagram
   - Botón "Comprar por WhatsApp"
```

---

## 🔐 FASE 12: SEGURIDAD Y PERMISOS

### Row Level Security (RLS) en Supabase
```sql
-- Política: Solo el dueño puede ver su negocio
CREATE POLICY "Usuarios solo ven su negocio"
ON negocios FOR SELECT
USING (auth.uid() = user_id);

-- Política: Solo el dueño puede ver productos de su negocio
CREATE POLICY "Usuarios solo ven productos de su negocio"
ON productos FOR ALL
USING (negocio_id IN (
  SELECT id FROM negocios WHERE user_id = auth.uid()
));

-- Aplicar a todas las tablas
```

### Multi-Usuario (Si módulo activo)
```dart
// Tabla: usuarios
CREATE TABLE usuarios (
    id UUID PRIMARY KEY,
    negocio_id UUID REFERENCES negocios,
    auth_uid UUID REFERENCES auth.users,
    
    -- Datos
    nombre VARCHAR(255),
    email VARCHAR(255),
    telefono VARCHAR(20),
    
    -- Rol
    rol VARCHAR(20), -- ADMIN, VENDEDOR, ALMACENERO, CONTADOR
    
    -- Permisos específicos
    permisos JSONB DEFAULT '{
        "ver_ventas": true,
        "crear_ventas": true,
        "editar_productos": false,
        "ver_reportes": false,
        "acceder_caja": false
    }'::jsonb,
    
    -- Control
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

// Lógica en la app:
- Al iniciar sesión, verificar rol del usuario
- Mostrar/ocultar módulos según permisos
- Validar permisos en cada acción
```

---

## 📱 DISEÑO UI/UX

### Paleta de Colores
```dart
// Colores principales:
- Primary: #2563EB (Azul profesional)
- Secondary: #10B981 (Verde éxito)
- Accent: #F59E0B (Naranja llamada a acción)
- Error: #EF4444 (Rojo alertas)
- Background: #F9FAFB (Gris claro)
- Surface: #FFFFFF (Blanco)
- Text: #1F2937 (Gris oscuro)
```

### Tipografía
```dart
- Font: 'Inter' o 'Poppins'
- Tamaños:
  • Título: 24px, bold
  • Subtítulo: 18px, semibold
  • Cuerpo: 16px, regular
  • Pequeño: 14px, regular
```

### Iconos
```dart
// Usar paquete: flutter_icons o lucide_icons
- Consistencia en todos los módulos
- Iconos outline (no filled)
```

### Componentes Reutilizables
```dart
1. CustomButton
2. CustomTextField
3. CustomCard
4. ProductCard
5. LoadingIndicator
6. EmptyState
7. ErrorState
8. SuccessDialog
9. ConfirmDialog
10. CustomAppBar
```

---

## 🧪 TESTING

### Prioridades de Testing
```dart
1. Autenticación (login/registro)
2. Onboarding completo
3. POS - Flujo de venta
4. Inventario - CRUD productos
5. Caja - Apertura/Cierre
6. Reportes - Generación correcta
7. Integración Yape (si aplica)
```

---

## 📦 ENTREGABLES

### Lo que DEBES entregar:
```
1. ✅ Código fuente completo (Flutter)
2. ✅ Proyecto Supabase configurado:
   - Schema de base de datos (.sql)
   - Políticas RLS
   - Edge Functions (si aplica)
3. ✅ Documentación técnica:
   - Arquitectura del sistema
   - Diagrama de base de datos
   - Flujos principales
4. ✅ APK para testing (Android)
5. ✅ Guía de despliegue
6. ✅ Video demo (5-10 min) mostrando:
   - Onboarding completo
   - Venta en POS
   - Gestión de inventario
   - Dashboard adaptativo
```

---

## ⚠️ CONSIDERACIONES IMPORTANTES

### 1. Prioriza Funcionalidad sobre Estética
- Primero que funcione bien
- Luego que se vea bien

### 2. Usa Packages Confiables
```yaml
dependencies:
  supabase_flutter: ^latest
  provider: ^latest
  go_router: ^latest
  image_picker: ^latest
  barcode_scan2: ^latest
  pdf: ^latest
  printing: ^latest
  intl: ^latest
  flutter_svg: ^latest
```

### 3. Manejo de Errores
- SIEMPRE usar try-catch
- Mostrar mensajes de error amigables
- No dejar que la app crashee

### 4. Offline First (Opcional pero Recomendado)
- Usar sqflite para cache local
- Sincronizar cuando haya internet
- Ideal para zonas con mala conexión

### 5. Notificaciones
- Stock bajo
- Productos por vencer
- Pagos Yape/Plin recibidos
- Pedidos online nuevos

---

## 🚀 PLAN DE DESARROLLO SUGERIDO

### SPRINT 1 (2 semanas): Fundación
- [ ] Setup proyecto Flutter + Supabase
- [ ] Diseño de base de datos
- [ ] Sistema de autenticación
- [ ] Onboarding completo (7 pasos)

### SPRINT 2 (2 semanas): Core
- [ ] Dashboard adaptativo
- [ ] Módulo POS básico
- [ ] Módulo Inventario (CRUD)

### SPRINT 3 (2 semanas): Gestión
- [ ] Módulo Caja
- [ ] Módulo Clientes
- [ ] Módulo Proveedores

### SPRINT 4 (2 semanas): Reportes y Pulido
- [ ] Módulo Reportes
- [ ] Generación de PDFs
- [ ] Testing exhaustivo

### SPRINT 5 (2 semanas): Módulos Opcionales
- [ ] Integración Yape/Plin
- [ ] Facturación SUNAT (básico)
- [ ] Marketplace (básico)

---

## 📞 NOTAS FINALES

- **Pregunta si algo no está claro** antes de empezar a codear
- **Commit frecuente** (cada funcionalidad nueva)
- **Comenta el código** en español para facilitar mantenimiento
- **No reinventes la rueda**: usa packages existentes
- **Piensa en escalabilidad**: el sistema crecerá

¡ÉXITO CON EL DESARROLLO! 🚀