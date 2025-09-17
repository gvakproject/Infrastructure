#!/bin/bash
# Bash скрипт для просмотра логов SteamInfrastructure
# Автор: SteamInfrastructure Team
# Дата: 2024

SERVICE="all"
LINES=50
FOLLOW=false

# Парсинг аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--service)
            SERVICE="$2"
            shift 2
            ;;
        -n|--lines)
            LINES="$2"
            shift 2
            ;;
        -f|--follow)
            FOLLOW=true
            shift
            ;;
        -h|--help)
            echo "Использование: $0 [OPTIONS]"
            echo "Опции:"
            echo "  -s, --service SERVICE  Сервис для просмотра логов (sql, scrapoxy, all)"
            echo "  -n, --lines LINES     Количество строк для показа (по умолчанию: 50)"
            echo "  -f, --follow          Показывать логи в реальном времени"
            echo "  -h, --help            Показать эту справку"
            echo ""
            echo "Примеры:"
            echo "  $0                    # Показать все логи"
            echo "  $0 -s sql             # Показать только логи SQL Server"
            echo "  $0 -s scrapoxy -f     # Показать логи Scrapoxy в реальном времени"
            echo "  $0 -n 100             # Показать последние 100 строк"
            exit 0
            ;;
        *)
            echo "Неизвестная опция: $1"
            echo "Используйте -h или --help для справки"
            exit 1
            ;;
    esac
done

echo "=== SteamInfrastructure Logs Viewer ==="

# Проверка наличия Docker
echo "Проверка Docker..."
if ! command -v docker &> /dev/null; then
    echo "ОШИБКА: Docker не установлен или не доступен!"
    exit 1
fi
echo "Docker найден"

# Функция для отображения логов
show_logs() {
    local container_name="$1"
    local service_name="$2"
    
    echo ""
    echo "--- Логи $service_name ---"
    
    if [ "$FOLLOW" = true ]; then
        echo "Показ логов в реальном времени (Ctrl+C для выхода)..."
        docker logs -f --tail "$LINES" "$container_name"
    else
        docker logs --tail "$LINES" "$container_name"
    fi
}

# Отображение логов в зависимости от выбранного сервиса
case "$SERVICE" in
    "sql")
        show_logs "steam-sqlserver" "SQL Server"
        ;;
    "scrapoxy")
        show_logs "steam-scrapoxy" "Scrapoxy"
        ;;
    "all")
        show_logs "steam-sqlserver" "SQL Server"
        show_logs "steam-scrapoxy" "Scrapoxy"
        ;;
    *)
        echo "Неизвестный сервис: $SERVICE"
        echo "Доступные сервисы: sql, scrapoxy, all"
        exit 1
        ;;
esac

echo ""
echo "=== Просмотр логов завершен ==="
