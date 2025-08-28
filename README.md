# osu! Telegram Bot — Clean Architecture (Dart)

Телеграм‑бот для osu! с аккуратной чистой архитектурой (**domain / data / presentation + core / di**) и минимальными зависимостями. Работает поверх `teledart` и официального osu! v2 API.

> Цель: сохранить поведение простого «монолитного» бота, но сделать код удобным для тестов, расширения и сопровождения.

---

## Возможности
- Привязка Telegram ↔ osu! аккаунта (`/reg`, `/unreg`, `/whoami`).
- Профиль игрока с аватаркой (`/profile`).
- Топ‑скоринг (`/top5`).
- Последний результат (`/last`, `/last_fails`).
- Сравнение скоров на карте (`/compare`).
- Помощь (`/help`).

### Пример вывода `/last`
```
[Server: Bancho]

 <🔷 Ranked> Artist - Title [Diff] by Mapper

Map stats:
  05:50 | AR:9.8 CS:4.0 OD:9.6 HP:5.0 164BPM | ⭐ 7.48
  Mods: +HDDT

Score: 819470 | Combo: 222x/3170x
Accuracy: 80.07%
PP: НЕ ПОФАРМИЛ :(
Hitcounts: 103/19/7/9
Grade: F (6.25%)

Beatmap: https://osu.ppy.sh/b/4684353
```

---

## Архитектура
- **core** — утилиты: парсинг команд, форматирование, HTTP‑клиент, env.
- **domain** — сущности (`OsuUser`, `OsuScore`, `Binding`), репозитории (интерфейсы), use‑cases.
- **data** — DTO, data sources (osu! API, локальная БД), реализации репозиториев.
- **presentation** — слой Телеграма: базовый `BotCommand`, конкретные команды.
- **di** — ручная сборка зависимостей: `di/wiring.dart`.

### Дерево
```
lib/
  core/
  domain/
  data/
  presentation/
  di/
bin/
  main.dart
```

---

## Быстрый старт

### 1) Требования
- Dart >= 3.8.1
- Токен Telegram‑бота (`BOT_TOKEN`)
- osu! OAuth2: `OSU_CLIENT_ID`, `OSU_CLIENT_SECRET`

### 2) Конфигурация окружения
```bash
export BOT_TOKEN=123:ABC
export OSU_CLIENT_ID=xxxxx
export OSU_CLIENT_SECRET=yyyyy
```

### 3) Установка и запуск
```bash
dart pub get
dart run bin/main.dart
```

---

## Команды бота
- `/help` — помощь (алиасы: `/h`, `/хелп`, `/х`)
- `/reg <user>` — привязать osu! к Telegram (алиасы: `/r`, `/рег`)
- `/unreg` — удалить привязку
- `/whoami` — показать привязку
- `/profile [user] [mode]` — профиль (алиасы: `/p`, `/профиль`, `/п`)
- `/top5 [user] [mode]` — топ‑скоры (алиасы: `/t5`, `/т5`)
- `/last [user] [mode]` — последний успешный скор (алиасы: `/l`, `/л`)
- `/last_fails [user] [mode]` — последняя попытка, включая фейлы (алиасы: `/lf`, `/лф`)
- `/compare [user] [mode] [beatmapId]` — результаты на карте (алиасы: `/c`, `/с`)

> `mode`: `osu|taiko|fruits|mania`. Если пользователь привязан через `/reg`, аргумент `<user>` можно не указывать.

---

## DI
Все зависимости собираются в одном месте:

```dart
// di/wiring.dart (фрагмент)
final http = HttpClientImpl(httpClient);
final auth = OsuAuthService(http: http, clientId: env.osuClientId, clientSecret: env.osuClientSecret);
final remote = OsuRemoteDs(http: http, tokenProvider: () => auth.getToken());
final osuRepo = OsuRepositoryImpl(remote);
final bindingLocal = BindingLocalDs(db);
final bindingRepo = BindingRepositoryImpl(bindingLocal);
// далее: создание use‑cases и передача их в команды
```

`bin/main.dart` — простая инициализация `TeledartBot` с массивом команд.

---

## Форматирование `/last`
- Звёзды: **`⭐ 7.48`**.
- Статус:
  - `❤️ Loved`
  - `✅ Qualified`
  - `🔷 Ranked`
  - `❔ Unranked` (pending/wip/graveyard)
- Моды выводятся отдельной строкой: `Mods: +HDDT` или `Mods: NM`.
- Если `max_combo` карты отсутствует в `recent`, бот дотягивает его отдельным вызовом `/beatmaps/{id}` и подставляет.

---

## Дальнейшие улучшения
- Подсчёт **PP для FC/SS** (возможны интеграции через внешние утилиты; по умолчанию поля скрыты или выводятся как `-`).
- Кэширование ответов osu! API.
- Markdown‑формат для ответа (жирные ранги, кликабельные ссылки).
- Rate limiting и повтор при 429.
- Тесты на use‑cases и команды (моки репозиториев).


