# Script para solucionar el problema del puerto 3000 en uso

Write-Host "🔍 Buscando procesos usando el puerto 3000..." -ForegroundColor Cyan

$processes = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique

if ($processes) {
    Write-Host "`n⚠️  Procesos encontrados en el puerto 3000:" -ForegroundColor Yellow
    
    foreach ($pid in $processes) {
        $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
        if ($proc) {
            Write-Host "   PID: $($proc.Id) - $($proc.ProcessName)" -ForegroundColor Red
        }
    }
    
    Write-Host "`n¿Deseas cerrar estos procesos? (S/N)" -ForegroundColor Yellow
    $respuesta = Read-Host
    
    if ($respuesta -eq "S" -or $respuesta -eq "s") {
        foreach ($pid in $processes) {
            try {
                Stop-Process -Id $pid -Force
                Write-Host "✅ Proceso $pid cerrado" -ForegroundColor Green
            } catch {
                Write-Host "❌ Error al cerrar proceso $pid" -ForegroundColor Red
            }
        }
        Write-Host "`n✅ Puedes ejecutar 'npm run dev' nuevamente" -ForegroundColor Green
    }
} else {
    Write-Host "✅ No hay procesos usando el puerto 3000" -ForegroundColor Green
    Write-Host "💡 Prueba cerrar todas las terminales y ejecutar nuevamente" -ForegroundColor Yellow
}

Write-Host "`n📝 Alternativa: Usar otro puerto" -ForegroundColor Cyan
Write-Host "   PORT=3001 npm run dev" -ForegroundColor Gray


