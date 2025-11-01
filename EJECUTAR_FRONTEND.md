# 📱 Ejecutar Frontend (Flutter)

## 🚀 Comandos Rápidos

### Opción 1: Windows Desktop (Recomendado)
```powershell
cd sistema
flutter run -d windows
```

### Opción 2: Chrome (Navegador - Más rápido)
```powershell
cd sistema
flutter run -d chrome
```

### Opción 3: Edge (Navegador)
```powershell
cd sistema
flutter run -d edge
```

## 📋 Pasos Completos

### 1. Ir al directorio del frontend
```powershell
cd sistema
```

### 2. Verificar dispositivos disponibles
```powershell
flutter devices
```

### 3. Instalar dependencias (si es necesario)
```powershell
flutter pub get
```

### 4. Ejecutar la aplicación
```powershell
# Windows Desktop
flutter run -d windows

# O en navegador
flutter run -d chrome
```

## 🔍 Comandos Útiles

### Ver qué dispositivos están disponibles
```powershell
flutter devices
```

### Limpiar y reconstruir
```powershell
flutter clean
flutter pub get
flutter run -d windows
```

### Ejecutar en modo release (más rápido)
```powershell
flutter run -d windows --release
```

### Ver logs en tiempo real
```powershell
flutter run -d windows -v
```

## ⚠️ Si hay errores

### Error: "No devices found"
```powershell
# Ver dispositivos
flutter devices

# Si no hay dispositivos, ejecuta en web
flutter run -d chrome
```

### Error: "Build failed"
```powershell
# Limpiar y reconstruir
flutter clean
flutter pub get
flutter run -d windows
```

## ✅ Verificación

Una vez ejecutado, deberías ver:
- La aplicación Flutter abierta
- La interfaz del sistema multi-negocio
- Si hay errores, aparecerán en la consola

---
**Nota:** Asegúrate de que el backend esté corriendo en `http://localhost:3000` para que la app funcione completamente.


