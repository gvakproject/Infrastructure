# PowerShell скрипт для просмотра логов SteamInfrastructure
# Автор: SteamInfrastructure Team
# Дата: 2024

param(
    [string]$Service = "all",
    [int]$Lines = 50,
    [switch]$Follow
)

Write-Host "=== SteamInfrastructure Logs Viewer ===" -ForegroundColor Green

# Проверка наличия Docker
Write-Host "Проверка Docker..." -ForegroundColor Cyan
try {
    docker --version | Out-Null
    Write-Host "Docker найден" -ForegroundColor Green
} catch {
    Write-Host "ОШИБКА: Docker не установлен или не доступен!" -ForegroundColor Red
    exit 1
}

# Функция для отображения логов
function Show-Logs {
    param(
        [string]$ContainerName,
        [string]$ServiceName
    )
    
    Write-Host "`n--- Логи $ServiceName ---" -ForegroundColor Yellow
    
    if ($Follow) {
        Write-Host "Показ логов в реальном времени (Ctrl+C для выхода)..." -ForegroundColor Cyan
        docker logs -f --tail $Lines $ContainerName
    } else {
        docker logs --tail $Lines $ContainerName
    }
}

# Отображение логов в зависимости от выбранного сервиса
switch ($Service.ToLower()) {
    "sql" {
        Show-Logs -ContainerName "steam-sqlserver" -ServiceName "SQL Server"
    }
    "scrapoxy" {
        Show-Logs -ContainerName "steam-scrapoxy" -ServiceName "Scrapoxy"
    }
    "all" {
        Show-Logs -ContainerName "steam-sqlserver" -ServiceName "SQL Server"
        Show-Logs -ContainerName "steam-scrapoxy" -ServiceName "Scrapoxy"
    }
    default {
        Write-Host "Неизвестный сервис: $Service" -ForegroundColor Red
        Write-Host "Доступные сервисы: sql, scrapoxy, all" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "`n=== Просмотр логов завершен ===" -ForegroundColor Green
