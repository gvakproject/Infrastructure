# Диаграмма связей базы данных SteamInfrastructure

## 🔗 Схема связей между таблицами

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    item_type    │    │     weapon      │    │      wear       │
│                 │    │                 │    │                 │
│ id (PK)         │    │ id (PK)         │    │ id (PK)         │
│ name            │    │ name            │    │ name            │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                            item                                │
│                                                                 │
│ id (PK)                                                         │
│ name                                                            │
│ item_typeid (FK) ──────────────────────────────────────────────┼─┘
│ weaponid (FK) ─────────────────────────────────────────────────┼─┘
│ categoryid (FK) ───────────────────────────────────────────────┼─┘
│ wearid (FK) ───────────────────────────────────────────────────┼─┘
│ rarityid (FK) ─────────────────────────────────────────────────┼─┘
└─────────────────────────────────────────────────────────────────┘
         │                       │
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  request_order  │    │    inventory    │    │  request_sell   │
│                 │    │                 │    │                 │
│ id (PK)         │    │ id (PK)         │    │ id (PK)         │
│ itemid (FK) ────┼────┼─► itemid (FK)   │    │ inventoryid (FK)┼─┐
│ count           │    │ id_item         │    │ cost_tax        │ │
│ price           │    │ request_orderid │◄───┼─► request_order │ │
│ predict_price   │    │ createdon       │    │ cost_taxless    │ │
│ statusid (FK)   │    │ nametag         │    │ statusid (FK)   │ │
│ createdon       │    │ botid (FK) ─────┼────┼─► bot           │ │
│ modifyon        │    │ float           │    │ createdon       │ │
└─────────────────┘    │ stickerid (FK)  │    │ modifyon        │ │
         │              │ trinketid (FK)  │    └─────────────────┘ │
         │              └─────────────────┘                       │
         │                       │                               │
         │                       │                               │
         ▼                       ▼                               │
┌─────────────────┐    ┌─────────────────┐                       │
│     status      │    │      bot        │                       │
│                 │    │                 │                       │
│ id (PK)         │    │ id (PK)         │                       │
│ name            │    │ login           │                       │
└─────────────────┘    │ password        │                       │
         ▲              │ email           │                       │
         │              │ balance         │                       │
         │              │ count_item      │                       │
         │              │ sharedSecret    │                       │
         │              │ steamid         │                       │
         │              │ statusid (FK) ──┼───────────────────────┘
         │              └─────────────────┘
         │
         │
         ▼
┌─────────────────┐
│    account      │
│                 │
│ id (PK)         │
│ createdOn       │
│ login           │
│ password        │
│ email           │
│ balance         │
│ item_count      │
│ statusid (FK) ──┼─┘
└─────────────────┘

┌─────────────────┐    ┌─────────────────┐
│     sticker     │    │     trinket     │
│                 │    │                 │
│ id (PK)         │    │ id (PK)         │
│ name            │    │ name            │
│ price           │    │ price           │
└─────────────────┘    └─────────────────┘
         │                       │
         │                       │
         ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                    inventory_sticker                           │
│                                                                 │
│ inventoryid (FK) ──────────────────────────────────────────────┼─┐
│ stickerid (FK) ────────────────────────────────────────────────┼─┼─┐
│ enrollmentDate                                                  │ │ │
│ count                                                           │ │ │
│ PRIMARY KEY (inventoryid, stickerid)                           │ │ │
└─────────────────────────────────────────────────────────────────┘ │ │
         │                                                           │ │
         │                                                           │ │
         ▼                                                           │ │
┌─────────────────────────────────────────────────────────────────┐ │ │
│                    inventory_trinket                            │ │ │
│                                                                 │ │ │
│ inventoryid (FK) ──────────────────────────────────────────────┼─┼─┘
│ trinketid (FK) ────────────────────────────────────────────────┼─┘
│ count                                                           │
│ enrollmentDate                                                  │
│ PRIMARY KEY (inventoryid, trinketid)                           │
└─────────────────────────────────────────────────────────────────┘
         │
         │
         ▼
┌─────────────────┐
│    inventory    │
│                 │
│ id (PK)         │
│ id_item         │
│ itemid (FK)     │
│ request_orderid │
│ createdon       │
│ nametag         │
│ botid (FK)      │
│ float           │
│ stickerid (FK)  │
│ trinketid (FK)  │
└─────────────────┘
```

## 📊 Справочные таблицы

```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ item_type   │  │   weapon    │  │    wear     │  │  category   │
│             │  │             │  │             │  │             │
│ id (PK)     │  │ id (PK)     │  │ id (PK)     │  │ id (PK)     │
│ name        │  │ name        │  │ name        │  │ name        │
└─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘

┌─────────────┐  ┌─────────────┐
│   rarity    │  │   status    │
│             │  │             │
│ id (PK)     │  │ id (PK)     │
│ name        │  │ name        │
└─────────────┘  └─────────────┘
```

## 🔄 Основные связи

### 1. **item** → справочные таблицы
- `item_typeid` → `item_type.id`
- `weaponid` → `weapon.id`
- `categoryid` → `category.id`
- `wearid` → `wear.id`
- `rarityid` → `rarity.id`

### 2. **account** → **status**
- `statusid` → `status.id`

### 3. **bot** → **status**
- `statusid` → `status.id`

### 4. **inventory** → основные таблицы
- `itemid` → `item.id`
- `request_orderid` → `request_order.id`
- `botid` → `bot.id`

### 5. **request_order** → основные таблицы
- `itemid` → `item.id`
- `statusid` → `status.id`

### 6. **request_sell** → основные таблицы
- `inventoryid` → `inventory.id`
- `statusid` → `status.id`

### 7. **inventory_sticker** → связующие таблицы
- `inventoryid` → `inventory.id` (CASCADE DELETE)
- `stickerid` → `sticker.id` (CASCADE DELETE)

### 8. **inventory_trinket** → связующие таблицы
- `inventoryid` → `inventory.id` (CASCADE DELETE)
- `trinketid` → `trinket.id` (CASCADE DELETE)

## 🎯 Ключевые особенности

1. **UNIQUEIDENTIFIER** - все первичные ключи используют GUID
2. **CASCADE DELETE** - при удалении инвентаря удаляются связанные стикеры и аксессуары
3. **Составные ключи** - для связующих таблиц многие-ко-многим
4. **DEFAULT значения** - большинство полей имеют значения по умолчанию
5. **Внешние ключи** - все связи обеспечены ограничениями целостности

## 📈 Производительность

- Индексы на часто используемые поля
- Оптимизированные типы данных
- Правильная нормализация
- Эффективные связи между таблицами

