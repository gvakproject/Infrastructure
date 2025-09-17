-- SQL скрипт инициализации базы данных для SteamInfrastructure
-- Автор: SteamInfrastructure Team
-- Дата: 2024
-- Описание: Создание схемы базы данных для Steam-торговой системы

-- Создание базы данных SteamInfrastructure
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'SteamInfrastructure')
BEGIN
    CREATE DATABASE SteamInfrastructure;
    PRINT 'База данных SteamInfrastructure создана';
END
ELSE
BEGIN
    PRINT 'База данных SteamInfrastructure уже существует';
END
GO

-- Использование базы данных SteamInfrastructure
USE SteamInfrastructure;
GO

-- Создание справочных таблиц
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'item_type' AND type = 'U')
BEGIN   
    CREATE TABLE item_type (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        name NVARCHAR(150) NOT NULL
    );
    PRINT 'Таблица item_type создана';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'weapon' AND type = 'U')
BEGIN   
    CREATE TABLE weapon (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        name NVARCHAR(150) NOT NULL
    );
    PRINT 'Таблица weapon создана';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'wear' AND type = 'U')
BEGIN   
    CREATE TABLE wear (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        name NVARCHAR(150) NOT NULL
    );
    PRINT 'Таблица wear создана';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'category' AND type = 'U')
BEGIN   
    CREATE TABLE category (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        name NVARCHAR(150) NOT NULL
    );
    PRINT 'Таблица category создана';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'rarity' AND type = 'U')
BEGIN   
    CREATE TABLE rarity (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        name NVARCHAR(150) NOT NULL
    );
    PRINT 'Таблица rarity создана';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'status' AND type = 'U')
BEGIN
    CREATE TABLE status (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        name NVARCHAR(50) NOT NULL
    );
    PRINT 'Таблица status создана';
END

-- Создание основных таблиц
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'account' AND type = 'U')
BEGIN
    CREATE TABLE account (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        createdOn DATETIME DEFAULT GETDATE(),
        login NVARCHAR(100) NOT NULL,
        password NVARCHAR(100) NOT NULL,
        email NVARCHAR(100) NOT NULL,
        balance DECIMAL(15,2) DEFAULT 0,
        item_count INT DEFAULT 0,
        statusid UNIQUEIDENTIFIER NOT NULL,
        CONSTRAINT FK_status_account 
        FOREIGN KEY (statusid) REFERENCES status(id)
    );
    PRINT 'Таблица account создана';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'item' AND type = 'U')
BEGIN
    CREATE TABLE item (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        name NVARCHAR(550) NOT NULL,
        item_typeid UNIQUEIDENTIFIER,
        weaponid UNIQUEIDENTIFIER,
        categoryid UNIQUEIDENTIFIER,
        wearid UNIQUEIDENTIFIER,
        rarityid UNIQUEIDENTIFIER,
        CONSTRAINT FK_item_item_type
        FOREIGN KEY (item_typeid) REFERENCES item_type(id),
        CONSTRAINT FK_item_weapon
        FOREIGN KEY (weaponid) REFERENCES weapon(id),
        CONSTRAINT FK_item_category
        FOREIGN KEY (categoryid) REFERENCES category(id),
        CONSTRAINT FK_item_wear
        FOREIGN KEY (wearid) REFERENCES wear(id),
        CONSTRAINT FK_item_rarity
        FOREIGN KEY (rarityid) REFERENCES rarity(id)
    );
    PRINT 'Таблица item создана';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'request_order' AND type = 'U')
BEGIN
    CREATE TABLE request_order (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        itemid UNIQUEIDENTIFIER,
        CONSTRAINT FK_request_order_item
        FOREIGN KEY (itemid) REFERENCES item(id),
        count INT DEFAULT 1,
        price DECIMAL(15,2) DEFAULT 0,
        predict_price DECIMAL(15,2) DEFAULT 0,
        statusid UNIQUEIDENTIFIER,
        CONSTRAINT FK_request_order_status
        FOREIGN KEY (statusid) REFERENCES status(id),
        createdon DATETIME DEFAULT GETDATE(),
        modifyon DATETIME DEFAULT GETDATE()
    );
    PRINT 'Таблица request_order создана';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'sticker' AND type = 'U')
BEGIN   
    CREATE TABLE sticker (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        name NVARCHAR(150) NOT NULL,
        price DECIMAL(15,2) DEFAULT 0
    );
    PRINT 'Таблица sticker создана';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'trinket' AND type = 'U')
BEGIN   
    CREATE TABLE trinket (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        name NVARCHAR(150) NOT NULL,
        price DECIMAL(15,2) DEFAULT 0
    );
    PRINT 'Таблица trinket создана';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'bot' AND type = 'U')
BEGIN   
    CREATE TABLE bot (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        login NVARCHAR(100) NOT NULL,
        password NVARCHAR(100) NOT NULL,
        email NVARCHAR(255) NOT NULL,
        balance DECIMAL(15,2) DEFAULT 0,
        count_item INT DEFAULT 0,
        sharedSecret NVARCHAR(100),
        steamid BIGINT,
        statusid UNIQUEIDENTIFIER,
        CONSTRAINT FK_bot_status
        FOREIGN KEY (statusid) REFERENCES status(id)
    );
    PRINT 'Таблица bot создана';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'inventory' AND type = 'U')
BEGIN   
    CREATE TABLE inventory (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        id_item NVARCHAR(100),
        itemid UNIQUEIDENTIFIER,
        request_orderid UNIQUEIDENTIFIER,
        createdon DATETIME DEFAULT GETDATE(),
        nametag BIT DEFAULT 0,
        botid UNIQUEIDENTIFIER,
        float DECIMAL(15,8) DEFAULT 0,
        stickerid UNIQUEIDENTIFIER,
        trinketid UNIQUEIDENTIFIER,
        CONSTRAINT FK_inventory_bot
        FOREIGN KEY (botid) REFERENCES bot(id),
        CONSTRAINT FK_inventory_request_order
        FOREIGN KEY (request_orderid) REFERENCES request_order(id),
        CONSTRAINT FK_inventory_item
        FOREIGN KEY (itemid) REFERENCES item(id)
    );
    PRINT 'Таблица inventory создана';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'inventory_trinket' AND type = 'U')
BEGIN   
    CREATE TABLE inventory_trinket (
        inventoryid UNIQUEIDENTIFIER,
        trinketid UNIQUEIDENTIFIER,
        count INT DEFAULT 1,
        enrollmentDate DATETIME DEFAULT GETDATE(),
        PRIMARY KEY (inventoryid, trinketid),
        CONSTRAINT FK_inventory_trinket_inventory
        FOREIGN KEY (inventoryid) REFERENCES inventory(id)
        ON DELETE CASCADE,
        CONSTRAINT FK_inventory_trinket_trinket
        FOREIGN KEY (trinketid) REFERENCES trinket(id)
        ON DELETE CASCADE
    );
    PRINT 'Таблица inventory_trinket создана';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'inventory_sticker' AND type = 'U')
BEGIN   
    CREATE TABLE inventory_sticker (
        inventoryid UNIQUEIDENTIFIER,
        stickerid UNIQUEIDENTIFIER,
        enrollmentDate DATETIME DEFAULT GETDATE(),
        count INT DEFAULT 1,
        PRIMARY KEY (inventoryid, stickerid),
        CONSTRAINT FK_inventory_sticker_inventory
        FOREIGN KEY (inventoryid) REFERENCES inventory(id)
        ON DELETE CASCADE,
        CONSTRAINT FK_inventory_sticker_sticker
        FOREIGN KEY (stickerid) REFERENCES sticker(id)
        ON DELETE CASCADE
    );
    PRINT 'Таблица inventory_sticker создана';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'request_sell' AND type = 'U')
BEGIN   
    CREATE TABLE request_sell (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        inventoryid UNIQUEIDENTIFIER,
        cost_tax DECIMAL(15,2) DEFAULT 0,
        cost_taxless DECIMAL(15,2) DEFAULT 0,
        statusid UNIQUEIDENTIFIER,
        createdon DATETIME DEFAULT GETDATE(),
        modifyon DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_request_sell_status
        FOREIGN KEY (statusid) REFERENCES status(id),
        CONSTRAINT FK_request_sell_inventory
        FOREIGN KEY (inventoryid) REFERENCES inventory(id)
    );
    PRINT 'Таблица request_sell создана';
END

-- Создание индексов для улучшения производительности
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_account_login')
BEGIN
    CREATE INDEX IX_account_login ON account(login);
    PRINT 'Индекс IX_account_login создан';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_item_name')
BEGIN
    CREATE INDEX IX_item_name ON item(name);
    PRINT 'Индекс IX_item_name создан';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_bot_steamid')
BEGIN
    CREATE INDEX IX_bot_steamid ON bot(steamid);
    PRINT 'Индекс IX_bot_steamid создан';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_inventory_botid')
BEGIN
    CREATE INDEX IX_inventory_botid ON inventory(botid);
    PRINT 'Индекс IX_inventory_botid создан';
END

-- Вставка базовых данных
IF NOT EXISTS (SELECT * FROM status)
BEGIN
    INSERT INTO status (name) VALUES 
        ('Active'),
        ('Inactive'),
        ('Banned'),
        ('Pending');
    PRINT 'Базовые статусы добавлены';
END

IF NOT EXISTS (SELECT * FROM item_type)
BEGIN
    INSERT INTO item_type (name) VALUES 
        ('Weapon'),
        ('Knife'),
        ('Gloves'),
        ('Agent'),
        ('Music Kit'),
        ('Graffiti'),
        ('Sticker'),
        ('Patch');
    PRINT 'Базовые типы предметов добавлены';
END

IF NOT EXISTS (SELECT * FROM rarity)
BEGIN
    INSERT INTO rarity (name) VALUES 
        ('Consumer Grade'),
        ('Industrial Grade'),
        ('Mil-Spec Grade'),
        ('Restricted'),
        ('Classified'),
        ('Covert'),
        ('Contraband');
    PRINT 'Базовые редкости добавлены';
END

PRINT '=== Инициализация базы данных SteamInfrastructure завершена ===';
PRINT 'Создана схема для Steam-торговой системы';
PRINT 'Включены таблицы: item_type, weapon, wear, category, rarity, status';
PRINT 'Включены основные таблицы: account, item, bot, inventory';
PRINT 'Включены таблицы заказов: request_order, request_sell';
PRINT 'База данных готова к использованию!';
