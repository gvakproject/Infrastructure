# Информация о проекте SteamInfrastructure

## Обзор проекта

SteamInfrastructure - это инфраструктурный проект для поддержки Steam API, включающий SQL Server для хранения данных и Scrapoxy для управления прокси-серверами.

## Архитектура

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Steam API     │    │  SQL Server     │    │   Scrapoxy      │
│   (External)    │◄───┤   (Port 1433)   │    │ (Ports 8889/8891)│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Docker Host (EC2)                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │steam-sqlserver│  │steam-scrapoxy│  │steam-api   │            │
│  │   Container  │  │   Container  │  │  Container  │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
└─────────────────────────────────────────────────────────────────┘
```

## Компоненты

### 1. SQL Server
- **Образ**: `mcr.microsoft.com/mssql/server:2022-latest`
- **Порт**: 1433
- **База данных**: SteamInfrastructure
- **Пользователь**: sa
- **Пароль**: настраивается через переменные окружения

### 2. Scrapoxy
- **Образ**: `scrapoxy/scrapoxy:latest`
- **API порт**: 8889 (маппинг 8889→8888)
- **Web UI порт**: 8891 (маппинг 8891→8890)
- **Аутентификация**: базовая HTTP

## Структура файлов

```
SteamInfrastructure/
├── README.md                 # Основная документация
├── QUICK_START.md           # Быстрый старт
├── API_EXAMPLES.md          # Примеры использования API
├── EC2_SETUP.md            # Настройка EC2
├── GITHUB_SECRETS.md       # Настройка GitHub Secrets
├── PROJECT_INFO.md         # Информация о проекте
├── .gitignore              # Игнорируемые файлы
├── env.example             # Пример переменных окружения
├── .github/
│   └── workflows/
│       └── deploy.yml      # GitHub Actions workflow
├── scripts/                # Скрипты управления
│   ├── start.ps1/.sh       # Запуск сервисов
│   ├── stop.ps1/.sh        # Остановка сервисов
│   ├── restart.ps1/.sh     # Перезапуск сервисов
│   ├── status.ps1/.sh      # Проверка статуса
│   ├── logs.ps1/.sh        # Просмотр логов
│   ├── backup.ps1/.sh      # Резервное копирование
│   ├── cleanup.ps1/.sh     # Очистка Docker
│   └── manage.ps1/.sh      # Главный скрипт управления
├── sql/
│   └── init.sql            # SQL скрипт инициализации
├── scrapoxy/
│   └── config.json         # Конфигурация Scrapoxy
└── data/
    └── sqlserver/          # Данные SQL Server
```

## Порты

| Сервис | Порт | Описание |
|--------|------|----------|
| SteamApi | 80 | Существующий сервис |
| SQL Server | 1433 | База данных |
| Scrapoxy API | 8889 | REST API |
| Scrapoxy Web UI | 8891 | Веб-интерфейс |

## GitHub Secrets

Проект использует только GitHub Secrets для конфигурации (нет локального развертывания):

- `HOST` - IP адрес EC2
- `USERNAME` - пользователь для SSH
- `SSH_KEY` - приватный SSH ключ
- `SQL_SERVER_USERNAME` - имя пользователя SQL Server (обычно 'sa')
- `SQL_SERVER_PASSWORD` - пароль SQL Server
- `SCRAPOXY_USERNAME` - имя пользователя Scrapoxy
- `SCRAPOXY_PASSWORD` - пароль Scrapoxy
- `SCRAPOXY_BACKEND_SECRET` - секрет backend (32+ символов)
- `SCRAPOXY_FRONTEND_SECRET` - секрет frontend (32+ символов)

## База данных

### Таблицы
- **ProxyServers** - информация о прокси-серверах
- **Sessions** - активные сессии
- **Logs** - логи системы

### Хранимые процедуры
- **GetActiveProxies** - получение активных прокси
- **CleanupExpiredSessions** - очистка истекших сессий

### Индексы
- `IX_ProxyServers_IsActive` - по полю IsActive
- `IX_Sessions_SessionId` - по полю SessionId
- `IX_Sessions_IsActive` - по полю IsActive
- `IX_Logs_CreatedAt` - по полю CreatedAt

## Скрипты управления

### Основные команды
```bash
# Windows PowerShell
.\scripts\manage.ps1 start
.\scripts\manage.ps1 stop
.\scripts\manage.ps1 status
.\scripts\manage.ps1 logs

# Linux/macOS Bash
./scripts/manage.sh start
./scripts/manage.sh stop
./scripts/manage.sh status
./scripts/manage.sh logs
```

### Дополнительные команды
```bash
# Резервное копирование
./scripts/backup.sh --include-data --include-config

# Очистка Docker
./scripts/cleanup.sh --all

# Просмотр логов
./scripts/logs.sh -s sql -f
./scripts/logs.sh -s scrapoxy -n 100
```

## Развертывание

### Локальное развертывание
1. Клонировать репозиторий
2. Создать файл `.env` на основе `env.example`
3. Запустить: `./scripts/start.sh`

### Развертывание на EC2
1. Настроить GitHub Secrets
2. Запустить GitHub Actions workflow
3. Проверить развертывание

## Мониторинг

### Проверка статуса
```bash
# Статус контейнеров
docker ps --filter "name=steam-"

# Использование ресурсов
docker stats

# Логи
docker logs steam-sqlserver
docker logs steam-scrapoxy
```

### Проверка портов
```bash
# Проверка открытых портов
netstat -tlnp | grep -E ":(1433|8889|8891)"
```

### Проверка API
```bash
# SQL Server
docker exec steam-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SQL_SERVER_PASSWORD" -Q "SELECT @@VERSION"

# Scrapoxy
curl -u "steam_admin_2024:SteamInfra_2024_Secret!" http://localhost:8889/api/health
```

## Безопасность

### Рекомендации
- Используйте надежные пароли
- Регулярно обновляйте пароли
- Настройте файрвол
- Мониторьте логи
- Создавайте резервные копии

### Ограничения доступа
- SQL Server: только локальный доступ
- Scrapoxy: базовая HTTP аутентификация
- SSH: только для администраторов

## Производительность

### Рекомендуемые характеристики
- **CPU**: 2+ ядра
- **RAM**: 4+ GB
- **Storage**: 20+ GB SSD
- **Network**: 1+ Gbps

### Оптимизация
- Настройка Docker daemon
- Оптимизация SQL запросов
- Мониторинг ресурсов
- Регулярная очистка

## Устранение неполадок

### Частые проблемы
1. **Docker не найден** - установите Docker
2. **Порты заняты** - освободите порты
3. **SQL Server не запускается** - проверьте пароль
4. **Scrapoxy недоступен** - проверьте конфигурацию

### Логи для отладки
```bash
# Логи SQL Server
docker logs steam-sqlserver --tail 50

# Логи Scrapoxy
docker logs steam-scrapoxy --tail 50

# Системные логи
journalctl -u docker
```

## Поддержка

### Документация
- [README.md](README.md) - основная документация
- [QUICK_START.md](QUICK_START.md) - быстрый старт
- [API_EXAMPLES.md](API_EXAMPLES.md) - примеры API
- [EC2_SETUP.md](EC2_SETUP.md) - настройка EC2
- [GITHUB_SECRETS.md](GITHUB_SECRETS.md) - настройка секретов

### Получение помощи
1. Проверьте документацию
2. Проверьте логи
3. Создайте issue в репозитории
4. Опишите проблему подробно

## Лицензия

Проект распространяется под лицензией MIT.

## Авторы

- SteamInfrastructure Team
- Дата создания: 2024

## Версия

- Текущая версия: 1.0.0
- Дата релиза: 2024-09-17
