# syntax=docker/dockerfile:1
# ─────────────────────────────────────────────────────────────────────────────
# LLM-образ хакатона: модель запечена в образ, инференс — llama.cpp.
# По умолчанию — Gemma 4 E2B (Q4_0, 2.84GB); крошечный вариант (<1GB)
# собирается из docker-compose профиля tiny (Llama 3.2 1B Instruct, 773MB).
# Продает OpenAI-совместимый API на порту 8000 (готово для opencode: /v1).
#
#   docker build -t hackathon-gemma .
#   docker run -d --rm -p 8000:8000 hackathon-gemma
#
# NOTE: «ультра-компактная ~1.2GB» версия E2B не существует отдельно от draft
# (см. rasyosef dspark — это draft для speculative decoding). Минимальный
# standalone-квант — Q4_0 (2.84 GB). Более качественный: Q8_0 (4.97 GB).
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
# Официальный образ llama.cpp: полноценный OpenAI-совместимый сервер на :8080
FROM ghcr.io/ggml-org/llama.cpp:server

COPY --from=downloader /model/model.gguf /model/model.gguf

ENV CONTEXT=8192 \
    THREADS=0 \
    MODEL_ALIAS=gemma-4-E2B-it-Q4_0

# llama-server: OpenAI-compatible /v1/chat/completions, web UI на /
CMD ["sh", "-c", "llama-server \
    --model /model/model.gguf \
    --alias ${MODEL_ALIAS} \
    --host 0.0.0.0 --port 8000 \
    --threads ${THREADS:-0} \
    --ctx-size ${CONTEXT:-8192} \
    --mlock"]

EXPOSE 8000
