# SteamInfrastructure

Инфраструктурный проект для поддержки Steam API с SQL Server и Scrapoxy.

## Архитектураff

Проект включает:
- **SQL Server** - база данных (порт 1433)
- **Scrapoxy** - прокси-сервер (API: 8889, Web UI: 8891)
dd
Все сервисы развертываются на одной виртуальной машине с использованием Docker.

## Структура проекта

```
SteamInfrastructure/
├── README.md
├── .gitignore
├── .github/
│   └── workflows/
│       └── deploy.yml     # GitHub Actions workflow
├── scripts/               # Скрипты управления (для EC2)
│   ├── start.ps1/.sh      # Запуск сервисов
│   ├── stop.ps1/.sh       # Остановка сервисов
│   ├── restart.ps1/.sh    # Перезапуск сервисов
│   ├── status.ps1/.sh     # Проверка статуса
│   ├── logs.ps1/.sh       # Просмотр логов
│   ├── backup.ps1/.sh     # Резервное копирование
│   ├── cleanup.ps1/.sh    # Очистка Docker
│   └── manage.ps1/.sh     # Главный скрипт управления
├── sql/
│   └── init.sql           # SQL скрипт инициализации
├── DATABASE_SCHEMA.md     # Описание схемы базы данных
└── DATABASE_ERD.md        # Диаграмма связей таблиц
├── scrapoxy/
│   └── config.json        # Конфигурация Scrapoxy
└── data/
    └── sqlserver/         # Данные SQL Server (создается на EC2)
```

## Требования

- GitHub репозиторий с настроенными Secrets
- EC2 инстанс с установленным Docker
- SSH доступ к EC2
- Настроенные Security Groups для портов 22, 1433, 8889, 8891

## Быстрый старт

### 1. Настройка GitHub Secrets

Перейдите в Settings → Secrets and variables → Actions и добавьте все необходимые секреты (см. раздел "Конфигурация").

### 2. Запуск развертывания

1. Перейдите в раздел Actions
2. Выберите workflow "Deploy SteamInfrastructure to EC2"
3. Нажмите "Run workflow"
4. Дождитесь завершения развертывания

### 3. Проверка

После успешного развертывания сервисы будут доступны:
- SQL Server: `your-ec2-ip:1433`
- Scrapoxy API: `http://your-ec2-ip:8889`
- Scrapoxy Web UI: `http://your-ec2-ip:8891`

## Конфигурация

### GitHub Secrets

Настройте следующие секреты в GitHub для автоматического развертывания:

- `HOST` - IP адрес EC2
- `USERNAME` - пользователь для SSH
- `SSH_KEY` - приватный SSH ключ
- `SQL_SERVER_USERNAME` - имя пользователя SQL Server (всегда 'sa')
- `SQL_SERVER_PASSWORD` - пароль SQL Server
- `SCRAPOXY_USERNAME` - имя пользователя Scrapoxy
- `SCRAPOXY_PASSWORD` - пароль Scrapoxy
- `SCRAPOXY_BACKEND_SECRET` - секрет для backend
- `SCRAPOXY_FRONTEND_SECRET` - секрет для frontend

### Порты

- **80**: SteamApi (существующий)
- **1433**: SQL Server
- **8889**: Scrapoxy API
- **8891**: Scrapoxy Web UI

## Развертывание

### 🚀 Автоматическое развертывание (GitHub Actions)

1. Настройте GitHub Secrets (см. раздел "Конфигурация" выше)
2. Запустите workflow `Deploy to EC2`

Workflow автоматически:
- Создаст необходимые директории на EC2
- Скопирует файлы проекта
- Запустит SQL Server и Scrapoxy
- Выполнит инициализацию базы данных
- Проверит статус всех сервисов

## База данных

SteamInfrastructure использует SQL Server с готовой схемой для Steam-торговой системы:

### 📊 Основные таблицы:
- **Справочные**: `item_type`, `weapon`, `wear`, `category`, `rarity`, `status`
- **Основные**: `account`, `item`, `bot`, `inventory`, `request_order`, `request_sell`
- **Связующие**: `inventory_sticker`, `inventory_trinket`, `sticker`, `trinket`

### 📚 Документация:
- [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) - подробное описание всех таблиц
- [DATABASE_ERD.md](DATABASE_ERD.md) - диаграмма связей между таблицами

## Доступ к сервисам

После развертывания сервисы будут доступны по адресам:

- **SQL Server**: `ec2-ip:1433`
- **Scrapoxy API**: `http://ec2-ip:8889`
- **Scrapoxy Web UI**: `http://ec2-ip:8891`

## Управление

### Проверка статуса

```bash
# Проверка контейнеров
docker ps

# Проверка логов SQL Server
docker logs steam-sqlserver

# Проверка логов Scrapoxy
docker logs steam-scrapoxy
```

### Остановка сервисов

```bash
# Остановка всех контейнеров
docker stop steam-sqlserver steam-scrapoxy

# Удаление контейнеров
docker rm steam-sqlserver steam-scrapoxy
```

## Безопасность

- Используйте надежные пароли
- Настройте файрвол для ограничения доступа к портам
- Регулярно обновляйте Docker образы
- Мониторьте логи на предмет подозрительной активности

## Устранение неполадок

### SQL Server не запускается

1. Проверьте логи: `docker logs steam-sqlserver`
2. Убедитесь что порт 1433 свободен
3. Проверьте права доступа к папке данных

### Scrapoxy не доступен

1. Проверьте логи: `docker logs steam-scrapoxy`
2. Убедитесь что порты 8889 и 8891 свободны
3. Проверьте конфигурацию в `scrapoxy/config.json`

### Проблемы с сетью

1. Проверьте настройки файрвола
2. Убедитесь что порты открыты в Security Groups EC2
3. Проверьте маршрутизацию трафика

## Поддержка

При возникновении проблем:
1. Проверьте логи контейнеров
2. Убедитесь что все порты свободны
3. Проверьте конфигурацию переменных окружения
4. Создайте issue в репозитории
