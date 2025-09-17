# Инструкции по развертыванию SteamInfrastructure

## 🚀 Публикация в GitHub

### 1. Инициализация Git репозитория

```bash
# Инициализация Git
git init

# Добавление всех файлов
git add .

# Первый коммит
git commit -m "Initial commit: SteamInfrastructure project setup

- SQL Server с полной схемой для Steam-торговой системы
- Scrapoxy для управления прокси-серверами
- GitHub Actions для автоматического развертывания на EC2
- Полная документация и скрипты управления
- 16 таблиц базы данных с индексами и связями
- Готовые скрипты для Windows (PowerShell) и Linux (Bash)"

# Добавление удаленного репозитория
git remote add origin https://github.com/gvakproject/Infrastructure.git

# Установка основной ветки
git branch -M main

# Отправка в GitHub
git push -u origin main
```

### 2. Настройка GitHub Secrets

После загрузки кода в репозиторий необходимо настроить секреты:

1. Перейдите в **Settings** → **Secrets and variables** → **Actions**
2. Добавьте следующие секреты:

#### Обязательные секреты:
- `HOST` - IP адрес вашего EC2 инстанса
- `USERNAME` - пользователь для SSH (обычно 'ubuntu')
- `SSH_KEY` - приватный SSH ключ для подключения к EC2

#### Секреты для SQL Server:
- `SQL_SERVER_USERNAME` - имя пользователя SQL Server (обычно 'sa')
- `SQL_SERVER_PASSWORD` - надежный пароль для SQL Server

#### Секреты для Scrapoxy:
- `SCRAPOXY_USERNAME` - имя пользователя для Scrapoxy Web UI
- `SCRAPOXY_PASSWORD` - пароль для Scrapoxy Web UI
- `SCRAPOXY_BACKEND_SECRET` - секрет для backend API (минимум 32 символа)
- `SCRAPOXY_FRONTEND_SECRET` - секрет для frontend (минимум 32 символа)

### 3. Запуск развертывания

1. Перейдите в раздел **Actions**
2. Выберите workflow **"Deploy SteamInfrastructure to EC2"**
3. Нажмите **"Run workflow"**
4. Дождитесь завершения развертывания

## 📋 Требования к EC2

### Минимальные характеристики:
- **Instance Type**: t3.medium или выше
- **RAM**: 4 GB (рекомендуется 8 GB)
- **Storage**: 20 GB (рекомендуется 50 GB)
- **OS**: Ubuntu 20.04 LTS или Amazon Linux 2

### Настройка Security Groups:
| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|--------|-------------|
| SSH | TCP | 22 | 0.0.0.0/0 | SSH доступ |
| Custom TCP | TCP | 1433 | 0.0.0.0/0 | SQL Server |
| Custom TCP | TCP | 8889 | 0.0.0.0/0 | Scrapoxy API |
| Custom TCP | TCP | 8891 | 0.0.0.0/0 | Scrapoxy Web UI |

### Установка Docker на EC2:
```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker
```

## 🔧 После развертывания

### Доступные сервисы:
- **SQL Server**: `your-ec2-ip:1433`
- **Scrapoxy API**: `http://your-ec2-ip:8889`
- **Scrapoxy Web UI**: `http://your-ec2-ip:8891`

### Управление на EC2:
```bash
# Подключение к EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# Переход в директорию проекта
cd SteamInfrastructure

# Управление сервисами
./scripts/status.sh      # Проверка статуса
./scripts/logs.sh        # Просмотр логов
./scripts/backup.sh      # Резервное копирование
./scripts/cleanup.sh     # Очистка Docker
```

## 📚 Документация

- [README.md](README.md) - основная документация
- [QUICK_START.md](QUICK_START.md) - быстрый старт
- [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) - схема базы данных
- [DATABASE_ERD.md](DATABASE_ERD.md) - диаграмма связей
- [API_EXAMPLES.md](API_EXAMPLES.md) - примеры использования API
- [GITHUB_SECRETS.md](GITHUB_SECRETS.md) - настройка секретов
- [EC2_SETUP.md](EC2_SETUP.md) - настройка EC2
- [TESTING.md](TESTING.md) - тестирование

## 🆘 Поддержка

При возникновении проблем:
1. Проверьте логи GitHub Actions
2. Проверьте статус сервисов на EC2
3. Убедитесь, что все секреты настроены правильно
4. Проверьте Security Groups EC2

## 🎯 Особенности проекта

- ✅ **Только автоматическое развертывание** через GitHub Actions
- ✅ **Полная схема Steam-торговой системы** с 16 таблицами
- ✅ **Scrapoxy для управления прокси** с Web UI
- ✅ **Кроссплатформенные скрипты** (PowerShell + Bash)
- ✅ **Подробная документация** и примеры использования
- ✅ **Готов к продакшну** сразу после настройки секретов
