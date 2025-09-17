#!/bin/bash
# Bash скрипт для остановки SteamInfrastructure
# Автор: SteamInfrastructure Team
# Дата: 2024

echo "=== SteamInfrastructure Stop Script ==="
echo "Остановка SQL Server и Scrapoxy..."

# Проверка наличия Docker
echo "Проверка Docker..."
if ! command -v docker &> /dev/null; then
    echo "ОШИБКА: Docker не установлен или не доступен!"
    exit 1
fi
echo "Docker найден"

# Остановка контейнеров
echo "Остановка контейнеров..."

# Остановка SQL Server
echo "Остановка SQL Server..."
if docker ps -q --filter "name=steam-sqlserver" | grep -q .; then
    docker stop steam-sqlserver
    if [ $? -eq 0 ]; then
        echo "SQL Server остановлен"
    else
        echo "ОШИБКА: Не удалось остановить SQL Server!"
    fi
else
    echo "SQL Server не запущен"
fi

# Остановка Scrapoxy
echo "Остановка Scrapoxy..."
if docker ps -q --filter "name=steam-scrapoxy" | grep -q .; then
    docker stop steam-scrapoxy
    if [ $? -eq 0 ]; then
        echo "Scrapoxy остановлен"
    else
        echo "ОШИБКА: Не удалось остановить Scrapoxy!"
    fi
else
    echo "Scrapoxy не запущен"
fi

# Удаление контейнеров
echo "Удаление контейнеров..."

# Удаление SQL Server контейнера
if docker ps -a -q --filter "name=steam-sqlserver" | grep -q .; then
    docker rm steam-sqlserver
    if [ $? -eq 0 ]; then
        echo "Контейнер SQL Server удален"
    else
        echo "ОШИБКА: Не удалось удалить контейнер SQL Server!"
    fi
else
    echo "Контейнер SQL Server не найден"
fi

# Удаление Scrapoxy контейнера
if docker ps -a -q --filter "name=steam-scrapoxy" | grep -q .; then
    docker rm steam-scrapoxy
    if [ $? -eq 0 ]; then
        echo "Контейнер Scrapoxy удален"
    else
        echo "ОШИБКА: Не удалось удалить контейнер Scrapoxy!"
    fi
else
    echo "Контейнер Scrapoxy не найден"
fi

# Проверка статуса
echo "Проверка статуса контейнеров..."
running_containers=$(docker ps --filter "name=steam-")
if [ -n "$running_containers" ]; then
    echo "Запущенные контейнеры:"
    echo "$running_containers"
else
    echo "Нет запущенных контейнеров SteamInfrastructure"
fi

echo "=== SteamInfrastructure остановлен! ==="
echo "Для запуска используйте: ./scripts/start.sh"
