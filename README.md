# osu! Telegram Bot — Clean Architecture (Dart)

Этот бот для osu! реализован на Dart с модульной архитектурой (domain / data / presentation + core / di). Использует teledart и osu! v2 API.

---

## Быстрый старт

1) Версии/переменные окружения
- Dart >= 3.8.1
- Telegram токен: `BOT_TOKEN`
- osu! OAuth2: `OSU_CLIENT_ID`, `OSU_CLIENT_SECRET`

2) Экспорт переменных
```bash
export BOT_TOKEN=123:ABC
export OSU_CLIENT_ID=xxxxx
export OSU_CLIENT_SECRET=yyyyy
```

3) Запуск бота
```bash
dart pub get
dart run bin/main.dart
```

---

## Команды
- `/help` — справка
- `/reg <user>` — привязать osu! к Telegram
- `/unreg` — отвязать привязку
- `/whoami` — показать привязку
- `/profile [user] [mode]` — профиль
- `/top5 [user] [mode]` — топ-5
- `/last [user] [mode]` — последние результаты
- `/last_fails [user] [mode]` — последние фейлы
- `/pp [link] [mods] [accuracy]` - пп-калькулятор (подробнее ниже)

`mode`: `osu|taiko|fruits|mania`. Если нет привязки через `/reg`, то для команд с `<user>` укажи пользователя вручную.

---

## Команда /pp

- Формат: `/pp <link> [mods] [accuracy]`
- Что делает: считает PP для конкретной сложности карты с помощью rosu_pp_dart.
- Примеры:
  - `/pp https://osu.ppy.sh/beatmapsets/773995#osu/1622719 HDDT 98.5`
  - `/pp https://osu.ppy.sh/beatmaps/1622719 HR 99%`
- Моды: `HD`, `HR`, `DT`/`NC`, `FL`, `EZ`, `NF`, `K1`…`K9`, `SV2`, `COOP` и т.д.
- Точность: `98`, `98.5`, `98%` или `0.985` (интерпретируется как 98.5%).

Технически: бот скачивает .osu по `https://osu.ppy.sh/osu/{beatmapId}` и передаёт содержимое в `RosuPP.calculate(...)`. Для работы FFI ожидается библиотека `native.dll` (Windows) в текущей директории или путь в `ROSU_PP_DART_LIB_PATH`.

---

## DI
См. `di/wiring.dart` — создание HTTP клиента, osu! OAuth2, Remote DS, репозиториев и юзкейсов. `bin/main.dart` поднимает `TeledartBot` и регистрирует команды.

