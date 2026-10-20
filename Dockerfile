# syntax=docker/dockerfile:1
# ─────────────────────────────────────────────────────────────────────────────
# LLM-образ хакатона: модель запечена в образ, инференс — llama.cpp.
# По умолчанию — Gemma 4 E2B (Q4_0, 2.84GB); крошечный вариант (<1GB)
# собирается из docker-compose профиля tiny (Llama 3.2 1B Instruct, 773MB).
# Открывает OpenAI-совместимый API на порту 8000 (готово для opencode: /v1).
#
#   docker build -t hackathon-gemma .
#   docker run -d --rm -p 8000:8000 hackathon-gemma
# ─────────────────────────────────────────────────────────────────────────────

# --- Этап 1: Скачивание модели (кэшируется как слой образа) ---
FROM alpine:latest AS downloader
RUN apk add --no-cache curl

WORKDIR /model
# Минимальный качественный standalone-квант Gemma 4 E2B (google, Apache-2.0)
# Можно переопределить: --build-arg MODEL_URL=.../gemma-4-E2B-it-Q8_0.gguf
ARG MODEL_URL=https://huggingface.co/ggml-org/gemma-4-E2B-it-GGUF/resolve/main/gemma-4-E2B-it-Q4_0.gguf
RUN curl -fL --retry 3 -o model.gguf "${MODEL_URL}"

# --- Этап 2: Легковесный образ для инференса ---
# ВАЖНО: у образа llama.cpp:server ENTRYPOINT = /app/llama-server, поэтому
# CMD не может быть shell-скриптом — всё задаётся LLAMA_ARG_* (из common/arg.cpp
# llama.cpp): LLAMA_ARG_MODEL, LLAMA_ARG_ALIAS, LLAMA_ARG_HOST,
# LLAMA_ARG_PORT, LLAMA_ARG_CTX_SIZE, LLAMA_ARG_THREADS и т.д.
FROM ghcr.io/ggml-org/llama.cpp:server

COPY --from=downloader /model/model.gguf /model/model.gguf

ENV LLAMA_ARG_MODEL=/model/model.gguf \
    LLAMA_ARG_HOST=0.0.0.0 \
    LLAMA_ARG_PORT=8000 \
    LLAMA_ARG_CTX_SIZE=8192 \
    LLAMA_ARG_ALIAS=gemma-4-E2B-it-Q4_0

# Явные не-пустые CMD перекрывают базовый и гарантированно не путаются
# llama-server как аргументы (пустой CMD ненадёжен из-за наследования базы).
CMD ["--host", "0.0.0.0", "--port", "8000"]

EXPOSE 8000
