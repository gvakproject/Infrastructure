#!/bin/bash
# Bash скрипт для очистки и обслуживания SteamInfrastructure
# Автор: SteamInfrastructure Team
# Дата: 2024

ALL=false
CONTAINERS=false
IMAGES=false
VOLUMES=false
NETWORKS=false
SYSTEM=false

# Парсинг аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            ALL=true
            shift
            ;;
        --containers)
            CONTAINERS=true
            shift
            ;;
        --images)
            IMAGES=true
            shift
            ;;
        --volumes)
            VOLUMES=true
            shift
            ;;
        --networks)
            NETWORKS=true
            shift
            ;;
        --system)
            SYSTEM=true
            shift
            ;;
        -h|--help)
            echo "Использование: $0 [OPTIONS]"
            echo "Опции:"
            echo "  --all         Выполнить все виды очистки"
            echo "  --containers  Очистить контейнеры"
            echo "  --images      Очистить образы"
            echo "  --volumes     Очистить тома"
            echo "  --networks    Очистить сети"
            echo "  --system      Полная очистка системы"
            echo "  -h, --help    Показать эту справку"
            echo ""
            echo "Примеры:"
            echo "  $0 --all                    # Выполнить все виды очистки"
            echo "  $0 --containers --images    # Очистить контейнеры и образы"
            echo "  $0 --system                 # Полная очистка системы"
            exit 0
            ;;
        *)
            echo "Неизвестная опция: $1"
            echo "Используйте -h или --help для справки"
            exit 1
            ;;
    esac
done

echo "=== SteamInfrastructure Cleanup Script ==="

# Проверка наличия Docker
echo "Проверка Docker..."
if ! command -v docker &> /dev/null; then
    echo "ОШИБКА: Docker не установлен или не доступен!"
    exit 1
fi
echo "Docker найден"

# Функция для подтверждения действия
confirm_action() {
    local message="$1"
    read -p "$message (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Очистка контейнеров
if [ "$ALL" = true ] || [ "$CONTAINERS" = true ]; then
    echo ""
    echo "--- Очистка контейнеров ---"
    
    # Остановка контейнеров SteamInfrastructure
    echo "Остановка контейнеров SteamInfrastructure..."
    docker stop steam-sqlserver steam-scrapoxy 2>/dev/null || true
    docker rm steam-sqlserver steam-scrapoxy 2>/dev/null || true
    
    # Очистка всех остановленных контейнеров
    if confirm_action "Удалить все остановленные контейнеры?"; then
        stopped_containers=$(docker container ls -a --filter "status=exited" -q)
        if [ -n "$stopped_containers" ]; then
            echo "$stopped_containers" | xargs docker container rm
            echo "Остановленные контейнеры удалены"
        else
            echo "Нет остановленных контейнеров"
        fi
    fi
fi

# Очистка образов
if [ "$ALL" = true ] || [ "$IMAGES" = true ]; then
    echo ""
    echo "--- Очистка образов ---"
    
    if confirm_action "Удалить неиспользуемые образы?"; then
        docker image prune -f
        echo "Неиспользуемые образы удалены"
    fi
    
    if confirm_action "Удалить все неиспользуемые образы (включая теги)?"; then
        docker image prune -a -f
        echo "Все неиспользуемые образы удалены"
    fi
fi

# Очистка томов
if [ "$ALL" = true ] || [ "$VOLUMES" = true ]; then
    echo ""
    echo "--- Очистка томов ---"
    
    if confirm_action "Удалить неиспользуемые тома?"; then
        docker volume prune -f
        echo "Неиспользуемые тома удалены"
    fi
fi

# Очистка сетей
if [ "$ALL" = true ] || [ "$NETWORKS" = true ]; then
    echo ""
    echo "--- Очистка сетей ---"
    
    if confirm_action "Удалить неиспользуемые сети?"; then
        docker network prune -f
        echo "Неиспользуемые сети удалены"
    fi
fi

# Полная очистка системы
if [ "$ALL" = true ] || [ "$SYSTEM" = true ]; then
    echo ""
    echo "--- Полная очистка системы ---"
    
    if confirm_action "Выполнить полную очистку Docker системы?"; then
        docker system prune -a -f --volumes
        echo "Полная очистка системы выполнена"
    fi
fi

# Показ статистики
echo ""
echo "--- Статистика Docker ---"
docker system df

echo ""
echo "=== Очистка завершена! ==="
