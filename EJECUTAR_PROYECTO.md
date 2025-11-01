# 🚀 Guía para Ejecutar el Proyecto

## ✅ Estado Actual

### Backend (Node.js)
- ✅ Dependencias instaladas
- ⚠️ **Requiere configuración de Supabase**
- ⚠️ El servidor necesita credenciales válidas de Supabase

### Frontend (Flutter)
- ✅ Dependencias instaladas (140 paquetes)
- ✅ Flutter 3.24.5 instalado y funcionando
- ✅ Dispositivos disponibles:
  - Windows Desktop
  - Chrome (web)
  - Edge (web)
- ⚠️ **Requiere configuración de Supabase**

## 🔧 Configuración Necesaria

### 1. Backend - Configurar Supabase

Edita `backend/index.js` líneas 7-8:
```javascript
const supabaseUrl = 'https://TU_PROYECTO.supabase.co';
const supabaseKey = 'TU_ANON_KEY';
```

O crea un archivo `backend/.env`:
```env
SUPABASE_URL=https://TU_PROYECTO.supabase.co
SUPABASE_ANON_KEY=TU_ANON_KEY
```

### 2. Frontend - Configurar Supabase

Edita `sistema/lib/app/config/app_config.dart`:
```dart
static const String supabaseUrl = 'https://TU_PROYECTO.supabase.co';
static const String supabaseAnonKey = 'TU_ANON_KEY';
```

## 🚀 Comandos para Ejecutar

### Backend
```powershell
cd backend
npm run dev
```
El servidor correrá en: `http://localhost:3000`

### Frontend
```powershell
cd sistema

# Ejecutar en Windows Desktop
flutter run -d windows

# O ejecutar en navegador
flutter run -d chrome
flutter run -d edge
```

## 📋 Funcionalidades del Sistema

### Módulos Disponibles:
- ✅ **Onboarding** - Registro de negocio
- ✅ **Dashboard** - Panel adaptativo
- ✅ **POS** - Punto de venta
- ✅ **Inventario** - Gestión de productos
- ✅ **Clientes** - Gestión de clientes
- ✅ **Proveedores** - Gestión de proveedores
- ✅ **Caja** - Gestión de caja
- ✅ **Reportes** - Reportes y estadísticas

## ⚠️ Notas Importantes

1. **Supabase**: Ambos (backend y frontend) requieren las credenciales de Supabase para funcionar completamente.

2. **Base de Datos**: Asegúrate de que las tablas estén creadas en Supabase:
   - `negocios`
   - `productos`
   - `ventas`
   - `clientes`

3. **Primera Ejecución**: El sistema iniciará con el flujo de onboarding para configurar el negocio.

## 🔍 Verificar Estado

```powershell
# Ver dispositivos Flutter disponibles
flutter devices

# Verificar dependencias
cd backend && npm list
cd ../sistema && flutter pub deps
```


