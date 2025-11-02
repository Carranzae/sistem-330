# 📱 Guía de Ejecución en Móviles (Android/iOS)

## ✅ Estado Actual

El proyecto está **100% configurado** para ejecutarse en móviles:

- ✅ **Android**: Configurado con permisos necesarios
- ✅ **iOS**: Configurado con permisos necesarios
- ✅ **Diseño Responsive**: Se adapta automáticamente a todos los tamaños de pantalla

---

## 🚀 Cómo Ejecutar en Android

### Opción 1: Emulador Android (RECOMENDADO)

**Tienes 4 emuladores disponibles:**

```powershell
# Desde la carpeta sistema/

# 1. Iniciar un emulador (elige uno):
flutter emulators --launch Pixel_8_Pro
# O
flutter emulators --launch Medium_Phone_API_36

# 2. Esperar a que inicie el emulador (30-60 segundos)

# 3. Ejecutar la app:
flutter run
# O específicamente:
flutter run -d Pixel_8_Pro
```

### Opción 2: Dispositivo Android Físico

```powershell
# 1. Conecta tu celular Android por USB
# 2. Activa "Modo Desarrollador" y "Depuración USB" en tu teléfono
# 3. Verifica que esté conectado:
flutter devices

# 4. Ejecuta la app:
flutter run -d android
```

---

## 🍎 Cómo Ejecutar en iOS

**NOTA:** Requiere Mac y Xcode instalado

```bash
# Desde la carpeta sistema/

# 1. Abrir Xcode y configurar el proyecto (solo primera vez)
open ios/Runner.xcworkspace

# 2. Ejecutar en simulador iOS:
flutter run -d ios

# O ejecutar en dispositivo físico iOS (requiere certificados)
flutter run -d <DEVICE_ID>
```

---

## 📐 Diseño Responsive Integrado

El sistema se adapta automáticamente a diferentes tamaños:

### 📱 Móvil (< 600px)
- **Sidebar**: Drawer lateral (menú deslizable)
- **Header**: Barra superior fija con botón hamburguesa
- **Navegación**: Tap en items del menú

### 📱 Tablet (600px - 1024px)
- **Sidebar**: Estrecho (80px) con solo iconos
- **Header**: Barra superior con nombre del negocio
- **Contenido**: Optimizado para pantalla grande

### 💻 Desktop (> 1024px)
- **Sidebar**: Completo (280px) con iconos y texto
- **Header**: Barra superior con notificaciones
- **Layout**: Diseño de escritorio profesional

---

## 🧪 Probar el Flujo Completo

### 1. Pantalla de Login
```powershell
flutter run
```
- Verás la pantalla de login con imagen
- Tap en "Empezar" para comenzar onboarding

### 2. Onboarding (6 Pasos)
1. **Datos del Negocio**: Nombre, RUC, dirección
2. **Seleccionar Categoría**: Elige uno de los 12 rubros
3. **Modelo de Negocio**: B2C, B2B o Híbrido
4. **Configuraciones**: Específicas según tu categoría
5. **Módulos Opcionales**: Funciones extra
6. **Confirmación**: Revisa y confirma

### 3. Dashboard Personalizado
- **Sidebar** con módulos según tu categoría
- **Dashboard** con métricas y gráficos
- Navegación fluida entre módulos

---

## 🔧 Solución de Problemas

### Error: "No Android device found"
```powershell
# Inicia un emulador primero
flutter emulators --launch Medium_Phone_API_36

# Espera a que termine de iniciar, luego:
flutter run
```

### Error: "Gradle sync failed"
```powershell
cd android
.\gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### La app se ve mal en tu dispositivo
- El diseño es responsive, se adapta automáticamente
- Reinicia la app con: `flutter run -d <DEVICE_ID>`

---

## 📦 Generar APK para Instalar

### APK de Debug (para pruebas)
```powershell
flutter build apk --debug
```
Archivo: `build/app/outputs/flutter-apk/app-debug.apk`

### APK de Release (para producción)
```powershell
flutter build apk --release
```
Archivo: `build/app/outputs/flutter-apk/app-release.apk`

### Instalar APK en tu celular
```powershell
# Conecta tu celular por USB y ejecuta:
flutter install
```

---

## 🌐 Comandos Útiles

```powershell
# Ver dispositivos conectados
flutter devices

# Ver emuladores disponibles
flutter emulators

# Limpiar cache
flutter clean
flutter pub get

# Rebuild completo
flutter clean && flutter pub get && flutter run

# Run en release mode (más rápido)
flutter run --release
```

---

## ✅ Checklist de Funcionalidades

### ✅ Implementado
- [x] Login responsive
- [x] Onboarding completo (6 pasos)
- [x] 12 categorías de negocios
- [x] Dashboard adaptativo
- [x] Sidebar responsive
- [x] Navegación entre módulos
- [x] Diseño móvil/tablet/desktop
- [x] Permisos Android/iOS configurados

### 🔄 Pendiente (Opcional)
- [ ] Conexión real con backend PostgreSQL
- [ ] Persistencia de datos
- [ ] Autenticación real
- [ ] Backend API

---

## 🎯 Próximos Pasos

1. **Ejecuta en emulador** para ver el flujo completo
2. **Prueba en dispositivo físico** para testing real
3. **Configura PostgreSQL** para guardar datos persistentes
4. **Personaliza colores** según tu marca

---

## 📞 Comandos Rápidos

```powershell
# Empezar emulador y app en una sola línea
flutter emulators --launch Pixel_8_Pro && flutter run

# Run en hot-reload mode (cambios en vivo)
flutter run -d android --hot

# Build release APK
flutter build apk --release
```

---

¡Tu app está lista para móviles! 🚀📱

