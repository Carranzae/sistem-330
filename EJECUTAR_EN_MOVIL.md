# 📱 EJECUTAR EN TU MÓVIL ANDROID

## 🔧 PASO 1: HABILITAR DEPURACIÓN USB

### **En tu Móvil Android:**

1. **Abrir Configuración**
   - Ir a: `Configuración > Acerca del teléfono`
   - Buscar: **"Número de compilación"** o **"MIUI version"**

2. **Habilitar Opciones de Desarrollador**
   - Tocar **7 veces** en "Número de compilación"
   - Aparecerá: "¡Ahora eres un desarrollador!"

3. **Activar Depuración USB**
   - Ir a: `Configuración > Opciones de desarrollador`
   - Activar: **"Depuración USB"**
   - Activar: **"Instalar vía USB"** (si está disponible)

---

## 📲 PASO 2: CONECTAR AL PC

### **Conectar por USB:**

1. Conectar tu móvil al PC con **cable USB**
2. Tu móvil mostrará un diálogo: **"¿Permitir depuración USB?"**
3. Marcar: **"Permitir siempre desde este equipo"**
4. Tocar: **"Aceptar"**

---

## ✅ PASO 3: VERIFICAR CONEXIÓN

### **Comando 1: Verificar ADB**

```bash
adb devices
```

**Debería mostrar:**
```
List of devices attached
ABC123XYZ    device    ← Tu móvil aquí
```

### **Comando 2: Verificar Flutter**

```bash
cd sistema
flutter devices
```

**Debería mostrar:**
```
Found 2 connected devices:
  SM-G950F (mobile) • ABC123XYZ • android-arm64 • Android 11
  Windows (desktop) • windows   • windows-x64
```

---

## 🚀 PASO 4: EJECUTAR LA APP

### **Ejecutar en tu móvil:**

```bash
cd sistema
flutter run
```

**O especificar el dispositivo:**

```bash
flutter run -d ABC123XYZ
```

---

## 🔍 SOLUCIÓN DE PROBLEMAS

### **Error: "No devices detected"**

1. **Verificar cable USB:**
   ```bash
   # Probar con otro cable USB
   # Algunos cables son solo para carga
   ```

2. **Reiniciar ADB:**
   ```bash
   adb kill-server
   adb start-server
   adb devices
   ```

3. **Cambiar modo USB:**
   - En tu móvil: Deslizar notificaciones
   - Buscar: "Cargar dispositivo vía USB"
   - Cambiar a: **"Transferencia de archivos (MTP)"**

### **Error: "Device unauthorized"**

1. Desconectar y reconectar USB
2. Revisar tu móvil y aceptar el diálogo
3. Marcar "Permitir siempre"

### **Error: "ADB not found"**

1. Instalar Android SDK Platform Tools
2. O usar Flutter que incluye ADB
3. Verificar PATH de ADB

---

## 🔌 MODO WIRELESS (OPCIONAL)

### **Ejecutar sin cable USB:**

```bash
# 1. Conectar por WiFi
adb tcpip 5555

# 2. Conectar (reemplaza IP_MOVIL)
adb connect IP_MOVIL:5555

# 3. Ejecutar app
cd sistema
flutter run
```

---

## 📱 VERIFICAR QUE FUNCIONA

### **Durante la ejecución:**

```
Running "flutter pub get"...
Resolving dependencies...

Launching lib/main.dart on SM-G950F in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build/app/outputs/flutter-apk/app-debug.apk (35.2MB).
Installing build/app/outputs/flutter-apk/app.apk...
Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
```

---

## ✅ VERIFICACIÓN FINAL

### **Tu app debería:**

1. ✅ Instalarse en tu móvil
2. ✅ Ejecutarse automáticamente
3. ✅ Mostrar la pantalla de Login
4. ✅ Responder a cambios con Hot Reload (r)

---

## 🎯 COMANDOS ÚTILES

```bash
# Listar dispositivos
flutter devices

# Verificar ADB
adb devices

# Instalar APK directamente
flutter install

# Build APK para compartir
flutter build apk

# Modo release (más rápido)
flutter run --release
```

---

**¡Tu app en tu móvil!** 📱🚀

