#!/bin/bash
# Bash скрипт для запуска SteamInfrastructure
# Автор: SteamInfrastructure Team
# Дата: 2024

echo "=== SteamInfrastructure Startup Script ==="
echo "Запуск SQL Server и Scrapoxy..."

# Проверка наличия Docker
echo "Проверка Docker..."
if ! command -v docker &> /dev/null; then
    echo "ОШИБКА: Docker не установлен или не доступен!"
    exit 1
fi
echo "Docker найден"

# Создание необходимых директорий
echo "Создание директорий..."
mkdir -p data/sqlserver
echo "Создана директория data/sqlserver"

mkdir -p scrapoxy
echo "Создана директория scrapoxy"

# Проверка переменных окружения
echo "Проверка переменных окружения..."
required_vars=(
    "SQL_SERVER_USERNAME"
    "SQL_SERVER_PASSWORD"
    "SCRAPOXY_USERNAME"
    "SCRAPOXY_PASSWORD"
    "SCRAPOXY_BACKEND_SECRET"
    "SCRAPOXY_FRONTEND_SECRET"
)

missing_vars=()
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
    echo "ОШИБКА: Отсутствуют переменные окружения:"
    for var in "${missing_vars[@]}"; do
        echo "  - $var"
    done
    echo "Установите переменные окружения или используйте GitHub Actions для развертывания"
    exit 1
fi

# Остановка существующих контейнеров (если есть)
echo "Остановка существующих контейнеров..."
docker stop steam-sqlserver steam-scrapoxy 2>/dev/null || true
docker rm steam-sqlserver steam-scrapoxy 2>/dev/null || true

# Запуск SQL Server
echo "Запуск SQL Server..."
docker run -d --name steam-sqlserver \
  -p 1433:1433 \
  -e ACCEPT_EULA=Y \
  -e SA_PASSWORD="$SQL_SERVER_PASSWORD" \
  -e MSSQL_PID=Express \
  -e MSSQL_COLLATION=SQL_Latin1_General_CP1_CI_AS \
  -v "$(pwd)/data/sqlserver:/var/opt/mssql" \
  --restart unless-stopped \
  mcr.microsoft.com/mssql/server:2022-latest

if [ $? -ne 0 ]; then
    echo "ОШИБКА: Не удалось запустить SQL Server!"
    exit 1
fi

echo "SQL Server запущен успешно"

# Ожидание готовности SQL Server
echo "Ожидание готовности SQL Server (30 секунд)..."
sleep 30

# Проверка готовности SQL Server
echo "Проверка готовности SQL Server..."
max_attempts=10
attempt=0
sql_ready=false

while [ $attempt -lt $max_attempts ] && [ "$sql_ready" = false ]; do
    if docker exec steam-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U "$SQL_SERVER_USERNAME" -P "$SQL_SERVER_PASSWORD" -Q "SELECT 1" >/dev/null 2>&1; then
        sql_ready=true
        echo "SQL Server готов к работе"
    else
        attempt=$((attempt + 1))
        echo "Попытка $attempt/$max_attempts - ожидание..."
        sleep 5
    fi
done

if [ "$sql_ready" = false ]; then
    echo "ПРЕДУПРЕЖДЕНИЕ: SQL Server может быть не готов. Продолжаем..."
fi

# Выполнение SQL скрипта инициализации
if [ -f "sql/init.sql" ]; then
    echo "Выполнение SQL скрипта инициализации..."
    docker exec -i steam-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U "$SQL_SERVER_USERNAME" -P "$SQL_SERVER_PASSWORD" < "sql/init.sql"
    if [ $? -eq 0 ]; then
        echo "SQL скрипт выполнен успешно"
    else
        echo "ПРЕДУПРЕЖДЕНИЕ: Ошибка при выполнении SQL скрипта"
    fi
fi

# Создание конфигурации Scrapoxy
echo "Создание конфигурации Scrapoxy..."
cat > scrapoxy/config.json << EOF
{
  "name": "steam-scrapoxy",
  "version": "1.0.0",
  "proxies": [],
  "sessions": []
}
EOF

# Запуск Scrapoxy
echo "Запуск Scrapoxy..."
docker run -d --name steam-scrapoxy \
  -p 8889:8888 -p 8891:8890 \
  -e AUTH_LOCAL_USERNAME="$SCRAPOXY_USERNAME" \
  -e AUTH_LOCAL_PASSWORD="$SCRAPOXY_PASSWORD" \
  -e BACKEND_JWT_SECRET="$SCRAPOXY_BACKEND_SECRET" \
  -e FRONTEND_JWT_SECRET="$SCRAPOXY_FRONTEND_SECRET" \
  -e STORAGE_FILE_FILENAME=/etc/scrapoxy/config.json \
  -v "$(pwd)/scrapoxy:/etc/scrapoxy" \
  --restart unless-stopped \
  scrapoxy/scrapoxy:latest

if [ $? -ne 0 ]; then
    echo "ОШИБКА: Не удалось запустить Scrapoxy!"
    exit 1
fi

echo "Scrapoxy запущен успешно"

# Ожидание готовности Scrapoxy
echo "Ожидание готовности Scrapoxy (10 секунд)..."
sleep 10

# Проверка статуса контейнеров
echo "Проверка статуса контейнеров..."
docker ps --filter "name=steam-"

echo "=== SteamInfrastructure успешно запущен! ==="
echo "Доступные сервисы:"
echo "  - SQL Server: localhost:1433"
echo "  - Scrapoxy API: http://localhost:8889"
echo "  - Scrapoxy Web UI: http://localhost:8891"
echo ""
echo "Для остановки используйте: ./scripts/stop.sh"
