# 📱 INSTRUCCIONES PARA EJECUTAR EN MÓVIL

## ✅ Tu Proyecto Está 100% Listo para Móviles

El sistema está **completamente configurado** para Android e iOS con diseño responsive.

---

## 🚀 CÓMO EJECUTAR (3 PASOS)

### PASO 1: Abre una Terminal

```powershell
# Navega a la carpeta del proyecto
cd C:\Users\auner\Desktop\SYSTEM_MULTI_NEGOCIO\sistem-330\sistema
```

### PASO 2: Inicia un Emulador Android

Tienes 4 emuladores disponibles:

```powershell
flutter emulators --launch Pixel_8_Pro
```

O si prefieres un teléfono más pequeño:
```powershell
flutter emulators --launch Medium_Phone_API_36
```

**Espera** 30-60 segundos a que inicie el emulador.

### PASO 3: Ejecuta la App

```powershell
flutter run
```

¡Listo! La app se abrirá en el emulador.

---

## 📱 LO QUE VERÁS

### 1. Pantalla de Login
- Imagen de la mujer profesional
- Botón "**Empezar**" → Para registro nuevo
- Botón "Ya tengo cuenta" → Para login

### 2. Onboarding (6 Pasos)
Al hacer click en "Empezar":

**Paso 1:** Datos del Negocio
- Nombre comercial
- RUC (opcional)
- País, dirección

**Paso 2:** Selecciona tu Categoría
- 12 opciones disponibles
- Cada una con su color e icono

**Paso 3:** Modelo de Negocio
- Al por menor (B2C)
- Al por mayor (B2B)
- Híbrido (ambos)

**Paso 4:** Configuraciones
- Opciones específicas según tu categoría

**Paso 5:** Módulos Opcionales
- Funciones extra (opcional)

**Paso 6:** Confirmación
- Revisa tus datos
- Click en "Ir al Dashboard"

### 3. Dashboard Personalizado
**Sidebar Izquierdo** con:
- Dashboard
- Punto de Venta (POS)
- Inventario
- Clientes
- Caja
- Reportes
- Módulos específicos según tu categoría

**Header Superior** con:
- Nombre de tu negocio
- Categoría
- Notificaciones
- Perfil

---

## 🎨 DISEÑO RESPONSIVE

La app se adapta automáticamente:

### 📱 Teléfono (< 600px)
- Sidebar oculto (menú hamburguesa)
- Contenido a pantalla completa
- Navegación táctil optimizada

### 📱 Tablet (600px - 1024px)
- Sidebar estrecho con iconos
- Más espacio para contenido
- Diseño intermedio

### 💻 Escritorio (> 1024px)
- Sidebar completo con texto
- Layout de oficina
- Máxima productividad

---

## 🧪 PROBAR EN TU CELULAR REAL

### Android:

1. **Conecta tu celular** por USB
2. **Activa "Modo Desarrollador"**:
   - Ve a Ajustes → Acerca del teléfono
   - Toca "Número de compilación" 7 veces
3. **Activa "Depuración USB"**:
   - Ve a Ajustes → Opciones de desarrollador
   - Activa "Depuración USB"
4. **Ejecuta**:
   ```powershell
   flutter devices  # Verifica que aparece tu celular
   flutter run
   ```

### iOS (Requiere Mac):

```bash
flutter run -d ios
```

---

## 📦 GENERAR APK PARA INSTALAR

### Para compartir con otros:

```powershell
# Genera el APK
flutter build apk --release

# Archivo generado:
# build\app\outputs\flutter-apk\app-release.apk
```

**Transferencia:**
- Conecta tu celular por USB
- Copia el APK a tu celular
- Abre el APK y permite "Instalar desde fuentes desconocidas"

---

## 🔧 COMANDOS ÚTILES

```powershell
# Ver todos los emuladores disponibles
flutter emulators

# Ver dispositivos conectados
flutter devices

# Limpiar cache si hay problemas
flutter clean
flutter pub get

# Ejecutar en modo release (más rápido)
flutter run --release

# Ver logs en tiempo real
flutter run -v
```

---

## ✅ QUÉ YA FUNCIONA

✅ Login/Onboarding completo
✅ 12 categorías de negocios
✅ Dashboard adaptativo
✅ Navegación por módulos
✅ Diseño responsive móvil/tablet/desktop
✅ Permisos Android/iOS configurados
✅ Iconos y diseño profesional
✅ Header fijo y sidebar adaptable

---

## ⚠️ NOTAS IMPORTANTES

1. **Para usar Supabase real**: Edita `lib/app/config/app_config.dart` con tus credenciales
2. **Por ahora**: Los datos se guardan en memoria (perfecto para demo)
3. **El diseño**: Se adapta automáticamente al tamaño de tu pantalla
4. **Performance**: La app es ligera y rápida

---

## 🎯 CÓMO PROBAR EL FLUJO COMPLETO

### Demo Rápida (5 minutos):

1. **Inicia**: `flutter emulators --launch Pixel_8_Pro && flutter run`
2. **Toca**: "Empezar" en la pantalla de login
3. **Completa**: Los 6 pasos del onboarding
   - Nombre: "Mi Tienda"
   - Categoría: "Abarrotes / Bodega"
   - Modelo: "Al por MENOR"
   - Siguiente, siguiente...
4. **Explora**: El dashboard y los diferentes módulos
5. **Navega**: Entre módulos usando el sidebar

---

## 🚀 PROYECTO COMPLETO

Tu app funciona en:
- ✅ Android (móvil, tablet)
- ✅ iOS (iPhone, iPad)
- ✅ Web (Chrome, Edge)
- ✅ Windows Desktop
- ✅ Linux (si configuras)

**¡Todo listo para ejecutar!** 🎉

---

## 📞 AYUDA RÁPIDA

**Si la app no inicia:**
```powershell
flutter clean
flutter pub get
flutter run
```

**Si el emulador no inicia:**
- Cierra Android Studio si está abierto
- Inicia: `flutter emulators --launch Medium_Phone_API_36`

**Si ves errores:**
- Lee la guía detallada: `sistema/EJECUTAR_MOVIL.md`

---

**¡Disfruta tu sistema multi-negocio!** 🚀📱💼

