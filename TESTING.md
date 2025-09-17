# Тестирование SteamInfrastructure

Руководство по тестированию всех компонентов SteamInfrastructure.

## Подготовка к тестированию

### 1. Запуск сервисов
```bash
# Windows PowerShell
.\scripts\start.ps1

# Linux/macOS Bash
./scripts/start.sh
```

### 2. Проверка статуса
```bash
# Windows PowerShell
.\scripts\status.ps1

# Linux/macOS Bash
./scripts/status.sh
```

## Тестирование SQL Server

### 1. Проверка подключения
```bash
# Подключение через Docker
docker exec -it steam-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "SteamSQL_2024_Secret!"
```

### 2. Проверка базы данных
```sql
-- Проверка версии SQL Server
SELECT @@VERSION;

-- Проверка базы данных
SELECT name FROM sys.databases WHERE name = 'SteamInfrastructure';

-- Проверка таблиц
USE SteamInfrastructure;
SELECT name FROM sys.tables;
```

### 3. Тестирование таблиц
```sql
-- Проверка таблицы ProxyServers
SELECT COUNT(*) as ProxyCount FROM ProxyServers;

-- Проверка таблицы Sessions
SELECT COUNT(*) as SessionCount FROM Sessions;

-- Проверка таблицы Logs
SELECT COUNT(*) as LogCount FROM Logs;
```

### 4. Тестирование хранимых процедур
```sql
-- Тест GetActiveProxies
EXEC GetActiveProxies;

-- Тест CleanupExpiredSessions
EXEC CleanupExpiredSessions;
```

### 5. Тестирование вставки данных
```sql
-- Вставка тестового прокси
INSERT INTO ProxyServers (Name, Host, Port, Username, Password, IsActive)
VALUES ('Test Proxy', 'test.example.com', 8080, 'testuser', 'testpass', 1);

-- Вставка тестовой сессии
INSERT INTO Sessions (SessionId, ProxyId, UserAgent, IsActive, ExpiresAt)
VALUES ('test_session_123', 1, 'Mozilla/5.0 Test Browser', 1, DATEADD(hour, 1, GETUTCDATE()));

-- Вставка тестового лога
INSERT INTO Logs (Level, Message, Source)
VALUES ('INFO', 'Test log message', 'TestScript');
```

## Тестирование Scrapoxy

### 1. Проверка API
```bash
# Проверка здоровья API
curl -u "steam_admin_2024:SteamInfra_2024_Secret!" \
  http://localhost:8889/api/health

# Получение информации о проекте
curl -u "steam_admin_2024:SteamInfra_2024_Secret!" \
  http://localhost:8889/api/project
```

### 2. Тестирование Web UI
```bash
# Проверка доступности Web UI
curl -I http://localhost:8891

# Открыть в браузере
# http://localhost:8891
# Username: steam_admin_2024
# Password: SteamInfra_2024_Secret!
```

### 3. Тестирование управления прокси
```bash
# Получение списка прокси
curl -u "steam_admin_2024:SteamInfra_2024_Secret!" \
  http://localhost:8889/api/proxies

# Добавление прокси
curl -X POST \
  -u "steam_admin_2024:SteamInfra_2024_Secret!" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "test_proxy",
    "host": "test.example.com",
    "port": 8080,
    "username": "testuser",
    "password": "testpass"
  }' \
  http://localhost:8889/api/proxies
```

### 4. Тестирование управления сессиями
```bash
# Получение списка сессий
curl -u "steam_admin_2024:SteamInfra_2024_Secret!" \
  http://localhost:8889/api/sessions

# Создание сессии
curl -X POST \
  -u "steam_admin_2024:SteamInfra_2024_Secret!" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "test_session",
    "userAgent": "Mozilla/5.0 Test Browser"
  }' \
  http://localhost:8889/api/sessions
```

## Тестирование интеграции

### 1. Тест связи SQL Server ↔ Scrapoxy
```python
# Python скрипт для тестирования интеграции
import requests
import sqlalchemy
from sqlalchemy import create_engine, text

# SQL Server подключение
engine = create_engine('mssql+pyodbc://sa:SteamSQL_2024_Secret!@localhost:1433/SteamInfrastructure?driver=ODBC+Driver+17+for+SQL+Server')

# Scrapoxy API
scrapoxy_auth = ('steam_admin_2024', 'SteamInfra_2024_Secret!')
scrapoxy_base_url = 'http://localhost:8889'

def test_sql_connection():
    try:
        with engine.connect() as conn:
            result = conn.execute(text("SELECT @@VERSION"))
            version = result.fetchone()[0]
            print(f"✓ SQL Server подключен: {version[:50]}...")
            return True
    except Exception as e:
        print(f"✗ Ошибка SQL Server: {e}")
        return False

def test_scrapoxy_api():
    try:
        response = requests.get(f"{scrapoxy_base_url}/api/health", auth=scrapoxy_auth)
        if response.status_code == 200:
            print("✓ Scrapoxy API доступен")
            return True
        else:
            print(f"✗ Scrapoxy API недоступен: {response.status_code}")
            return False
    except Exception as e:
        print(f"✗ Ошибка Scrapoxy API: {e}")
        return False

if __name__ == "__main__":
    print("=== Тестирование интеграции ===")
    sql_ok = test_sql_connection()
    scrapoxy_ok = test_scrapoxy_api()
    
    if sql_ok and scrapoxy_ok:
        print("✓ Все сервисы работают корректно")
    else:
        print("✗ Обнаружены проблемы")
```

### 2. Тест производительности
```bash
# Тест нагрузки на SQL Server
for i in {1..100}; do
  docker exec steam-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "SteamSQL_2024_Secret!" -Q "SELECT COUNT(*) FROM ProxyServers" >/dev/null 2>&1
  echo "Запрос $i выполнен"
done

# Тест нагрузки на Scrapoxy API
for i in {1..100}; do
  curl -s -u "steam_admin_2024:SteamInfra_2024_Secret!" http://localhost:8889/api/health >/dev/null
  echo "API запрос $i выполнен"
done
```

## Тестирование скриптов управления

### 1. Тест скрипта запуска
```bash
# Остановка сервисов
./scripts/stop.sh

# Запуск сервисов
./scripts/start.sh

# Проверка статуса
./scripts/status.sh
```

### 2. Тест скрипта перезапуска
```bash
# Перезапуск сервисов
./scripts/restart.sh

# Проверка статуса
./scripts/status.sh
```

### 3. Тест скрипта логов
```bash
# Просмотр логов SQL Server
./scripts/logs.sh -s sql -n 10

# Просмотр логов Scrapoxy
./scripts/logs.sh -s scrapoxy -n 10

# Просмотр всех логов
./scripts/logs.sh -n 5
```

### 4. Тест скрипта резервного копирования
```bash
# Создание резервной копии
./scripts/backup.sh --include-data --include-config

# Проверка создания архива
ls -la backups/
```

### 5. Тест скрипта очистки
```bash
# Очистка Docker ресурсов
./scripts/cleanup.sh --containers --images

# Проверка очистки
docker system df
```

## Тестирование GitHub Actions

### 1. Проверка workflow файла
```bash
# Проверка синтаксиса YAML
yamllint .github/workflows/deploy.yml
```

### 2. Тест локального развертывания
```bash
# Симуляция развертывания
mkdir -p test_deploy
cp -r * test_deploy/
cd test_deploy

# Запуск сервисов
./scripts/start.sh

# Проверка статуса
./scripts/status.sh

# Остановка сервисов
./scripts/stop.sh
cd ..
rm -rf test_deploy
```

## Тестирование безопасности

### 1. Тест аутентификации
```bash
# Тест неправильного пароля SQL Server
docker exec steam-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "wrong_password" -Q "SELECT 1" 2>/dev/null
echo "Exit code: $?"

# Тест неправильных учетных данных Scrapoxy
curl -u "wrong_user:wrong_pass" http://localhost:8889/api/health
echo "HTTP status: $?"
```

### 2. Тест портов
```bash
# Проверка открытых портов
netstat -tlnp | grep -E ":(1433|8889|8891)"

# Тест подключения к портам
telnet localhost 1433
telnet localhost 8889
telnet localhost 8891
```

## Тестирование отказоустойчивости

### 1. Тест перезапуска контейнеров
```bash
# Остановка SQL Server
docker stop steam-sqlserver

# Проверка недоступности
curl -s http://localhost:8889/api/health || echo "Scrapoxy недоступен"

# Запуск SQL Server
docker start steam-sqlserver

# Ожидание восстановления
sleep 30

# Проверка восстановления
curl -s http://localhost:8889/api/health && echo "Scrapoxy восстановлен"
```

### 2. Тест нехватки ресурсов
```bash
# Мониторинг использования ресурсов
docker stats --no-stream

# Тест при высокой нагрузке
for i in {1..1000}; do
  curl -s -u "steam_admin_2024:SteamInfra_2024_Secret!" http://localhost:8889/api/health >/dev/null &
done
wait
```

## Автоматизированное тестирование

### 1. Создание тестового скрипта
```bash
#!/bin/bash
# test_all.sh - Полный набор тестов

echo "=== Запуск полного набора тестов ==="

# Запуск сервисов
echo "1. Запуск сервисов..."
./scripts/start.sh
sleep 30

# Проверка статуса
echo "2. Проверка статуса..."
./scripts/status.sh

# Тест SQL Server
echo "3. Тест SQL Server..."
docker exec steam-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "SteamSQL_2024_Secret!" -Q "SELECT @@VERSION" >/dev/null
if [ $? -eq 0 ]; then
    echo "✓ SQL Server работает"
else
    echo "✗ SQL Server не работает"
fi

# Тест Scrapoxy
echo "4. Тест Scrapoxy..."
curl -s -u "steam_admin_2024:SteamInfra_2024_Secret!" http://localhost:8889/api/health >/dev/null
if [ $? -eq 0 ]; then
    echo "✓ Scrapoxy работает"
else
    echo "✗ Scrapoxy не работает"
fi

# Тест Web UI
echo "5. Тест Web UI..."
curl -s -I http://localhost:8891 | grep -q "200 OK"
if [ $? -eq 0 ]; then
    echo "✓ Web UI доступен"
else
    echo "✗ Web UI недоступен"
fi

echo "=== Тестирование завершено ==="
```

### 2. Запуск автоматизированных тестов
```bash
chmod +x test_all.sh
./test_all.sh
```

## Результаты тестирования

### Успешное тестирование
- ✅ Все сервисы запускаются
- ✅ SQL Server принимает подключения
- ✅ Scrapoxy API отвечает
- ✅ Web UI доступен
- ✅ Скрипты управления работают
- ✅ Резервное копирование работает
- ✅ Очистка работает

### Проблемы и решения
- ❌ SQL Server не запускается → Проверить пароль
- ❌ Scrapoxy недоступен → Проверить конфигурацию
- ❌ Порты заняты → Освободить порты
- ❌ Docker не найден → Установить Docker

## Заключение

После успешного прохождения всех тестов SteamInfrastructure готов к использованию в продакшене.
