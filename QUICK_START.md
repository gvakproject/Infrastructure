# Быстрый старт SteamInfrastructure

Краткое руководство по развертыванию SteamInfrastructure через GitHub Actions.

## 🚀 Развертывание за 5 минут

### 1. Подготовка

```bash
# Клонирование репозитория
git clone <your-repo-url>
cd SteamInfrastructure
```

### 2. Настройка GitHub Secrets

Перейдите в Settings → Secrets and variables → Actions и добавьте:

- `HOST` - IP адрес EC2
- `USERNAME` - пользователь для SSH (обычно 'ubuntu')
- `SSH_KEY` - приватный SSH ключ
- `SQL_SERVER_USERNAME` - имя пользователя SQL Server (обычно 'sa')
- `SQL_SERVER_PASSWORD` - пароль SQL Server
- `SCRAPOXY_USERNAME` - имя пользователя Scrapoxy
- `SCRAPOXY_PASSWORD` - пароль Scrapoxy
- `SCRAPOXY_BACKEND_SECRET` - секрет для backend (32+ символов)
- `SCRAPOXY_FRONTEND_SECRET` - секрет для frontend (32+ символов)

### 3. Развертывание

1. Перейдите в раздел Actions
2. Выберите workflow "Deploy SteamInfrastructure to EC2"
3. Нажмите "Run workflow"
4. Дождитесь завершения развертывания

### 4. Проверка

После успешного развертывания сервисы будут доступны:
- SQL Server: `your-ec2-ip:1433`
- Scrapoxy API: `http://your-ec2-ip:8889`
- Scrapoxy Web UI: `http://your-ec2-ip:8891`

## 🌐 Доступ к сервисам

После успешного запуска сервисы будут доступны по адресам:

- **SQL Server**: `localhost:1433`
- **Scrapoxy API**: `http://localhost:8889`
- **Scrapoxy Web UI**: `http://localhost:8891`

### Подключение к SQL Server

```bash
# Через Docker
docker exec -it steam-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "SteamSQL_2024_Secret!"

# Через внешний клиент
# Host: localhost
# Port: 1433
# Username: sa
# Password: SteamSQL_2024_Secret!
```

### Доступ к Scrapoxy Web UI

1. Откройте браузер
2. Перейдите по адресу: `http://localhost:8891`
3. Войдите используя:
   - Username: `steam_admin_2024`
   - Password: `SteamInfra_2024_Secret!`

## 🛠 Управление

### Остановка сервисов

#### Windows (PowerShell)
```powershell
.\scripts\stop.ps1
```

#### Linux/macOS (Bash)
```bash
./scripts/stop.sh
```

### Проверка статуса

#### Windows (PowerShell)
```powershell
.\scripts\status.ps1
```

#### Linux/macOS (Bash)
```bash
./scripts/status.sh
```

### Просмотр логов

```bash
# Логи SQL Server
docker logs steam-sqlserver

# Логи Scrapoxy
docker logs steam-scrapoxy

# Логи в реальном времени
docker logs -f steam-sqlserver
docker logs -f steam-scrapoxy
```

## 🔧 Устранение неполадок

### Проблема: Docker не найден
```bash
# Установка Docker
# Windows: https://docs.docker.com/desktop/windows/install/
# Linux: https://docs.docker.com/engine/install/
# macOS: https://docs.docker.com/desktop/mac/install/
```

### Проблема: Порт занят
```bash
# Проверка занятых портов
netstat -tlnp | grep -E ":(1433|8889|8891)"

# Завершение процессов на портах
sudo fuser -k 1433/tcp
sudo fuser -k 8889/tcp
sudo fuser -k 8891/tcp
```

### Проблема: SQL Server не запускается
```bash
# Проверка логов
docker logs steam-sqlserver

# Проверка пароля (должен соответствовать требованиям)
echo $SQL_SERVER_PASSWORD

# Перезапуск
docker restart steam-sqlserver
```

### Проблема: Scrapoxy не доступен
```bash
# Проверка логов
docker logs steam-scrapoxy

# Проверка конфигурации
cat scrapoxy/config.json

# Перезапуск
docker restart steam-scrapoxy
```

## 📊 Мониторинг

### Проверка ресурсов
```bash
# Использование CPU и памяти
docker stats

# Использование диска
docker system df

# Очистка неиспользуемых ресурсов
docker system prune -f
```

### Проверка подключений
```bash
# Активные подключения
netstat -tlnp | grep -E ":(1433|8889|8891)"

# Тест подключения к SQL Server
docker exec steam-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SQL_SERVER_PASSWORD" -Q "SELECT @@VERSION"

# Тест подключения к Scrapoxy
curl http://localhost:8889/api/health
curl http://localhost:8891
```

## 🔄 Обновление

### Обновление образов Docker
```bash
# Остановка сервисов
./scripts/stop.sh

# Обновление образов
docker pull mcr.microsoft.com/mssql/server:2022-latest
docker pull scrapoxy/scrapoxy:latest

# Запуск сервисов
./scripts/start.sh
```

### Обновление кода
```bash
# Получение обновлений
git pull origin main

# Перезапуск сервисов
./scripts/stop.sh
./scripts/start.sh
```

## 📝 Полезные команды

### Очистка Docker
```bash
# Удаление остановленных контейнеров
docker container prune -f

# Удаление неиспользуемых образов
docker image prune -f

# Удаление неиспользуемых томов
docker volume prune -f

# Полная очистка
docker system prune -a -f
```

### Резервное копирование
```bash
# Создание резервной копии данных SQL Server
docker exec steam-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SQL_SERVER_PASSWORD" -Q "BACKUP DATABASE SteamInfrastructure TO DISK = '/var/opt/mssql/backup/SteamInfrastructure_$(date +%Y%m%d_%H%M%S).bak'"

# Копирование конфигурации Scrapoxy
cp -r scrapoxy scrapoxy_backup_$(date +%Y%m%d_%H%M%S)
```

## 🆘 Получение помощи

Если у вас возникли проблемы:

1. Проверьте логи: `docker logs <container-name>`
2. Проверьте статус: `./scripts/status.sh`
3. Проверьте переменные окружения: `cat .env`
4. Проверьте порты: `netstat -tlnp | grep -E ":(1433|8889|8891)"`
5. Создайте issue в репозитории с подробным описанием проблемы

## 📚 Дополнительная документация

- [README.md](README.md) - Полная документация
- [EC2_SETUP.md](EC2_SETUP.md) - Настройка EC2
- [GITHUB_SECRETS.md](GITHUB_SECRETS.md) - Настройка GitHub Secrets
