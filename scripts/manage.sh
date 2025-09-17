#!/bin/bash
# Bash скрипт для управления SteamInfrastructure
# Автор: SteamInfrastructure Team
# Дата: 2024

ACTION="${1:-help}"

echo "=== SteamInfrastructure Management Script ==="

# Функция для отображения справки
show_help() {
    echo ""
    echo "Использование: ./scripts/manage.sh [ACTION]"
    echo ""
    echo "Доступные действия:"
    echo "  start     - Запустить все сервисы"
    echo "  stop      - Остановить все сервисы"
    echo "  restart   - Перезапустить все сервисы"
    echo "  status    - Показать статус сервисов"
    echo "  logs      - Показать логи сервисов"
    echo "  backup    - Создать резервную копию"
    echo "  cleanup   - Очистить Docker ресурсы"
    echo "  help      - Показать эту справку"
    echo ""
    echo "Примеры:"
    echo "  ./scripts/manage.sh start"
    echo "  ./scripts/manage.sh status"
    echo "  ./scripts/manage.sh logs -s sql"
    echo "  ./scripts/manage.sh backup --include-data"
}

# Проверка наличия Docker
echo "Проверка Docker..."
if ! command -v docker &> /dev/null; then
    echo "ОШИБКА: Docker не установлен или не доступен!"
    exit 1
fi
echo "Docker найден"

# Выполнение действия
case "$ACTION" in
    "start")
        echo ""
        echo "Запуск SteamInfrastructure..."
        ./scripts/start.sh
        ;;
    "stop")
        echo ""
        echo "Остановка SteamInfrastructure..."
        ./scripts/stop.sh
        ;;
    "restart")
        echo ""
        echo "Перезапуск SteamInfrastructure..."
        ./scripts/restart.sh
        ;;
    "status")
        echo ""
        echo "Проверка статуса SteamInfrastructure..."
        ./scripts/status.sh
        ;;
    "logs")
        echo ""
        echo "Просмотр логов SteamInfrastructure..."
        shift
        ./scripts/logs.sh "$@"
        ;;
    "backup")
        echo ""
        echo "Создание резервной копии SteamInfrastructure..."
        shift
        ./scripts/backup.sh "$@"
        ;;
    "cleanup")
        echo ""
        echo "Очистка Docker ресурсов..."
        shift
        ./scripts/cleanup.sh "$@"
        ;;
    "help")
        show_help
        ;;
    *)
        echo ""
        echo "Неизвестное действие: $ACTION"
        show_help
        exit 1
        ;;
esac

echo ""
echo "=== Управление завершено! ==="
