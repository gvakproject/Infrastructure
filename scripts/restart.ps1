# PowerShell скрипт для перезапуска SteamInfrastructure
# Автор: SteamInfrastructure Team
# Дата: 2024

Write-Host "=== SteamInfrastructure Restart Script ===" -ForegroundColor Green
Write-Host "Перезапуск SQL Server и Scrapoxy..." -ForegroundColor Yellow

# Проверка наличия Docker
Write-Host "Проверка Docker..." -ForegroundColor Cyan
try {
    docker --version | Out-Null
    Write-Host "Docker найден" -ForegroundColor Green
} catch {
    Write-Host "ОШИБКА: Docker не установлен или не доступен!" -ForegroundColor Red
    exit 1
}

# Остановка существующих контейнеров
Write-Host "Остановка существующих контейнеров..." -ForegroundColor Cyan
docker stop steam-sqlserver steam-scrapoxy 2>$null
docker rm steam-sqlserver steam-scrapoxy 2>$null

# Ожидание завершения остановки
Write-Host "Ожидание завершения остановки (5 секунд)..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Запуск сервисов
Write-Host "Запуск сервисов..." -ForegroundColor Cyan
& ".\scripts\start.ps1"

Write-Host "=== SteamInfrastructure перезапущен! ===" -ForegroundColor Green
