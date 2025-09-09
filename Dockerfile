# ---------- 1) Сборка ----------
FROM dart:stable AS build
WORKDIR /app

# Кэш зависимостей
COPY pubspec.yaml pubspec.lock ./
RUN dart pub get

# Исходники и ресурсы
COPY . .

# Скомпилируем в нативный бинарник
RUN dart compile exe bin/main.dart -o /out/app

# Обязательная FFI-библиотека: возьмём из корня или из bin/
# Если нет — прерываем сборку (т.к. она "нужна" по условию)
RUN if [ -f /app/libnative.so ]; then cp /app/libnative.so /out/libnative.so; \
    elif [ -f /app/bin/libnative.so ]; then cp /app/bin/libnative.so /out/libnative.so; \
    else echo "ERROR: libnative.so not found (expected in project root or bin/)" && exit 1; fi

# Приложим ресурсы (опционально: если используются)
RUN mkdir -p /out/assets /out/data && \
    if [ -d /app/assets ]; then cp -R /app/assets/* /out/assets/ 2>/dev/null || true; fi && \
    if [ -d /app/data ];   then cp -R /app/data/*   /out/data/   2>/dev/null || true; fi


# ---------- 2) Рантайм ----------
FROM debian:bookworm-slim AS runtime
WORKDIR /app

# Базовые рантайм-зависимости:
# - ca-certificates: HTTPS к API
# - libstdc++6, libgcc-s1: для нативного бинаря Dart/FFI
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates libstdc++6 libgcc-s1 && \
    rm -rf /var/lib/apt/lists/*

# Кладём скомпилированный бинарь и артефакты
COPY --from=build /out/app /app/app
COPY --from=build /out/libnative.so /app/libnative.so
COPY --from=build /out/assets /app/assets
COPY --from=build /out/data   /app/data

# FFI будет искаться в /app
ENV LD_LIBRARY_PATH=/app

# Делаем симлинк /app/data -> /data (дефолтная точка persistent-хранилища на Amvera)
# Так твой код по-прежнему пишет в относительный data/bot.db, но фактически это будет /data/bot.db
RUN rm -rf /app/data && ln -s /data /app/data

# Никаких портов не объявляем — бот на long-polling. Для вебхуков потом можно добавить EXPOSE/амвера.yml
CMD ["/app/app"]
