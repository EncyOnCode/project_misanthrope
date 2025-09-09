# ---------- 1) Build stage ----------
FROM dart:stable AS build
WORKDIR /app

# Кэш зависимостей
COPY pubspec.yaml pubspec.lock ./
RUN dart pub get

# Исходники и ресурсы
COPY . .

# Создаём директорию под артефакты и компилируем в неё
RUN mkdir -p /out \
 && dart compile exe bin/main.dart -o /out/app

# Обязательная FFI-библиотека: берём из корня или bin/
# Если нет — прерываем сборку (т.к. она "нужна")
RUN if [ -f /app/libnative.so ]; then cp /app/libnative.so /out/libnative.so; \
    elif [ -f /app/bin/libnative.so ]; then cp /app/bin/libnative.so /out/libnative.so; \
    else echo "ERROR: libnative.so not found (expected in project root or bin/)" && exit 1; fi

# Ресурсы (если используются)
RUN mkdir -p /out/assets /out/data && \
    if [ -d /app/assets ]; then cp -R /app/assets/* /out/assets/ 2>/dev/null || true; fi && \
    if [ -d /app/data ];   then cp -R /app/data/*   /out/data/   2>/dev/null || true; fi

# ---------- 2) Runtime stage ----------
FROM debian:bookworm-slim AS runtime
WORKDIR /app

# Минимальные рантайм-зависимости
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates libstdc++6 libgcc-s1 && \
    rm -rf /var/lib/apt/lists/*

# Кладём бинарь и артефакты
COPY --from=build /out/app        /app/app
COPY --from=build /out/libnative.so /app/libnative.so
COPY --from=build /out/assets     /app/assets
COPY --from=build /out/data       /app/data

# FFI ищется в /app
ENV LD_LIBRARY_PATH=/app

# Связываем /app/data -> /data (дефолтный персистент-том на Amvera)
RUN rm -rf /app/data && ln -s /data /app/data

# Для long-polling порты не объявляем. Для вебхуков можно добавить EXPOSE/настройки позже.
CMD ["/app/app"]
