# 🔐 Configuración SSH para GitHub

## ✅ Paso 1: Agregar tu clave SSH a GitHub

**Tu clave pública SSH es:**
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILgsvoI/u9FRZ4qvROI9hgVhVBTO6YBQ5u5fVK8kOqFx github-key-sistem330
```

### Instrucciones:

1. **Copia la clave pública de arriba** (toda la línea completa)

2. **Ve a GitHub:**
   - Abre: https://github.com/settings/keys
   - O ve a: GitHub → Tu perfil → Settings → SSH and GPG keys

3. **Agrega la clave:**
   - Haz clic en **"New SSH key"**
   - **Title**: `Sistem-330 - Windows PC` (o el nombre que prefieras)
   - **Key**: Pega la clave pública completa
   - Haz clic en **"Add SSH key"**

4. **Verificar conexión:**
   ```powershell
   ssh -T git@github.com
   ```
   Deberías ver: `Hi Carranzae! You've successfully authenticated...`

## ✅ Paso 2: Configuración Completada

El repositorio ya está configurado para usar SSH:
- **Remote URL**: `git@github.com:Carranzae/sistem-330.git`

## 📝 Scripts Disponibles

Ahora tienes 3 scripts útiles:

### 1. `git-update.ps1` - Solo actualizar desde GitHub
```powershell
.\git-update.ps1
```

### 2. `git-push.ps1` - Subir cambios a GitHub
```powershell
.\git-push.ps1 "Mi mensaje de commit"
```

### 3. `git-sync.ps1` - Actualizar y subir (todo en uno)
```powershell
.\git-sync.ps1 "Mi mensaje de commit"
```

## 🚀 Uso Diario

### Opción 1: Usar los scripts (Recomendado)
```powershell
# Actualizar desde GitHub
.\git-update.ps1

# Subir cambios
.\git-push.ps1 "Descripción de cambios"
```

### Opción 2: Comandos Git tradicionales
```powershell
# Actualizar
git pull origin main

# Subir cambios
git add .
git commit -m "Mi mensaje"
git push origin main
```

## 🔍 Verificar que todo funciona

Después de agregar la clave SSH a GitHub, prueba:

```powershell
# Probar conexión SSH
ssh -T git@github.com

# Verificar remote
git remote -v

# Hacer un pull de prueba
git pull origin main
```

## ⚠️ Si tienes problemas

### Si SSH no funciona:
- Verifica que agregaste la clave en GitHub
- Prueba: `ssh -T git@github.com`
- Si falla, puedes volver a HTTPS temporalmente:
  ```powershell
  git remote set-url origin https://github.com/Carranzae/sistem-330.git
  ```

### Si los scripts no funcionan:
- Asegúrate de estar en el directorio del proyecto
- Ejecuta PowerShell como administrador si es necesario
- Verifica permisos de ejecución: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

## ✅ Listo!

Una vez que agregues la clave SSH a GitHub, podrás usar `git pull` y `git push` sin ingresar credenciales cada vez.


