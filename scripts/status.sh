#!/bin/bash
# Bash скрипт для проверки статуса SteamInfrastructure
# Автор: SteamInfrastructure Team
# Дата: 2024

echo "=== SteamInfrastructure Status Check ==="

# Проверка наличия Docker
echo "Проверка Docker..."
if ! command -v docker &> /dev/null; then
    echo "ОШИБКА: Docker не установлен или не доступен!"
    exit 1
fi
echo "Docker найден"

# Проверка статуса контейнеров
echo ""
echo "Статус контейнеров:"
containers=$(docker ps --filter "name=steam-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}")
if [ -n "$containers" ]; then
    echo "$containers"
else
    echo "Нет запущенных контейнеров SteamInfrastructure"
fi

# Проверка SQL Server
echo ""
echo "Проверка SQL Server:"
if docker ps -q --filter "name=steam-sqlserver" | grep -q .; then
    echo "✓ SQL Server контейнер запущен"
    
    # Проверка доступности SQL Server
    if docker exec steam-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U "$SQL_SERVER_USERNAME" -P "$SQL_SERVER_PASSWORD" -Q "SELECT @@VERSION" >/dev/null 2>&1; then
        echo "✓ SQL Server доступен и отвечает"
    else
        echo "✗ SQL Server не отвечает на запросы"
    fi
else
    echo "✗ SQL Server контейнер не запущен"
fi

# Проверка Scrapoxy
echo ""
echo "Проверка Scrapoxy:"
if docker ps -q --filter "name=steam-scrapoxy" | grep -q .; then
    echo "✓ Scrapoxy контейнер запущен"
    
    # Проверка доступности Scrapoxy API
    if curl -s http://localhost:8889/api/health >/dev/null 2>&1; then
        echo "✓ Scrapoxy API доступен"
    else
        echo "✗ Scrapoxy API недоступен"
    fi
    
    # Проверка доступности Scrapoxy Web UI
    if curl -s http://localhost:8891 >/dev/null 2>&1; then
        echo "✓ Scrapoxy Web UI доступен"
    else
        echo "✗ Scrapoxy Web UI недоступен"
    fi
else
    echo "✗ Scrapoxy контейнер не запущен"
fi

# Проверка портов
echo ""
echo "Проверка портов:"
ports=(1433 8889 8891)
for port in "${ports[@]}"; do
    if netstat -tlnp 2>/dev/null | grep -q ":$port "; then
        echo "✓ Порт $port открыт"
    elif ss -tlnp 2>/dev/null | grep -q ":$port "; then
        echo "✓ Порт $port открыт"
    else
        echo "✗ Порт $port закрыт"
    fi
done

# Проверка логов
echo ""
echo "Последние логи SQL Server:"
if docker logs steam-sqlserver --tail 5 2>/dev/null; then
    echo ""
else
    echo "Логи SQL Server недоступны"
fi

echo ""
echo "Последние логи Scrapoxy:"
if docker logs steam-scrapoxy --tail 5 2>/dev/null; then
    echo ""
else
    echo "Логи Scrapoxy недоступны"
fi

echo "=== Проверка завершена ==="
