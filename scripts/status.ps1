# PowerShell скрипт для проверки статуса SteamInfrastructure
# Автор: SteamInfrastructure Team
# Дата: 2024

Write-Host "=== SteamInfrastructure Status Check ===" -ForegroundColor Green

# Проверка наличия Docker
Write-Host "Проверка Docker..." -ForegroundColor Cyan
try {
    docker --version | Out-Null
    Write-Host "Docker найден" -ForegroundColor Green
} catch {
    Write-Host "ОШИБКА: Docker не установлен или не доступен!" -ForegroundColor Red
    exit 1
}

# Проверка статуса контейнеров
Write-Host "`nСтатус контейнеров:" -ForegroundColor Cyan
$containers = docker ps --filter "name=steam-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
if ($containers) {
    Write-Host $containers -ForegroundColor White
} else {
    Write-Host "Нет запущенных контейнеров SteamInfrastructure" -ForegroundColor Yellow
}

# Проверка SQL Server
Write-Host "`nПроверка SQL Server:" -ForegroundColor Cyan
$sqlServerRunning = docker ps -q --filter "name=steam-sqlserver"
if ($sqlServerRunning) {
    Write-Host "✓ SQL Server контейнер запущен" -ForegroundColor Green
    
    # Проверка доступности SQL Server
    try {
        $result = docker exec steam-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U $env:SQL_SERVER_USERNAME -P $env:SQL_SERVER_PASSWORD -Q "SELECT @@VERSION" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ SQL Server доступен и отвечает" -ForegroundColor Green
        } else {
            Write-Host "✗ SQL Server не отвечает на запросы" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ Не удалось подключиться к SQL Server" -ForegroundColor Red
    }
} else {
    Write-Host "✗ SQL Server контейнер не запущен" -ForegroundColor Red
}

# Проверка Scrapoxy
Write-Host "`nПроверка Scrapoxy:" -ForegroundColor Cyan
$scrapoxyRunning = docker ps -q --filter "name=steam-scrapoxy"
if ($scrapoxyRunning) {
    Write-Host "✓ Scrapoxy контейнер запущен" -ForegroundColor Green
    
    # Проверка доступности Scrapoxy API
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8889/api/health" -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ Scrapoxy API доступен" -ForegroundColor Green
        } else {
            Write-Host "✗ Scrapoxy API возвращает код: $($response.StatusCode)" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ Scrapoxy API недоступен" -ForegroundColor Red
    }
    
    # Проверка доступности Scrapoxy Web UI
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8891" -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ Scrapoxy Web UI доступен" -ForegroundColor Green
        } else {
            Write-Host "✗ Scrapoxy Web UI возвращает код: $($response.StatusCode)" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ Scrapoxy Web UI недоступен" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Scrapoxy контейнер не запущен" -ForegroundColor Red
}

# Проверка портов
Write-Host "`nПроверка портов:" -ForegroundColor Cyan
$ports = @(1433, 8889, 8891)
foreach ($port in $ports) {
    $connection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    if ($connection.TcpTestSucceeded) {
        Write-Host "✓ Порт $port открыт" -ForegroundColor Green
    } else {
        Write-Host "✗ Порт $port закрыт" -ForegroundColor Red
    }
}

# Проверка логов
Write-Host "`nПоследние логи SQL Server:" -ForegroundColor Cyan
try {
    $sqlLogs = docker logs steam-sqlserver --tail 5 2>$null
    if ($sqlLogs) {
        Write-Host $sqlLogs -ForegroundColor White
    } else {
        Write-Host "Логи SQL Server недоступны" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Не удалось получить логи SQL Server" -ForegroundColor Yellow
}

Write-Host "`nПоследние логи Scrapoxy:" -ForegroundColor Cyan
try {
    $scrapoxyLogs = docker logs steam-scrapoxy --tail 5 2>$null
    if ($scrapoxyLogs) {
        Write-Host $scrapoxyLogs -ForegroundColor White
    } else {
        Write-Host "Логи Scrapoxy недоступны" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Не удалось получить логи Scrapoxy" -ForegroundColor Yellow
}

Write-Host "`n=== Проверка завершена ===" -ForegroundColor Green
