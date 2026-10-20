#!/bin/sh
# Тест стартового шаблона example/index.html — TASK.md §7/§9/§10.
# Работает БЕЗ LLM, БЕЗ Node, npm, Python: только sh + grep (git-bash подходит).
# Usage: bash test/example-test.sh     (из корня репозитория, где лежит example/)

SELF="$(dirname "$0")"
FILE="$SELF/../example/index.html"
[ -f "$FILE" ] || { echo "example/index.html is missing"; exit 1; }

PASS=0
FAIL=0
check() {
  if grep -q "$1" "$FILE"; then
    PASS=$((PASS+1))
  else
    FAIL=$((FAIL+1))
    MISSING="$MISSING$2
"
  fi
}

check 'LLM: ПОДКЛЮЧЕНИЕ'  "метка подключения LLM ('LLM: ПОДКЛЮЧЕНИЕ')"
check 'localhost:8000/v1' "LLM адрес localhost:8000/v1"
check '/models'          "runtime-запрос GET /v1/models (model id в рантайме)"
check 'chat/completions'  "POST /v1/chat/completions"
check 'LLM: ПРОМПТ'       "метка промпта ('LLM: ПРОМПТ')"
check 'SYSTEM_PROMPT'     "системный промпт"
check 'buildPrompt'       "сборка промпта из формы (buildPrompt)"
check 'SAFETY: RED FLAGS' "блок red flags"
check 'isRedFlag'         "локальная функция isRedFlag"
check 'груд'             "red flag: боль в груди"
check 'banner'            "баннер 'совет врача'"
check '103'               "номер экстренной службы (103) в баннере"
check 'Материал носит образовательный характер и не является медицинской рекомендацией.' \
                          "дисклеймер дословно"
check '<form'             "форма на странице"
check '<textarea'         "поле жалоб (textarea)"
check '<select'           "уровень активности (select)"
check 'checkbox'          "цели (мультивыбор)"
check 'TODO'              "TODO-метки для доработки участников"

# Сеть не уходит дальше локали:
for BAD in 'api.openai.com' 'anthropic' 'googleapis' 'huggingface' 'https://api.'; do
  if grep -q "$BAD" "$FILE"; then
    FAIL=$((FAIL+1))
    MISSING="$MISSING внешние запросы ('$BAD') в коде сайта
"
  else
    PASS=$((PASS+1))
  fi
done

if [ "$FAIL" -eq 0 ]; then
  echo "EXAMPLE TEST PASSED ($PASS checks)"
  exit 0
fi
echo "EXAMPLE TEST FAILED: $MISSING"
exit 1
