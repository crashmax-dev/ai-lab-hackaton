# Tests

> **⚠️ На паузе.** Для текущего формата задания (`TASK.md`: одностраничник, чистый HTML)
> автоматические тесты не обязательны — см. «Самопроверка» в TASK.md.
> Ниже — скрипты под прежний Svelte-контракт, оставлены для гибкости: их можно
> вернуть в игру, если задание вернётся к Svelte-формату.

Проверки для сайтов участников (см. `TASK.md`, раздел 6).

```bash
# 1. LLM API поднят и отвечает (нужен запущенный docker compose --profile llama up -d)
bash test/api-smoke.sh

# 2. Контрактный тест сайта (dev или собранная статика)
node test/site.test.mjs http://localhost:5173   # vite dev
node test/site.test.mjs                        # тоже самое, дефолтный URL

# 3. Собранный пример из .example/ (локально, в git не входит)
cd .example && npm install && npm run build && npm run preview
node test/site.test.mjs http://localhost:4173
```

`api-smoke.sh` — без зависимостей (curl). `site.test.mjs` — Node >= 18, без npm-зависимостей.
Сквозная проверка red flags, дисклеймера и network trace — судейский проход в браузере по чеклисту из TASK.md.
