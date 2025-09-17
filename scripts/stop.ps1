# PowerShell скрипт для остановки SteamInfrastructure
# Автор: SteamInfrastructure Team
# Дата: 2024

Write-Host "=== SteamInfrastructure Stop Script ===" -ForegroundColor Green
Write-Host "Остановка SQL Server и Scrapoxy..." -ForegroundColor Yellow

# Проверка наличия Docker
Write-Host "Проверка Docker..." -ForegroundColor Cyan
try {
    docker --version | Out-Null
    Write-Host "Docker найден" -ForegroundColor Green
} catch {
    Write-Host "ОШИБКА: Docker не установлен или не доступен!" -ForegroundColor Red
    exit 1
}

# Остановка контейнеров
Write-Host "Остановка контейнеров..." -ForegroundColor Cyan

# Остановка SQL Server
Write-Host "Остановка SQL Server..." -ForegroundColor Yellow
$sqlServerRunning = docker ps -q --filter "name=steam-sqlserver"
if ($sqlServerRunning) {
    docker stop steam-sqlserver
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SQL Server остановлен" -ForegroundColor Green
    } else {
        Write-Host "ОШИБКА: Не удалось остановить SQL Server!" -ForegroundColor Red
    }
} else {
    Write-Host "SQL Server не запущен" -ForegroundColor Yellow
}

# Остановка Scrapoxy
Write-Host "Остановка Scrapoxy..." -ForegroundColor Yellow
$scrapoxyRunning = docker ps -q --filter "name=steam-scrapoxy"
if ($scrapoxyRunning) {
    docker stop steam-scrapoxy
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Scrapoxy остановлен" -ForegroundColor Green
    } else {
        Write-Host "ОШИБКА: Не удалось остановить Scrapoxy!" -ForegroundColor Red
    }
} else {
    Write-Host "Scrapoxy не запущен" -ForegroundColor Yellow
}

# Удаление контейнеров
Write-Host "Удаление контейнеров..." -ForegroundColor Cyan

# Удаление SQL Server контейнера
$sqlServerExists = docker ps -a -q --filter "name=steam-sqlserver"
if ($sqlServerExists) {
    docker rm steam-sqlserver
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Контейнер SQL Server удален" -ForegroundColor Green
    } else {
        Write-Host "ОШИБКА: Не удалось удалить контейнер SQL Server!" -ForegroundColor Red
    }
} else {
    Write-Host "Контейнер SQL Server не найден" -ForegroundColor Yellow
}

# Удаление Scrapoxy контейнера
$scrapoxyExists = docker ps -a -q --filter "name=steam-scrapoxy"
if ($scrapoxyExists) {
    docker rm steam-scrapoxy
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Контейнер Scrapoxy удален" -ForegroundColor Green
    } else {
        Write-Host "ОШИБКА: Не удалось удалить контейнер Scrapoxy!" -ForegroundColor Red
    }
} else {
    Write-Host "Контейнер Scrapoxy не найден" -ForegroundColor Yellow
}

# Проверка статуса
Write-Host "Проверка статуса контейнеров..." -ForegroundColor Cyan
$runningContainers = docker ps --filter "name=steam-"
if ($runningContainers) {
    Write-Host "Запущенные контейнеры:" -ForegroundColor Yellow
    $runningContainers
} else {
    Write-Host "Нет запущенных контейнеров SteamInfrastructure" -ForegroundColor Green
}

Write-Host "=== SteamInfrastructure остановлен! ===" -ForegroundColor Green
Write-Host "Для запуска используйте: .\scripts\start.ps1" -ForegroundColor Cyan
