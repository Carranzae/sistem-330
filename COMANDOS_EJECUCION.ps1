# Script para ejecutar el proyecto completo
# Sistema Multi-Negocio

Write-Host "🚀 Iniciando Sistema Multi-Negocio" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Gray

# Función para ejecutar backend
function Start-Backend {
    Write-Host "`n📦 Iniciando Backend..." -ForegroundColor Yellow
    Set-Location backend
    if (-not (Test-Path node_modules)) {
        Write-Host "Instalando dependencias del backend..." -ForegroundColor Gray
        npm install
    }
    Write-Host "Ejecutando servidor en http://localhost:3000" -ForegroundColor Green
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; npm run dev"
    Set-Location ..
}

# Función para ejecutar frontend
function Start-Frontend {
    Write-Host "`n📱 Iniciando Frontend (Flutter)..." -ForegroundColor Yellow
    Set-Location sistema
    if (-not (Test-Path .dart_tool)) {
        Write-Host "Instalando dependencias de Flutter..." -ForegroundColor Gray
        flutter pub get
    }
    Write-Host "Ejecutando aplicación Flutter..." -ForegroundColor Green
    flutter run -d windows
    Set-Location ..
}

# Menú
Write-Host "`n¿Qué deseas ejecutar?" -ForegroundColor Cyan
Write-Host "1. Solo Backend (Node.js)"
Write-Host "2. Solo Frontend (Flutter)"
Write-Host "3. Ambos (Backend + Frontend)"
Write-Host "4. Salir"
Write-Host ""

$opcion = Read-Host "Selecciona una opción (1-4)"

switch ($opcion) {
    "1" { Start-Backend }
    "2" { Start-Frontend }
    "3" { 
        Start-Backend
        Start-Sleep -Seconds 3
        Start-Frontend
    }
    "4" { Write-Host "Saliendo..." -ForegroundColor Yellow }
    default { Write-Host "Opción inválida" -ForegroundColor Red }
}


