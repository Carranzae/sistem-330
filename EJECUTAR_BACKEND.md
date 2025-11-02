# 🚀 CÓMO EJECUTAR EL BACKEND

## ✅ ESTADO ACTUAL

El backend está **100% funcional** y ejecutándose correctamente:

```
✅ Dependencias instaladas
✅ Servidor iniciado en puerto 3000
✅ PostgreSQL configurado
⚠️  Redis opcional (no requiere instalación)
```

---

## 🚀 INICIO RÁPIDO

```bash
# 1. Instalar dependencias (solo primera vez)
cd backend
npm install

# 2. Iniciar servidor
npm start

# O modo desarrollo (con auto-reload)
npm run dev
```

---

## 🔧 CONFIGURACIÓN

### **Archivo `.env`**

Crea un archivo `.env` en `backend/` con:

```env
# Node Environment
NODE_ENV=development

# Server
PORT=3000
FRONTEND_URL=http://localhost:8080

# PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_NAME=multinegocio
DB_USER=postgres
DB_PASSWORD=tu_password
DB_SSL=false

# Redis (Opcional)
REDIS_URL=redis://localhost:6379

# JWT Secret
JWT_SECRET=tu_clave_secreta_muy_segura_aqui
```

---

## 📊 SERVICIOS

### **PostgreSQL** (Requerido)

El backend usa PostgreSQL como base de datos principal:

- **Puerto**: 5432
- **Base de datos**: multinegocio
- **Usuario**: postgres (configurable)

**Sin PostgreSQL el backend NO funcionará correctamente.**

### **Redis** (Opcional)

Redis es para cache y mejora de rendimiento:

- **Puerto**: 6379
- **Uso**: Cache de sesiones, queries, etc.

**Sin Redis el backend funciona normalmente, solo sin cache.**

---

## ⚠️ MENSAJES ESPERADOS

### **Redis No Disponible** (Normal en desarrollo)

```
❌ Redis Error: ECONNREFUSED
⚠️  Continuando sin Redis - cache deshabilitado
```

**Esto es OK** - El backend funciona sin Redis.

### **Backend Iniciado Correctamente**

```
✅ Logger inicializado
🚀 Servidor iniciado en puerto 3000

╔═══════════════════════════════════════════════╗
║  Backend Multi-Negocio API                   ║
║  Puerto: 3000                                 ║
║  Ambiente: dev                                ║
╚═══════════════════════════════════════════════╝
```

**Esto indica que todo está funcionando.** ✅

---

## 🧪 PROBAR EL BACKEND

### **Health Check**

```bash
curl http://localhost:3000/api/health
```

Debería retornar:

```json
{
  "status": "ok",
  "timestamp": "2025-11-01T23:18:59.000Z",
  "uptime": 0.123,
  "environment": "development"
}
```

### **Rutas Disponibles**

- `GET /api/health` - Estado del servidor
- `POST /api/auth/login` - Iniciar sesión
- `POST /api/auth/register` - Registrar usuario
- `GET /api/businesses` - Listar negocios
- `POST /api/businesses` - Crear negocio
- `GET /api/products` - Listar productos
- `POST /api/products` - Crear producto
- `GET /api/sales` - Listar ventas
- `POST /api/sales` - Crear venta

---

## 🔍 SOLUCIÓN DE PROBLEMAS

### **Error: Cannot find module 'helmet'**

```bash
cd backend
npm install
```

### **Error: PostgreSQL connection refused**

Asegúrate de tener PostgreSQL instalado y corriendo:

```bash
# Windows (con servicios)
# Busca "Services" y verifica que PostgreSQL esté "Running"

# Verificar si está corriendo
psql -U postgres -c "SELECT version();"
```

### **Puerto 3000 ya en uso**

```bash
# Cambiar puerto en .env
PORT=3001
```

O matar el proceso:

```powershell
# Windows
netstat -ano | findstr :3000
taskkill /PID [NUMERO_PID] /F
```

---

## 📝 NOTAS IMPORTANTES

1. **PostgreSQL es requerido** para funcionar correctamente
2. **Redis es opcional** - el backend funciona sin él
3. **Las migraciones están en ARQUITECTURA_EMPRESARIAL_NIVEL_PRODUCCION.md**
4. **El schema de PostgreSQL debe ejecutarse primero**

---

## ✅ VERIFICAR QUE TODO FUNCIONA

```bash
# 1. Backend corriendo
curl http://localhost:3000/api/health

# 2. Verificar logs
# Deberías ver: "Servidor iniciado en puerto 3000"

# 3. Probar endpoints
curl http://localhost:3000/api/businesses
```

---

**Backend listo para desarrollo y producción** 🚀

