# ---------- 1) Build stage ----------
FROM dart:stable AS build
WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN dart pub get

COPY . .

RUN mkdir -p /out \
 && dart compile exe bin/main.dart -o /out/app

# Требуемая FFI-библиотека
RUN if [ -f /app/libnative.so ]; then cp /app/libnative.so /out/libnative.so; \
    elif [ -f /app/bin/libnative.so ]; then cp /app/bin/libnative.so /out/libnative.so; \
    else echo "ERROR: libnative.so not found (expected in project root or bin/)" && exit 1; fi

RUN mkdir -p /out/assets /out/data && \
    if [ -d /app/assets ]; then cp -R /app/assets/* /out/assets/ 2>/dev/null || true; fi && \
    if [ -d /app/data ];   then cp -R /app/data/*   /out/data/   2>/dev/null || true; fi


# ---------- 2) Runtime stage ----------
FROM debian:bookworm-slim AS runtime
WORKDIR /app

# Библиотеки для рантайма + системный SQLite
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates libstdc++6 libgcc-s1 libsqlite3-0 && \
    rm -rf /var/lib/apt/lists/*

# На многих системах есть только libsqlite3.so.0 — добавим "неверсионированный" symlink
# (учтём архитектуру: amd64/arm64)
RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64)  dir="/usr/lib/x86_64-linux-gnu" ;; \
      arm64)  dir="/usr/lib/aarch64-linux-gnu" ;; \
      *)      dir="/usr/lib/$(uname -m)-linux-gnu" ;; \
    esac; \
    if [ -f "$dir/libsqlite3.so.0" ] && [ ! -f "$dir/libsqlite3.so" ]; then \
      ln -s "$dir/libsqlite3.so.0" "$dir/libsqlite3.so"; \
    fi

# Кладём артефакты сборки
COPY --from=build /out/app          /app/app
COPY --from=build /out/libnative.so /app/libnative.so
COPY --from=build /out/assets       /app/assets
COPY --from=build /out/data         /app/data

# FFI ищется тут
ENV LD_LIBRARY_PATH=/app

# Делаем /app/data ссылкой на /data (персистентный том Amvera)
RUN rm -rf /app/data && ln -s /data /app/data

CMD ["/app/app"]
