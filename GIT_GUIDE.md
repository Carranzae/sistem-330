# Guía de Configuración Git para Trabajo Remoto

## ✅ Estado Actual
Tu repositorio ya está configurado correctamente:
- **Remote origin**: `https://github.com/Carranzae/sistem-330.git`
- **Rama main** está rastreando `origin/main`

## 🔄 Comandos Principales para Sincronización

### 1. Actualizar desde GitHub (descargar cambios)
```bash
git pull
```
o específicamente desde origin/main:
```bash
git pull origin main
```

### 2. Verificar estado antes de actualizar
```bash
git status
git fetch origin
```

### 3. Subir cambios a GitHub
```bash
# Primero agregar tus cambios
git add .

# Luego hacer commit
git commit -m "Descripción de tus cambios"

# Finalmente subir a GitHub
git push
```

### 4. Ver diferencias antes de hacer pull
```bash
git fetch origin
git log HEAD..origin/main
```

## 🔐 Configuración de Autenticación

### Opción 1: Personal Access Token (Recomendado)
1. Ve a GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Genera un nuevo token con permisos `repo`
3. Cuando hagas `git push` o `git pull`, usa el token como contraseña

### Opción 2: SSH (Más Seguro para uso continuo)
```bash
# Generar clave SSH (si no tienes una)
ssh-keygen -t ed25519 -C "tu_email@ejemplo.com"

# Agregar clave al agente SSH
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copiar clave pública
cat ~/.ssh/id_ed25519.pub

# Agregar la clave pública en GitHub → Settings → SSH and GPG keys

# Cambiar remote a SSH
git remote set-url origin git@github.com:Carranzae/sistem-330.git
```

### Opción 3: GitHub CLI
```bash
# Instalar GitHub CLI
# Windows: winget install GitHub.cli

# Autenticarse
gh auth login

# Esto manejará automáticamente la autenticación
```

## 📋 Flujo de Trabajo Recomendado

### Al iniciar tu jornada:
```bash
git pull origin main
```

### Antes de hacer push:
```bash
# 1. Verificar estado
git status

# 2. Descargar cambios más recientes
git pull origin main

# 3. Resolver conflictos si los hay
# 4. Agregar cambios
git add .

# 5. Commit
git commit -m "Tu mensaje descriptivo"

# 6. Push
git push origin main
```

## 🔧 Configuración Adicional Útil

### Configurar nombre y email (si no está configurado)
```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu_email@ejemplo.com"
```

### Configurar pull con rebase (evita merge commits innecesarios)
```bash
git config pull.rebase false  # merge (por defecto)
# o
git config pull.rebase true   # rebase (más limpio)
```

### Ver configuración actual
```bash
git config --list
```

### Verificar conexión con GitHub
```bash
git ls-remote origin
```

## 🚨 Solución de Problemas Comunes

### Si `git pull` falla por autenticación:
- Usa Personal Access Token
- O configura SSH
- O usa GitHub CLI

### Si hay conflictos después de `git pull`:
```bash
# Ver archivos con conflictos
git status

# Editar manualmente los archivos marcados
# Luego:
git add .
git commit -m "Resuelto conflicto"
```

### Para ver el historial de cambios:
```bash
git log --oneline --graph --all
```

## 📝 Notas Importantes

1. **Siempre haz `git pull` antes de `git push`** para evitar conflictos
2. **Commit frecuentemente** pero haz push cuando estés seguro
3. **Usa mensajes de commit descriptivos** en español o inglés
4. **Nunca hagas push directamente a main** si trabajas en equipo (usa branches)


