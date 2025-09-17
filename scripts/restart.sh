#!/bin/bash
# Bash скрипт для перезапуска SteamInfrastructure
# Автор: SteamInfrastructure Team
# Дата: 2024

echo "=== SteamInfrastructure Restart Script ==="
echo "Перезапуск SQL Server и Scrapoxy..."

# Проверка наличия Docker
echo "Проверка Docker..."
if ! command -v docker &> /dev/null; then
    echo "ОШИБКА: Docker не установлен или не доступен!"
    exit 1
fi
echo "Docker найден"

# Остановка существующих контейнеров
echo "Остановка существующих контейнеров..."
docker stop steam-sqlserver steam-scrapoxy 2>/dev/null || true
docker rm steam-sqlserver steam-scrapoxy 2>/dev/null || true

# Ожидание завершения остановки
echo "Ожидание завершения остановки (5 секунд)..."
sleep 5

# Запуск сервисов
echo "Запуск сервисов..."
./scripts/start.sh

echo "=== SteamInfrastructure перезапущен! ==="
