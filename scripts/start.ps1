# PowerShell скрипт для запуска SteamInfrastructure
# Автор: SteamInfrastructure Team
# Дата: 2024

Write-Host "=== SteamInfrastructure Startup Script ===" -ForegroundColor Green
Write-Host "Запуск SQL Server и Scrapoxy..." -ForegroundColor Yellow

# Проверка наличия Docker
Write-Host "Проверка Docker..." -ForegroundColor Cyan
try {
    docker --version | Out-Null
    Write-Host "Docker найден" -ForegroundColor Green
} catch {
    Write-Host "ОШИБКА: Docker не установлен или не доступен!" -ForegroundColor Red
    exit 1
}

# Создание необходимых директорий
Write-Host "Создание директорий..." -ForegroundColor Cyan
if (!(Test-Path "data\sqlserver")) {
    New-Item -ItemType Directory -Path "data\sqlserver" -Force | Out-Null
    Write-Host "Создана директория data\sqlserver" -ForegroundColor Green
}

if (!(Test-Path "scrapoxy")) {
    New-Item -ItemType Directory -Path "scrapoxy" -Force | Out-Null
    Write-Host "Создана директория scrapoxy" -ForegroundColor Green
}

# Проверка переменных окружения
Write-Host "Проверка переменных окружения..." -ForegroundColor Cyan
$envVars = @(
    "SQL_SERVER_USERNAME",
    "SQL_SERVER_PASSWORD",
    "SCRAPOXY_USERNAME", 
    "SCRAPOXY_PASSWORD",
    "SCRAPOXY_BACKEND_SECRET",
    "SCRAPOXY_FRONTEND_SECRET"
)

$missingVars = @()
foreach ($var in $envVars) {
    if (-not (Get-Item "env:$var" -ErrorAction SilentlyContinue)) {
        $missingVars += $var
    }
}

if ($missingVars.Count -gt 0) {
    Write-Host "ОШИБКА: Отсутствуют переменные окружения:" -ForegroundColor Red
    $missingVars | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Host "Установите переменные окружения или используйте GitHub Actions для развертывания" -ForegroundColor Yellow
    exit 1
}

# Остановка существующих контейнеров (если есть)
Write-Host "Остановка существующих контейнеров..." -ForegroundColor Cyan
docker stop steam-sqlserver steam-scrapoxy 2>$null
docker rm steam-sqlserver steam-scrapoxy 2>$null

# Запуск SQL Server
Write-Host "Запуск SQL Server..." -ForegroundColor Cyan
docker run -d --name steam-sqlserver `
  -p 1433:1433 `
  -e ACCEPT_EULA=Y `
  -e SA_PASSWORD=$env:SQL_SERVER_PASSWORD `
  -e MSSQL_PID=Express `
  -e MSSQL_COLLATION=SQL_Latin1_General_CP1_CI_AS `
  -v "${PWD}\data\sqlserver:/var/opt/mssql" `
  --restart unless-stopped `
  mcr.microsoft.com/mssql/server:2022-latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "ОШИБКА: Не удалось запустить SQL Server!" -ForegroundColor Red
    exit 1
}

Write-Host "SQL Server запущен успешно" -ForegroundColor Green

# Ожидание готовности SQL Server
Write-Host "Ожидание готовности SQL Server (30 секунд)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Проверка готовности SQL Server
Write-Host "Проверка готовности SQL Server..." -ForegroundColor Cyan
$maxAttempts = 10
$attempt = 0
$sqlReady = $false

while ($attempt -lt $maxAttempts -and -not $sqlReady) {
    try {
        $result = docker exec steam-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U $env:SQL_SERVER_USERNAME -P $env:SQL_SERVER_PASSWORD -Q "SELECT 1" 2>$null
        if ($LASTEXITCODE -eq 0) {
            $sqlReady = $true
            Write-Host "SQL Server готов к работе" -ForegroundColor Green
        }
    } catch {
        # Игнорируем ошибки
    }
    
    if (-not $sqlReady) {
        $attempt++
        Write-Host "Попытка $attempt/$maxAttempts - ожидание..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    }
}

if (-not $sqlReady) {
    Write-Host "ПРЕДУПРЕЖДЕНИЕ: SQL Server может быть не готов. Продолжаем..." -ForegroundColor Yellow
}

# Выполнение SQL скрипта инициализации
if (Test-Path "sql\init.sql") {
    Write-Host "Выполнение SQL скрипта инициализации..." -ForegroundColor Cyan
    docker exec -i steam-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U $env:SQL_SERVER_USERNAME -P $env:SQL_SERVER_PASSWORD < "sql\init.sql"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SQL скрипт выполнен успешно" -ForegroundColor Green
    } else {
        Write-Host "ПРЕДУПРЕЖДЕНИЕ: Ошибка при выполнении SQL скрипта" -ForegroundColor Yellow
    }
}

# Создание конфигурации Scrapoxy
Write-Host "Создание конфигурации Scrapoxy..." -ForegroundColor Cyan
$scrapoxyConfig = @{
    "name" = "steam-scrapoxy"
    "version" = "1.0.0"
    "proxies" = @()
    "sessions" = @()
} | ConvertTo-Json -Depth 3

$scrapoxyConfig | Out-File -FilePath "scrapoxy\config.json" -Encoding UTF8

# Запуск Scrapoxy
Write-Host "Запуск Scrapoxy..." -ForegroundColor Cyan
docker run -d --name steam-scrapoxy `
  -p 8889:8888 -p 8891:8890 `
  -e AUTH_LOCAL_USERNAME=$env:SCRAPOXY_USERNAME `
  -e AUTH_LOCAL_PASSWORD=$env:SCRAPOXY_PASSWORD `
  -e BACKEND_JWT_SECRET=$env:SCRAPOXY_BACKEND_SECRET `
  -e FRONTEND_JWT_SECRET=$env:SCRAPOXY_FRONTEND_SECRET `
  -e STORAGE_FILE_FILENAME=/etc/scrapoxy/config.json `
  -v "${PWD}\scrapoxy:/etc/scrapoxy" `
  --restart unless-stopped `
  scrapoxy/scrapoxy:latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "ОШИБКА: Не удалось запустить Scrapoxy!" -ForegroundColor Red
    exit 1
}

Write-Host "Scrapoxy запущен успешно" -ForegroundColor Green

# Ожидание готовности Scrapoxy
Write-Host "Ожидание готовности Scrapoxy (10 секунд)..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Проверка статуса контейнеров
Write-Host "Проверка статуса контейнеров..." -ForegroundColor Cyan
docker ps --filter "name=steam-"

Write-Host "=== SteamInfrastructure успешно запущен! ===" -ForegroundColor Green
Write-Host "Доступные сервисы:" -ForegroundColor Yellow
Write-Host "  - SQL Server: localhost:1433" -ForegroundColor White
Write-Host "  - Scrapoxy API: http://localhost:8889" -ForegroundColor White
Write-Host "  - Scrapoxy Web UI: http://localhost:8891" -ForegroundColor White
Write-Host ""
Write-Host "Для остановки используйте: .\scripts\stop.ps1" -ForegroundColor Cyan
