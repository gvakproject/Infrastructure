# PowerShell скрипт для управления SteamInfrastructure
# Автор: SteamInfrastructure Team
# Дата: 2024

param(
    [Parameter(Position=0)]
    [string]$Action = "help"
)

Write-Host "=== SteamInfrastructure Management Script ===" -ForegroundColor Green

# Функция для отображения справки
function Show-Help {
    Write-Host "`nИспользование: .\scripts\manage.ps1 [ACTION]" -ForegroundColor Yellow
    Write-Host "`nДоступные действия:" -ForegroundColor Cyan
    Write-Host "  start     - Запустить все сервисы" -ForegroundColor White
    Write-Host "  stop      - Остановить все сервисы" -ForegroundColor White
    Write-Host "  restart   - Перезапустить все сервисы" -ForegroundColor White
    Write-Host "  status    - Показать статус сервисов" -ForegroundColor White
    Write-Host "  logs      - Показать логи сервисов" -ForegroundColor White
    Write-Host "  backup    - Создать резервную копию" -ForegroundColor White
    Write-Host "  cleanup   - Очистить Docker ресурсы" -ForegroundColor White
    Write-Host "  help      - Показать эту справку" -ForegroundColor White
    Write-Host "`nПримеры:" -ForegroundColor Cyan
    Write-Host "  .\scripts\manage.ps1 start" -ForegroundColor White
    Write-Host "  .\scripts\manage.ps1 status" -ForegroundColor White
    Write-Host "  .\scripts\manage.ps1 logs -Service sql" -ForegroundColor White
    Write-Host "  .\scripts\manage.ps1 backup -IncludeData" -ForegroundColor White
}

# Проверка наличия Docker
Write-Host "Проверка Docker..." -ForegroundColor Cyan
try {
    docker --version | Out-Null
    Write-Host "Docker найден" -ForegroundColor Green
} catch {
    Write-Host "ОШИБКА: Docker не установлен или не доступен!" -ForegroundColor Red
    exit 1
}

# Выполнение действия
switch ($Action.ToLower()) {
    "start" {
        Write-Host "`nЗапуск SteamInfrastructure..." -ForegroundColor Yellow
        & ".\scripts\start.ps1"
    }
    "stop" {
        Write-Host "`nОстановка SteamInfrastructure..." -ForegroundColor Yellow
        & ".\scripts\stop.ps1"
    }
    "restart" {
        Write-Host "`nПерезапуск SteamInfrastructure..." -ForegroundColor Yellow
        & ".\scripts\restart.ps1"
    }
    "status" {
        Write-Host "`nПроверка статуса SteamInfrastructure..." -ForegroundColor Yellow
        & ".\scripts\status.ps1"
    }
    "logs" {
        Write-Host "`nПросмотр логов SteamInfrastructure..." -ForegroundColor Yellow
        & ".\scripts\logs.ps1" @args
    }
    "backup" {
        Write-Host "`nСоздание резервной копии SteamInfrastructure..." -ForegroundColor Yellow
        & ".\scripts\backup.ps1" @args
    }
    "cleanup" {
        Write-Host "`nОчистка Docker ресурсов..." -ForegroundColor Yellow
        & ".\scripts\cleanup.ps1" @args
    }
    "help" {
        Show-Help
    }
    default {
        Write-Host "`nНеизвестное действие: $Action" -ForegroundColor Red
        Show-Help
        exit 1
    }
}

Write-Host "`n=== Управление завершено! ===" -ForegroundColor Green
