#!/bin/bash
# Bash скрипт для резервного копирования SteamInfrastructure
# Автор: SteamInfrastructure Team
# Дата: 2024

BACKUP_DIR="./backups"
INCLUDE_DATA=false
INCLUDE_CONFIG=false

# Парсинг аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            BACKUP_DIR="$2"
            shift 2
            ;;
        --include-data)
            INCLUDE_DATA=true
            shift
            ;;
        --include-config)
            INCLUDE_CONFIG=true
            shift
            ;;
        -h|--help)
            echo "Использование: $0 [OPTIONS]"
            echo "Опции:"
            echo "  -d, --dir DIR        Директория для резервных копий (по умолчанию: ./backups)"
            echo "  --include-data       Включить данные SQL Server"
            echo "  --include-config     Включить конфигурацию Scrapoxy"
            echo "  -h, --help           Показать эту справку"
            echo ""
            echo "Примеры:"
            echo "  $0                                    # Базовое резервное копирование"
            echo "  $0 --include-data --include-config   # Полное резервное копирование"
            echo "  $0 -d /backups --include-data        # Резервное копирование в /backups с данными"
            exit 0
            ;;
        *)
            echo "Неизвестная опция: $1"
            echo "Используйте -h или --help для справки"
            exit 1
            ;;
    esac
done

echo "=== SteamInfrastructure Backup Script ==="

# Проверка наличия Docker
echo "Проверка Docker..."
if ! command -v docker &> /dev/null; then
    echo "ОШИБКА: Docker не установлен или не доступен!"
    exit 1
fi
echo "Docker найден"

# Создание директории для резервных копий
timestamp=$(date +%Y%m%d_%H%M%S)
backup_path="$BACKUP_DIR/steam-infrastructure_$timestamp"

echo "Создание директории для резервной копии: $backup_path"
mkdir -p "$backup_path"

# Резервное копирование SQL Server
echo ""
echo "--- Резервное копирование SQL Server ---"

# Проверка доступности SQL Server
if docker ps -q --filter "name=steam-sqlserver" | grep -q .; then
    echo "Создание резервной копии базы данных..."
    
    # Создание директории для резервной копии в контейнере
    docker exec steam-sqlserver mkdir -p /var/opt/mssql/backup
    
    # Создание резервной копии
    backup_filename="SteamInfrastructure_$timestamp.bak"
    backup_command="BACKUP DATABASE SteamInfrastructure TO DISK = '/var/opt/mssql/backup/$backup_filename'"
    
    if docker exec steam-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U "$SQL_SERVER_USERNAME" -P "$SQL_SERVER_PASSWORD" -Q "$backup_command" >/dev/null 2>&1; then
        echo "Резервная копия базы данных создана: $backup_filename"
        
        # Копирование файла резервной копии
        docker cp "steam-sqlserver:/var/opt/mssql/backup/$backup_filename" "$backup_path/"
        echo "Файл резервной копии скопирован"
    else
        echo "ОШИБКА: Не удалось создать резервную копию базы данных"
    fi
else
    echo "SQL Server не запущен, пропускаем резервное копирование базы данных"
fi

# Резервное копирование данных SQL Server
if [ "$INCLUDE_DATA" = true ]; then
    echo ""
    echo "--- Резервное копирование данных SQL Server ---"
    
    data_backup_path="$backup_path/sqlserver_data"
    mkdir -p "$data_backup_path"
    
    if [ -d "data/sqlserver" ]; then
        cp -r data/sqlserver/* "$data_backup_path/"
        echo "Данные SQL Server скопированы"
    else
        echo "Директория данных SQL Server не найдена"
    fi
fi

# Резервное копирование конфигурации Scrapoxy
if [ "$INCLUDE_CONFIG" = true ]; then
    echo ""
    echo "--- Резервное копирование конфигурации Scrapoxy ---"
    
    scrapoxy_backup_path="$backup_path/scrapoxy_config"
    mkdir -p "$scrapoxy_backup_path"
    
    if [ -d "scrapoxy" ]; then
        cp -r scrapoxy/* "$scrapoxy_backup_path/"
        echo "Конфигурация Scrapoxy скопирована"
    else
        echo "Директория конфигурации Scrapoxy не найдена"
    fi
fi

# Резервное копирование скриптов
echo ""
echo "--- Резервное копирование скриптов ---"

scripts_backup_path="$backup_path/scripts"
mkdir -p "$scripts_backup_path"

if [ -d "scripts" ]; then
    cp -r scripts/* "$scripts_backup_path/"
    echo "Скрипты скопированы"
else
    echo "Директория скриптов не найдена"
fi

# Резервное копирование SQL скриптов
echo ""
echo "--- Резервное копирование SQL скриптов ---"

sql_backup_path="$backup_path/sql"
mkdir -p "$sql_backup_path"

if [ -d "sql" ]; then
    cp -r sql/* "$sql_backup_path/"
    echo "SQL скрипты скопированы"
else
    echo "Директория SQL скриптов не найдена"
fi

# Создание архива
echo ""
echo "--- Создание архива ---"

archive_path="$backup_path.tar.gz"
if tar -czf "$archive_path" -C "$(dirname "$backup_path")" "$(basename "$backup_path")" 2>/dev/null; then
    echo "Архив создан: $archive_path"
    
    # Удаление временной директории
    rm -rf "$backup_path"
    echo "Временная директория удалена"
else
    echo "ОШИБКА: Не удалось создать архив"
    echo "Резервная копия сохранена в: $backup_path"
fi

# Показ информации о резервной копии
echo ""
echo "--- Информация о резервной копии ---"

if [ -f "$archive_path" ]; then
    archive_size=$(du -h "$archive_path" | cut -f1)
    echo "Размер архива: $archive_size"
    echo "Путь к архиву: $archive_path"
else
    echo "Путь к резервной копии: $backup_path"
fi

echo ""
echo "=== Резервное копирование завершено! ==="
