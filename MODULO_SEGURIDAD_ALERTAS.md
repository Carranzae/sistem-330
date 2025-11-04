# 🔒 MÓDULO DE SEGURIDAD Y ALERTAS

## 🎯 **PROPÓSITO**

Sistema integral de seguridad para detectar, registrar y alertar sobre posibles intentos de intrusión o actividad maliciosa en el sistema.

---

## 📋 **FUNCIONALIDADES PRINCIPALES**

### ✅ **1. Detección de Intrusión**
- Monitoreo continuo de eventos de seguridad
- Análisis automático de patrones sospechosos
- Alertas en tiempo real

### ✅ **2. Registro de Intento de Login**
- Historial completo de todos los intentos
- Tracking de IP, ubicación y dispositivo
- Detección de patrones anómalos

### ✅ **3. Bloqueo Automático de IPs**
- Bloqueo después de 5 intentos fallidos
- Bloqueo temporal (24h) o permanente
- Whitelist de IPs confiables

### ✅ **4. Auditoría de Acciones**
- Log completo de acciones críticas
- Registro de cambios en datos sensibles
- Trazabilidad total

### ✅ **5. Alertas de Seguridad**
- Notificaciones inmediatas en eventos críticos
- Dashboard centralizado de seguridad
- Reportes automáticos

---

## 🗄️ **TABLAS EN POSTGRESQL**

### **1. seguridad_eventos**
Registro de todos los eventos de seguridad detectados.

```sql
CREATE TABLE seguridad_eventos (
    id UUID PRIMARY KEY,
    negocio_id UUID NOT NULL,
    tipo_evento TEXT NOT NULL,
    severidad TEXT NOT NULL, -- bajo, medio, alto, critico
    ip_address TEXT NOT NULL,
    ubicacion TEXT,
    exito BOOLEAN NOT NULL,
    fecha_evento TIMESTAMPTZ NOT NULL,
    resuelto BOOLEAN DEFAULT false
);
```

**Tipos de Eventos:**
- `login_intento` - Intentos de login
- `acceso_denegado` - Sin permisos
- `cambio_password` - Modificación de contraseña
- `bloqueo_ip` - IP bloqueada
- `query_sospechosa` - Consultas anómalas
- `exportacion_masiva` - Descargas masivas
- `manipulacion_datos` - Cambios sospechosos

---

### **2. ip_bloqueadas**
IPs bloqueadas por actividad sospechosa.

```sql
CREATE TABLE ip_bloqueadas (
    id UUID PRIMARY KEY,
    ip_address TEXT UNIQUE NOT NULL,
    razon TEXT NOT NULL,
    fecha_bloqueo TIMESTAMPTZ NOT NULL,
    fecha_desbloqueo TIMESTAMPTZ,
    intentos_fallidos INTEGER DEFAULT 0
);
```

---

### **3. intentos_login**
Historial completo de intentos de login.

```sql
CREATE TABLE intentos_login (
    id UUID PRIMARY KEY,
    email TEXT NOT NULL,
    ip_address TEXT NOT NULL,
    exito BOOLEAN NOT NULL,
    razon_fallo TEXT,
    intento_numero INTEGER,
    timestamp TIMESTAMPTZ NOT NULL
);
```

---

### **4. auditoria**
Log de auditoría de acciones críticas.

```sql
CREATE TABLE auditoria (
    id UUID PRIMARY KEY,
    negocio_id UUID NOT NULL,
    usuario_id UUID NOT NULL,
    accion TEXT NOT NULL,
    tabla_afectada TEXT NOT NULL,
    valores_anteriores JSONB,
    valores_nuevos JSONB,
    ip_address TEXT,
    timestamp TIMESTAMPTZ NOT NULL
);
```

---

## 🎨 **INTERFAZ DE USUARIO**

### **Dashboard de Seguridad**

```
┌─────────────────────────────────────────────┐
│  🔒 SEGURIDAD Y ALERTAS                     │
├─────────────────────────────────────────────┤
│                                              │
│  📊 MÉTRICAS:                               │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐    │
│  │ Alertas  │ │ IPs      │ │ Intentos │    │
│  │   Hoy    │ │ Bloqueadas││ Fallidos │    │
│  │    12    │ │    3     │ │    45    │    │
│  └──────────┘ └──────────┘ └──────────┘    │
│                                              │
│  🌍 ACTIVIDAD RECIENTE:                     │
│  • Login desde Lima, Perú (hace 5 min)      │
│  • Intento fallido desde Rusia (hace 15 min)│
│  ⚠️ IP 192.168.1.100 bloqueada              │
│                                              │
│  🚨 ALERTAS CRÍTICAS:                       │
│  [CRÍTICO] Múltiples intentos de hacking    │
│  [ALTO] Cambio de configuración sensible    │
│                                              │
│  📈 GRÁFICO: Eventos por hora               │
│  [Line Chart]                                │
│                                              │
│  🗺️ MAPA: Ubicaciones de login              │
│  [World Map con puntos]                     │
│                                              │
└─────────────────────────────────────────────┘
```

---

## 🚨 **EJEMPLOS DE ALERTAS**

### **Alerta Crítica: Múltiples Intentos de Login Fallidos**
```
🚨 ALERTA CRÍTICA
─────────────────────────────────────
Tipo: Múltiples intentos de login fallidos
IP: 192.168.1.100
Ubicación: Lima, Perú
Intentos: 5
Acción: IP bloqueada automáticamente
Tiempo: Hace 2 minutos
```

### **Alerta Alta: Exportación Masiva de Datos**
```
⚠️ ALERTA ALTA
─────────────────────────────────────
Tipo: Exportación masiva de datos
Usuario: Juan Pérez
Acción: Exportar 10,000 productos
IP: 192.168.1.50
Hora: Hace 30 minutos
```

### **Alerta Media: Cambio de Configuración**
```
⚠️ ALERTA MEDIA
─────────────────────────────────────
Tipo: Cambio en configuración sensible
Usuario: María García
Acción: Modificar límites de crédito
Detalle: Límite cambiado de $1000 a $5000
```

---

## 🛡️ **PROTECCIONES IMPLEMENTADAS**

| Protección | Descripción | Acción Automática |
|------------|-------------|-------------------|
| **Rate Limiting** | Límite de requests por minuto | Bloqueo temporal |
| **IP Blacklist** | Bloqueo por actividad sospechosa | Bloqueo 24h |
| **Geo-Blocking** | Detectar ubicaciones inusuales | Alerta + 2FA |
| **Pattern Detection** | Detectar patrones de ataque | Bloqueo preventivo |
| **Data Integrity** | Monitorear cambios críticos | Alertas inmediatas |
| **Session Hijacking** | Detectar sesiones robadas | Forzar logout |

---

## 🔔 **NOTIFICACIONES AUTOMÁTICAS**

**Canales de Alerta:**
- 📱 Push notifications (tiempo real)
- 📧 Email para eventos críticos
- 💬 SMS para emergencias
- 🔴 Badge en app

**Configuración:**
```dart
SecurityAlertSettings(
  enablePushNotifications: true,
  enableEmail: true,
  enableSMS: false,
  criticalEvents: ['hacking_attempt', 'data_breach'],
  notificationFrequency: 'realtime',
)
```

---

## 📊 **REPORTES**

**Reportes Disponibles:**
- 📈 Reporte mensual de seguridad
- 🚨 Eventos críticos del día
- 🌍 Análisis de ubicaciones
- 📋 Log de auditoría exportable

---

*Módulo integrado completamente en la arquitectura empresarial* ✅

