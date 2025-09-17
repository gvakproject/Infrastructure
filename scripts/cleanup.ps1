# PowerShell скрипт для очистки и обслуживания SteamInfrastructure
# Автор: SteamInfrastructure Team
# Дата: 2024

param(
    [switch]$All,
    [switch]$Containers,
    [switch]$Images,
    [switch]$Volumes,
    [switch]$Networks,
    [switch]$System
)

Write-Host "=== SteamInfrastructure Cleanup Script ===" -ForegroundColor Green

# Проверка наличия Docker
Write-Host "Проверка Docker..." -ForegroundColor Cyan
try {
    docker --version | Out-Null
    Write-Host "Docker найден" -ForegroundColor Green
} catch {
    Write-Host "ОШИБКА: Docker не установлен или не доступен!" -ForegroundColor Red
    exit 1
}

# Функция для подтверждения действия
function Confirm-Action {
    param([string]$Message)
    
    $response = Read-Host "$Message (y/N)"
    return $response -eq "y" -or $response -eq "Y"
}

# Очистка контейнеров
if ($All -or $Containers) {
    Write-Host "`n--- Очистка контейнеров ---" -ForegroundColor Yellow
    
    # Остановка контейнеров SteamInfrastructure
    Write-Host "Остановка контейнеров SteamInfrastructure..." -ForegroundColor Cyan
    docker stop steam-sqlserver steam-scrapoxy 2>$null
    docker rm steam-sqlserver steam-scrapoxy 2>$null
    
    # Очистка всех остановленных контейнеров
    if (Confirm-Action "Удалить все остановленные контейнеры?") {
        $stoppedContainers = docker container ls -a --filter "status=exited" -q
        if ($stoppedContainers) {
            docker container rm $stoppedContainers
            Write-Host "Остановленные контейнеры удалены" -ForegroundColor Green
        } else {
            Write-Host "Нет остановленных контейнеров" -ForegroundColor Yellow
        }
    }
}

# Очистка образов
if ($All -or $Images) {
    Write-Host "`n--- Очистка образов ---" -ForegroundColor Yellow
    
    if (Confirm-Action "Удалить неиспользуемые образы?") {
        docker image prune -f
        Write-Host "Неиспользуемые образы удалены" -ForegroundColor Green
    }
    
    if (Confirm-Action "Удалить все неиспользуемые образы (включая теги)?") {
        docker image prune -a -f
        Write-Host "Все неиспользуемые образы удалены" -ForegroundColor Green
    }
}

# Очистка томов
if ($All -or $Volumes) {
    Write-Host "`n--- Очистка томов ---" -ForegroundColor Yellow
    
    if (Confirm-Action "Удалить неиспользуемые тома?") {
        docker volume prune -f
        Write-Host "Неиспользуемые тома удалены" -ForegroundColor Green
    }
}

# Очистка сетей
if ($All -or $Networks) {
    Write-Host "`n--- Очистка сетей ---" -ForegroundColor Yellow
    
    if (Confirm-Action "Удалить неиспользуемые сети?") {
        docker network prune -f
        Write-Host "Неиспользуемые сети удалены" -ForegroundColor Green
    }
}

# Полная очистка системы
if ($All -or $System) {
    Write-Host "`n--- Полная очистка системы ---" -ForegroundColor Yellow
    
    if (Confirm-Action "Выполнить полную очистку Docker системы?") {
        docker system prune -a -f --volumes
        Write-Host "Полная очистка системы выполнена" -ForegroundColor Green
    }
}

# Показ статистики
Write-Host "`n--- Статистика Docker ---" -ForegroundColor Yellow
docker system df

Write-Host "`n=== Очистка завершена! ===" -ForegroundColor Green
