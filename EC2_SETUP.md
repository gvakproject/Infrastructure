# Настройка EC2 для SteamInfrastructure

Инструкции по подготовке EC2 инстанса для развертывания SteamInfrastructure.

## Требования к EC2

### Минимальные характеристики
- **Instance Type**: t3.medium или выше
- **RAM**: 4 GB (рекомендуется 8 GB)
- **Storage**: 20 GB (рекомендуется 50 GB)
- **OS**: Ubuntu 20.04 LTS или Amazon Linux 2

### Рекомендуемые характеристики
- **Instance Type**: t3.large
- **RAM**: 8 GB
- **Storage**: 50 GB
- **OS**: Ubuntu 22.04 LTS

## Настройка Security Groups

### Входящие правила (Inbound Rules)
| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|--------|-------------|
| SSH | TCP | 22 | 0.0.0.0/0 | SSH доступ |
| Custom TCP | TCP | 80 | 0.0.0.0/0 | SteamApi (существующий) |
| Custom TCP | TCP | 1433 | 0.0.0.0/0 | SQL Server |
| Custom TCP | TCP | 8889 | 0.0.0.0/0 | Scrapoxy API |
| Custom TCP | TCP | 8891 | 0.0.0.0/0 | Scrapoxy Web UI |

### Исходящие правила (Outbound Rules)
| Type | Protocol | Port Range | Destination | Description |
|------|----------|------------|-------------|-------------|
| All Traffic | All | All | 0.0.0.0/0 | Все исходящие соединения |

## Установка Docker

### Ubuntu/Debian
```bash
# Обновление пакетов
sudo apt update && sudo apt upgrade -y

# Установка зависимостей
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Добавление GPG ключа Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Добавление репозитория Docker
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Установка Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER

# Включение автозапуска Docker
sudo systemctl enable docker
sudo systemctl start docker

# Проверка установки
docker --version
```

### Amazon Linux 2
```bash
# Обновление пакетов
sudo yum update -y

# Установка Docker
sudo yum install -y docker

# Запуск Docker
sudo systemctl start docker
sudo systemctl enable docker

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER

# Проверка установки
docker --version
```

## Настройка SSH ключей

### Создание SSH ключа (на локальной машине)
```bash
# Создание SSH ключа
ssh-keygen -t rsa -b 4096 -f ~/.ssh/steam-infrastructure -C "steam-infrastructure@$(hostname)"

# Копирование публичного ключа
cat ~/.ssh/steam-infrastructure.pub
```

### Добавление SSH ключа на EC2
```bash
# Подключение к EC2
ssh -i ~/.ssh/steam-infrastructure.pem ubuntu@YOUR_EC2_IP

# Создание директории .ssh
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Добавление публичного ключа
echo "YOUR_PUBLIC_KEY" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Выход из SSH
exit
```

## Настройка файрвола (опционально)

### Ubuntu (ufw)
```bash
# Включение файрвола
sudo ufw enable

# Разрешение SSH
sudo ufw allow 22

# Разрешение портов SteamInfrastructure
sudo ufw allow 80
sudo ufw allow 1433
sudo ufw allow 8889
sudo ufw allow 8891

# Проверка статуса
sudo ufw status
```

### Amazon Linux 2 (iptables)
```bash
# Разрешение портов
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 1433 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8889 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8891 -j ACCEPT

# Сохранение правил
sudo service iptables save
```

## Проверка готовности

### Тест Docker
```bash
# Проверка версии Docker
docker --version

# Тест запуска контейнера
docker run hello-world

# Проверка прав пользователя
docker ps
```

### Тест SSH подключения
```bash
# С локальной машины
ssh -i ~/.ssh/steam-infrastructure ubuntu@YOUR_EC2_IP

# Проверка Docker на EC2
docker --version
```

### Тест портов
```bash
# Проверка открытых портов
sudo netstat -tlnp | grep -E ":(22|80|1433|8889|8891)"

# Или с помощью ss
sudo ss -tlnp | grep -E ":(22|80|1433|8889|8891)"
```

## Оптимизация производительности

### Настройка Docker
```bash
# Создание конфигурации Docker
sudo mkdir -p /etc/docker

# Настройка daemon.json
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

# Перезапуск Docker
sudo systemctl restart docker
```

### Настройка системы
```bash
# Увеличение лимитов файлов
echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf

# Настройка sysctl
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## Мониторинг

### Установка htop
```bash
# Ubuntu
sudo apt install -y htop

# Amazon Linux 2
sudo yum install -y htop
```

### Настройка логирования
```bash
# Создание директории для логов
sudo mkdir -p /var/log/steam-infrastructure
sudo chown $USER:$USER /var/log/steam-infrastructure
```

## Резервное копирование

### Создание скрипта резервного копирования
```bash
# Создание скрипта
cat > ~/backup-steam-infrastructure.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/home/$USER/backups/steam-infrastructure"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Резервное копирование данных SQL Server
docker exec steam-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SQL_SERVER_PASSWORD" -Q "BACKUP DATABASE SteamInfrastructure TO DISK = '/var/opt/mssql/backup/SteamInfrastructure_$DATE.bak'"

# Копирование файлов конфигурации
cp -r /home/$USER/SteamInfrastructure/scrapoxy $BACKUP_DIR/scrapoxy_$DATE
cp -r /home/$USER/SteamInfrastructure/data $BACKUP_DIR/data_$DATE

echo "Резервное копирование завершено: $BACKUP_DIR"
EOF

chmod +x ~/backup-steam-infrastructure.sh
```

## Проверка готовности к развертыванию

### Финальная проверка
```bash
# 1. Docker работает
docker --version && echo "✓ Docker установлен"

# 2. Пользователь в группе docker
groups | grep docker && echo "✓ Пользователь в группе docker"

# 3. Порты свободны
for port in 80 1433 8889 8891; do
    if ! netstat -tlnp | grep -q ":$port "; then
        echo "✓ Порт $port свободен"
    else
        echo "✗ Порт $port занят"
    fi
done

# 4. SSH работает
echo "✓ SSH доступен (если вы читаете это)"

# 5. Достаточно места на диске
df -h | grep -E "(/$|/home)" && echo "✓ Проверьте свободное место"

echo "EC2 готов к развертыванию SteamInfrastructure!"
```

## Устранение неполадок

### Проблемы с Docker
```bash
# Перезапуск Docker
sudo systemctl restart docker

# Проверка статуса
sudo systemctl status docker

# Просмотр логов
sudo journalctl -u docker
```

### Проблемы с портами
```bash
# Проверка занятых портов
sudo netstat -tlnp | grep -E ":(80|1433|8889|8891)"

# Завершение процессов на портах
sudo fuser -k 80/tcp
sudo fuser -k 1433/tcp
sudo fuser -k 8889/tcp
sudo fuser -k 8891/tcp
```

### Проблемы с правами доступа
```bash
# Исправление прав на Docker
sudo chmod 666 /var/run/docker.sock

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER
newgrp docker
```

После выполнения всех шагов EC2 будет готов к развертыванию SteamInfrastructure через GitHub Actions.
