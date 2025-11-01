# 🚀 COMANDOS PARA ACTUALIZAR REPOSITORIO EN GITHUB

## 📋 Pasos para Subir Cambios

### 1. Verificar Estado Actual
```bash
git status
```

### 2. Agregar Archivos al Stage
```bash
# Agregar todos los archivos modificados y nuevos (excepto los ignorados)
git add .

# O agregar archivos específicos:
git add sistema/lib/
git add sistema/pubspec.yaml
git add *.md
```

### 3. Crear Commit con Mensaje Descriptivo
```bash
git commit -m "feat: Implementación completa de Inventario y Mi Score

- Agregado Tab Entrada en Inventario con categorías dinámicas
- Implementado Tab Ventas en Mi Score con certificado PDF
- Agregado módulo Pronósticos en sidebar
- Corregido error Material widget en layouts
- Mejorada UI/UX en todos los módulos
- Actualizada documentación FUNCIONALIDADES_ABARROTES.md"
```

### 4. Subir a GitHub
```bash
# Si es la primera vez o quieres forzar
git push origin main

# Si ya existe y quieres traer cambios primero
git pull origin main
git push origin main

# O con rebase automático
git pull --rebase origin main
git push origin main
```

---

## 🔧 Comandos Adicionales Útiles

### Ver Cambios en Archivos
```bash
git diff
git diff archivo_especifico.dart
```

### Ver Historial de Commits
```bash
git log --oneline
git log --graph --oneline --all
```

### Deshacer Cambios
```bash
# Descartar cambios en un archivo
git restore archivo.dart

# Descartar TODOS los cambios
git restore .

# Deshacer último commit pero mantener cambios
git reset --soft HEAD~1

# Deshacer último commit y descartar cambios
git reset --hard HEAD~1
```

### Crear Ramas
```bash
# Crear y cambiar a nueva rama
git checkout -b nombre-rama

# Ver ramas
git branch

# Cambiar de rama
git checkout main

# Fusionar rama
git merge nombre-rama
```

---

## 📦 COMANDOS COMPLETOS PARA ESTA ACTUALIZACIÓN

```bash
# 1. Ir a la carpeta del proyecto
cd C:\Users\auner\Desktop\SYSTEM_MULTI_NEGOCIO\sistem-330

# 2. Ver qué archivos cambiaron
git status

# 3. Agregar todos los archivos importantes
git add .

# 4. Ver qué se va a commitear
git status

# 5. Crear commit
git commit -m "feat: Implementación completa de Inventario y Mi Score con certificados PDF"

# 6. Subir a GitHub
git push origin main
```

---

## ⚠️ IMPORTANTE

- **NO subir** `node_modules/`, `build/`, `.dart_tool/` (ya están en .gitignore)
- **Verificar** que `.gitignore` esté actualizado
- **Hacer commits frecuentes** con mensajes descriptivos
- **Pull antes de push** si trabajas en equipo

