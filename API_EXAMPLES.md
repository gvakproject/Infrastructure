# Примеры использования API SteamInfrastructure

Документация с примерами использования SQL Server и Scrapoxy API.

## SQL Server API

### Подключение к базе данных

#### Через Docker
```bash
# Подключение к SQL Server через Docker
docker exec -it steam-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "SteamSQL_2024_Secret!"
```

#### Через внешний клиент
```
Host: localhost
Port: 1433
Username: sa (или значение SQL_SERVER_USERNAME)
Password: SteamSQL_2024_Secret! (значение SQL_SERVER_PASSWORD)
Database: SteamInfrastructure
```

### Основные запросы

#### Создание прокси-сервера
```sql
INSERT INTO ProxyServers (Name, Host, Port, Username, Password, IsActive)
VALUES ('My Proxy', 'proxy.example.com', 8080, 'user', 'pass', 1);
```

#### Получение активных прокси
```sql
SELECT * FROM ProxyServers WHERE IsActive = 1;
```

#### Создание сессии
```sql
INSERT INTO Sessions (SessionId, ProxyId, UserAgent, IsActive, ExpiresAt)
VALUES ('session_123', 1, 'Mozilla/5.0...', 1, DATEADD(hour, 1, GETUTCDATE()));
```

#### Получение активных сессий
```sql
SELECT s.*, p.Name as ProxyName, p.Host, p.Port
FROM Sessions s
JOIN ProxyServers p ON s.ProxyId = p.Id
WHERE s.IsActive = 1;
```

#### Очистка истекших сессий
```sql
EXEC CleanupExpiredSessions;
```

#### Получение статистики
```sql
-- Количество активных прокси
SELECT COUNT(*) as ActiveProxies FROM ProxyServers WHERE IsActive = 1;

-- Количество активных сессий
SELECT COUNT(*) as ActiveSessions FROM Sessions WHERE IsActive = 1;

-- Количество логов за последний час
SELECT COUNT(*) as RecentLogs 
FROM Logs 
WHERE CreatedAt > DATEADD(hour, -1, GETUTCDATE());
```

### Хранимые процедуры

#### GetActiveProxies
```sql
EXEC GetActiveProxies;
```

#### CleanupExpiredSessions
```sql
EXEC CleanupExpiredSessions;
```

## Scrapoxy API

### Базовый URL
```
http://localhost:8889
```

### Аутентификация
Все запросы к API требуют базовой HTTP аутентификации:
- Username: `steam_admin_2024`
- Password: `SteamInfra_2024_Secret!`

### Основные эндпоинты

#### Проверка здоровья API
```bash
curl -u "steam_admin_2024:SteamInfra_2024_Secret!" \
  http://localhost:8889/api/health
```

#### Получение информации о проекте
```bash
curl -u "steam_admin_2024:SteamInfra_2024_Secret!" \
  http://localhost:8889/api/project
```

#### Получение списка прокси
```bash
curl -u "steam_admin_2024:SteamInfra_2024_Secret!" \
  http://localhost:8889/api/proxies
```

#### Добавление прокси
```bash
curl -X POST \
  -u "steam_admin_2024:SteamInfra_2024_Secret!" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "proxy1",
    "host": "proxy.example.com",
    "port": 8080,
    "username": "user",
    "password": "pass"
  }' \
  http://localhost:8889/api/proxies
```

#### Получение списка сессий
```bash
curl -u "steam_admin_2024:SteamInfra_2024_Secret!" \
  http://localhost:8889/api/sessions
```

#### Создание сессии
```bash
curl -X POST \
  -u "steam_admin_2024:SteamInfra_2024_Secret!" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "session1",
    "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
  }' \
  http://localhost:8889/api/sessions
```

#### Удаление сессии
```bash
curl -X DELETE \
  -u "steam_admin_2024:SteamInfra_2024_Secret!" \
  http://localhost:8889/api/sessions/session_id
```

### Web UI

Scrapoxy предоставляет веб-интерфейс для управления:
- URL: `http://localhost:8891`
- Username: `steam_admin_2024`
- Password: `SteamInfra_2024_Secret!`

## Интеграция с приложениями

### Python пример

```python
import requests
import sqlalchemy
from sqlalchemy import create_engine, text

# SQL Server подключение
engine = create_engine('mssql+pyodbc://sa:SteamSQL_2024_Secret!@localhost:1433/SteamInfrastructure?driver=ODBC+Driver+17+for+SQL+Server')

# Scrapoxy API
scrapoxy_auth = ('steam_admin_2024', 'SteamInfra_2024_Secret!')
scrapoxy_base_url = 'http://localhost:8889'

# Получение активных прокси из SQL Server
with engine.connect() as conn:
    result = conn.execute(text("SELECT * FROM ProxyServers WHERE IsActive = 1"))
    proxies = result.fetchall()
    print(f"Найдено {len(proxies)} активных прокси")

# Получение сессий из Scrapoxy
response = requests.get(f"{scrapoxy_base_url}/api/sessions", auth=scrapoxy_auth)
if response.status_code == 200:
    sessions = response.json()
    print(f"Найдено {len(sessions)} активных сессий")
```

### Node.js пример

```javascript
const sql = require('mssql');
const axios = require('axios');

// SQL Server подключение
const sqlConfig = {
    user: 'sa',
    password: 'SteamSQL_2024_Secret!',
    server: 'localhost',
    port: 1433,
    database: 'SteamInfrastructure',
    options: {
        encrypt: false,
        trustServerCertificate: true
    }
};

// Scrapoxy API
const scrapoxyAuth = {
    username: 'steam_admin_2024',
    password: 'SteamInfra_2024_Secret!'
};

async function getActiveProxies() {
    try {
        await sql.connect(sqlConfig);
        const result = await sql.query('SELECT * FROM ProxyServers WHERE IsActive = 1');
        console.log(`Найдено ${result.recordset.length} активных прокси`);
        return result.recordset;
    } catch (err) {
        console.error('Ошибка SQL Server:', err);
    } finally {
        await sql.close();
    }
}

async function getSessions() {
    try {
        const response = await axios.get('http://localhost:8889/api/sessions', {
            auth: scrapoxyAuth
        });
        console.log(`Найдено ${response.data.length} активных сессий`);
        return response.data;
    } catch (err) {
        console.error('Ошибка Scrapoxy API:', err);
    }
}
```

### C# пример

```csharp
using System;
using System.Data.SqlClient;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

class Program
{
    private static readonly string SqlConnectionString = 
        "Server=localhost,1433;Database=SteamInfrastructure;User Id=sa;Password=SteamSQL_2024_Secret!;";
    
    private static readonly string ScrapoxyBaseUrl = "http://localhost:8889";
    private static readonly string ScrapoxyUsername = "steam_admin_2024";
    private static readonly string ScrapoxyPassword = "SteamInfra_2024_Secret!";

    static async Task Main(string[] args)
    {
        // Получение активных прокси из SQL Server
        await GetActiveProxies();
        
        // Получение сессий из Scrapoxy
        await GetSessions();
    }

    static async Task GetActiveProxies()
    {
        using (var connection = new SqlConnection(SqlConnectionString))
        {
            await connection.OpenAsync();
            var command = new SqlCommand("SELECT * FROM ProxyServers WHERE IsActive = 1", connection);
            var reader = await command.ExecuteReaderAsync();
            
            int count = 0;
            while (await reader.ReadAsync())
            {
                count++;
            }
            Console.WriteLine($"Найдено {count} активных прокси");
        }
    }

    static async Task GetSessions()
    {
        using (var client = new HttpClient())
        {
            var credentials = Convert.ToBase64String(
                Encoding.ASCII.GetBytes($"{ScrapoxyUsername}:{ScrapoxyPassword}"));
            client.DefaultRequestHeaders.Authorization = 
                new System.Net.Http.Headers.AuthenticationHeaderValue("Basic", credentials);
            
            var response = await client.GetAsync($"{ScrapoxyBaseUrl}/api/sessions");
            if (response.IsSuccessStatusCode)
            {
                var content = await response.Content.ReadAsStringAsync();
                Console.WriteLine($"Ответ Scrapoxy: {content}");
            }
        }
    }
}
```

## Мониторинг и логирование

### SQL Server логи
```sql
-- Просмотр последних логов
SELECT TOP 10 * FROM Logs ORDER BY CreatedAt DESC;

-- Логи по уровню
SELECT * FROM Logs WHERE Level = 'ERROR' ORDER BY CreatedAt DESC;

-- Статистика логов
SELECT Level, COUNT(*) as Count 
FROM Logs 
GROUP BY Level 
ORDER BY Count DESC;
```

### Scrapoxy логи
```bash
# Просмотр логов контейнера
docker logs steam-scrapoxy --tail 50

# Логи в реальном времени
docker logs -f steam-scrapoxy
```

## Устранение неполадок

### Проблемы с подключением к SQL Server
1. Проверьте, что контейнер запущен: `docker ps | grep steam-sqlserver`
2. Проверьте логи: `docker logs steam-sqlserver`
3. Проверьте порт: `netstat -tlnp | grep 1433`

### Проблемы с Scrapoxy API
1. Проверьте, что контейнер запущен: `docker ps | grep steam-scrapoxy`
2. Проверьте логи: `docker logs steam-scrapoxy`
3. Проверьте порты: `netstat -tlnp | grep -E ":(8889|8891)"`
4. Проверьте аутентификацию: `curl -u "user:pass" http://localhost:8889/api/health`

### Проблемы с производительностью
1. Проверьте использование ресурсов: `docker stats`
2. Проверьте логи на ошибки
3. Увеличьте лимиты памяти для контейнеров
4. Оптимизируйте SQL запросы
