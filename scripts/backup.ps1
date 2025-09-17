# PowerShell скрипт для резервного копирования SteamInfrastructure
# Автор: SteamInfrastructure Team
# Дата: 2024

param(
    [string]$BackupDir = ".\backups",
    [switch]$IncludeData,
    [switch]$IncludeConfig
)

Write-Host "=== SteamInfrastructure Backup Script ===" -ForegroundColor Green

# Проверка наличия Docker
Write-Host "Проверка Docker..." -ForegroundColor Cyan
try {
    docker --version | Out-Null
    Write-Host "Docker найден" -ForegroundColor Green
} catch {
    Write-Host "ОШИБКА: Docker не установлен или не доступен!" -ForegroundColor Red
    exit 1
}

# Создание директории для резервных копий
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupPath = Join-Path $BackupDir "steam-infrastructure_$timestamp"

Write-Host "Создание директории для резервной копии: $backupPath" -ForegroundColor Cyan
New-Item -ItemType Directory -Path $backupPath -Force | Out-Null

# Резервное копирование SQL Server
Write-Host "`n--- Резервное копирование SQL Server ---" -ForegroundColor Yellow

# Проверка доступности SQL Server
$sqlServerRunning = docker ps -q --filter "name=steam-sqlserver"
if ($sqlServerRunning) {
    Write-Host "Создание резервной копии базы данных..." -ForegroundColor Cyan
    
    # Создание директории для резервной копии в контейнере
    docker exec steam-sqlserver mkdir -p /var/opt/mssql/backup
    
    # Создание резервной копии
    $backupFileName = "SteamInfrastructure_$timestamp.bak"
    $backupCommand = "BACKUP DATABASE SteamInfrastructure TO DISK = '/var/opt/mssql/backup/$backupFileName'"
    
    try {
        docker exec steam-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U $env:SQL_SERVER_USERNAME -P $env:SQL_SERVER_PASSWORD -Q $backupCommand
        Write-Host "Резервная копия базы данных создана: $backupFileName" -ForegroundColor Green
        
        # Копирование файла резервной копии
        docker cp "steam-sqlserver:/var/opt/mssql/backup/$backupFileName" "$backupPath\"
        Write-Host "Файл резервной копии скопирован" -ForegroundColor Green
    } catch {
        Write-Host "ОШИБКА: Не удалось создать резервную копию базы данных" -ForegroundColor Red
    }
} else {
    Write-Host "SQL Server не запущен, пропускаем резервное копирование базы данных" -ForegroundColor Yellow
}

# Резервное копирование данных SQL Server
if ($IncludeData) {
    Write-Host "`n--- Резервное копирование данных SQL Server ---" -ForegroundColor Yellow
    
    $dataBackupPath = Join-Path $backupPath "sqlserver_data"
    New-Item -ItemType Directory -Path $dataBackupPath -Force | Out-Null
    
    if (Test-Path "data\sqlserver") {
        Copy-Item -Path "data\sqlserver\*" -Destination $dataBackupPath -Recurse -Force
        Write-Host "Данные SQL Server скопированы" -ForegroundColor Green
    } else {
        Write-Host "Директория данных SQL Server не найдена" -ForegroundColor Yellow
    }
}

# Резервное копирование конфигурации Scrapoxy
if ($IncludeConfig) {
    Write-Host "`n--- Резервное копирование конфигурации Scrapoxy ---" -ForegroundColor Yellow
    
    $scrapoxyBackupPath = Join-Path $backupPath "scrapoxy_config"
    New-Item -ItemType Directory -Path $scrapoxyBackupPath -Force | Out-Null
    
    if (Test-Path "scrapoxy") {
        Copy-Item -Path "scrapoxy\*" -Destination $scrapoxyBackupPath -Recurse -Force
        Write-Host "Конфигурация Scrapoxy скопирована" -ForegroundColor Green
    } else {
        Write-Host "Директория конфигурации Scrapoxy не найдена" -ForegroundColor Yellow
    }
}

# Резервное копирование скриптов
Write-Host "`n--- Резервное копирование скриптов ---" -ForegroundColor Yellow

$scriptsBackupPath = Join-Path $backupPath "scripts"
New-Item -ItemType Directory -Path $scriptsBackupPath -Force | Out-Null

if (Test-Path "scripts") {
    Copy-Item -Path "scripts\*" -Destination $scriptsBackupPath -Recurse -Force
    Write-Host "Скрипты скопированы" -ForegroundColor Green
} else {
    Write-Host "Директория скриптов не найдена" -ForegroundColor Yellow
}

# Резервное копирование SQL скриптов
Write-Host "`n--- Резервное копирование SQL скриптов ---" -ForegroundColor Yellow

$sqlBackupPath = Join-Path $backupPath "sql"
New-Item -ItemType Directory -Path $sqlBackupPath -Force | Out-Null

if (Test-Path "sql") {
    Copy-Item -Path "sql\*" -Destination $sqlBackupPath -Recurse -Force
    Write-Host "SQL скрипты скопированы" -ForegroundColor Green
} else {
    Write-Host "Директория SQL скриптов не найдена" -ForegroundColor Yellow
}

# Создание архива
Write-Host "`n--- Создание архива ---" -ForegroundColor Yellow

$archivePath = "$backupPath.zip"
try {
    Compress-Archive -Path $backupPath -DestinationPath $archivePath -Force
    Write-Host "Архив создан: $archivePath" -ForegroundColor Green
    
    # Удаление временной директории
    Remove-Item -Path $backupPath -Recurse -Force
    Write-Host "Временная директория удалена" -ForegroundColor Green
} catch {
    Write-Host "ОШИБКА: Не удалось создать архив" -ForegroundColor Red
    Write-Host "Резервная копия сохранена в: $backupPath" -ForegroundColor Yellow
}

# Показ информации о резервной копии
Write-Host "`n--- Информация о резервной копии ---" -ForegroundColor Yellow

if (Test-Path $archivePath) {
    $archiveSize = (Get-Item $archivePath).Length
    $archiveSizeMB = [math]::Round($archiveSize / 1MB, 2)
    Write-Host "Размер архива: $archiveSizeMB MB" -ForegroundColor White
    Write-Host "Путь к архиву: $archivePath" -ForegroundColor White
} else {
    Write-Host "Путь к резервной копии: $backupPath" -ForegroundColor White
}

Write-Host "`n=== Резервное копирование завершено! ===" -ForegroundColor Green
