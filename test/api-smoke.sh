#!/usr/bin/env bash
# Smoke-test LLM API на :8000 (llama-server, OpenAI-совместимый).
# Использование: bash test/api-smoke.sh   (BASE_URL можно переопределить)

BASE_URL="${BASE_URL:-http://localhost:8000}"
fail(){ echo "FAIL: $1"; exit 1; }

MODELS=$(curl -sf "$BASE_URL/v1/models") || \
  fail "GET /v1/models на ${BASE_URL} недоступен — LLM не запущен? (docker compose --profile llama up -d)"

MODEL=$(printf '%s' "$MODELS" | grep -o '"id":"[^"]*"' | head -n1 | cut -d'"' -f4)
[ -n "$MODEL" ] || fail "в /v1/models нет id модели: $MODELS"
echo "OK: модель найдена — ${MODEL}"

RESP=$(curl -sf -X POST "$BASE_URL/v1/chat/completions" \
  -H 'Content-Type: application/json' \
  -d "{\"model\":\"${MODEL}\",\"messages\":[{\"role\":\"user\",\"content\":\"Ответь одним словом: работает?\"}],\"max_tokens\":16}") \
  || fail "POST /v1/chat/completions не прошёл"

printf '%s' "$RESP" | grep -q '"content"' || fail "в ответе нет поля content: $RESP"
echo "OK: chat/completions возвращает контент"

echo "SMOKE TEST PASSED (model=${MODEL}, server=${BASE_URL})"
