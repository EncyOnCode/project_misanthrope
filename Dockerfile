# Use official Dart image with SDK and runtime
FROM dart:stable

WORKDIR /app

# 1) Cache dependencies layer
COPY pubspec.yaml pubspec.lock ./
RUN dart pub get

# 2) Copy sources
COPY lib ./lib
COPY bin ./bin
COPY assets ./assets
COPY data ./data

# 3) Ensure runtime data dir exists (for drift DB at data/bot.db)
RUN mkdir -p /app/data

# 4) Pick up native library for rosu_pp_dart if present in repo
#    - Prefer libnative.so at project root or bin/ (Linux)
#    - You may also include libnative.dylib or native.dll; they are ignored here
RUN if [ -f /app/libnative.so ]; then echo "Using libnative.so at project root"; \
    elif [ -f /app/bin/libnative.so ]; then cp /app/bin/libnative.so /app/libnative.so; \
    else echo "WARNING: libnative.so not found in project. PP features may fail."; fi

# 5) Optional: reduce image size by removing pub cache temp files (keeps dependency cache)
RUN dart pub cache clean --no-precompile || true

# Runtime env (set at run-time)
#   - BOT_TOKEN (required)
#   - OSU_CLIENT_ID (required)
#   - OSU_CLIENT_SECRET (required)

# Start the bot with dart run
CMD ["dart", "run", "bin/main.dart"]

