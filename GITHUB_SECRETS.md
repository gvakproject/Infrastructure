# Настройка GitHub Secrets для SteamInfrastructure

Для автоматического развертывания на EC2 необходимо настроить следующие секреты в GitHub:

## Обязательные секреты

### 1. HOST
- **Описание**: IP адрес или доменное имя EC2 инстанса
- **Пример**: `54.123.45.67` или `ec2-54-123-45-67.compute-1.amazonaws.com`
- **Где найти**: AWS Console → EC2 → Instances → Public IPv4 address

### 2. USERNAME
- **Описание**: Имя пользователя для SSH подключения к EC2
- **Пример**: `ubuntu` (для Ubuntu), `ec2-user` (для Amazon Linux)
- **Где найти**: Зависит от AMI образа EC2 инстанса

### 3. SSH_KEY
- **Описание**: Приватный SSH ключ для подключения к EC2
- **Пример**: Содержимое файла `~/.ssh/id_rsa` или `~/.ssh/steam-infrastructure.pem`
- **Где найти**: Локальный файл SSH ключа, использованный при создании EC2

## Секреты для SQL Server

### 4. SQL_SERVER_USERNAME
- **Описание**: Имя пользователя SQL Server
- **Значение по умолчанию**: `sa` (System Administrator)
- **Пример**: `sa`
- **Рекомендации**: Обычно используется 'sa', но можно создать отдельного пользователя

### 5. SQL_SERVER_PASSWORD
- **Описание**: Пароль администратора SQL Server
- **Требования**: Минимум 8 символов, должен содержать заглавные, строчные буквы, цифры и специальные символы
- **Пример**: `SteamSQL_2024_Secret!`
- **Рекомендации**: Используйте надежный пароль, так как это критически важный сервис

## Секреты для Scrapoxy

### 6. SCRAPOXY_USERNAME
- **Описание**: Имя пользователя для входа в Scrapoxy Web UI
- **Пример**: `steam_admin_2024`
- **Рекомендации**: Используйте уникальное имя пользователя

### 7. SCRAPOXY_PASSWORD
- **Описание**: Пароль для входа в Scrapoxy Web UI
- **Требования**: Надежный пароль
- **Пример**: `SteamInfra_2024_Secret!`
- **Рекомендации**: Используйте надежный пароль, отличный от SQL Server

### 8. SCRAPOXY_BACKEND_SECRET
- **Описание**: Секретный ключ для backend API Scrapoxy
- **Требования**: Минимум 32 символа
- **Пример**: `steam_backend_secret_key_32_chars_minimum_length_required_2024`
- **Рекомендации**: Сгенерируйте случайную строку длиной 32+ символов

### 9. SCRAPOXY_FRONTEND_SECRET
- **Описание**: Секретный ключ для frontend Scrapoxy
- **Требования**: Минимум 32 символа, должен отличаться от backend секрета
- **Пример**: `steam_frontend_secret_key_32_chars_minimum_length_required_2024`
- **Рекомендации**: Сгенерируйте случайную строку длиной 32+ символов

## Как добавить секреты в GitHub

1. Перейдите в репозиторий на GitHub
2. Нажмите на вкладку **Settings**
3. В левом меню выберите **Secrets and variables** → **Actions**
4. Нажмите **New repository secret**
5. Введите **Name** (например, `HOST`)
6. Введите **Secret** (значение секрета)
7. Нажмите **Add secret**
8. Повторите для всех секретов

## Генерация надежных паролей и секретов

### Для паролей SQL Server и Scrapoxy:
```bash
# PowerShell
[System.Web.Security.Membership]::GeneratePassword(16, 4)

# Bash
openssl rand -base64 32
```

### Для секретов Scrapoxy (32+ символов):
```bash
# PowerShell
-join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | % {[char]$_})

# Bash
openssl rand -base64 32 | tr -d "=+/" | cut -c1-32
```

## Проверка настройки

После добавления всех секретов:

1. Убедитесь, что все 8 секретов добавлены
2. Проверьте, что значения секретов корректны
3. Запустите workflow вручную через **Actions** → **Deploy SteamInfrastructure to EC2** → **Run workflow**

## Безопасность

- **НЕ** коммитьте секреты в код
- **НЕ** делитесь секретами в открытом доступе
- Регулярно обновляйте пароли
- Используйте разные пароли для разных сервисов
- Храните резервные копии SSH ключей в безопасном месте

## Устранение неполадок

### Ошибка SSH подключения
- Проверьте правильность `HOST` и `USERNAME`
- Убедитесь, что SSH ключ корректный
- Проверьте Security Groups EC2 (порт 22 должен быть открыт)

### Ошибка запуска SQL Server
- Проверьте `SQL_SERVER_PASSWORD` (должен соответствовать требованиям)
- Убедитесь, что порт 1433 свободен

### Ошибка запуска Scrapoxy
- Проверьте все секреты Scrapoxy
- Убедитесь, что порты 8889 и 8891 свободны
- Проверьте длину секретов (минимум 32 символа)

## Пример полной настройки

```yaml
# GitHub Secrets
HOST: 54.123.45.67
USERNAME: ubuntu
SSH_KEY: -----BEGIN OPENSSH PRIVATE KEY-----
SQL_SERVER_USERNAME: sa
SQL_SERVER_PASSWORD: SteamSQL_2024_Secret!
SCRAPOXY_USERNAME: steam_admin_2024
SCRAPOXY_PASSWORD: SteamInfra_2024_Secret!
SCRAPOXY_BACKEND_SECRET: steam_backend_secret_key_32_chars_minimum_length_required_2024
SCRAPOXY_FRONTEND_SECRET: steam_frontend_secret_key_32_chars_minimum_length_required_2024
```
