# Tests

Проверки стартового шаблона участника (`example/index.html`):

```bash
bash test/test-example.sh          # чистый sh+grep: без LLM, без Node/npm/Python
```

Проверки LLM-сервера (опционально, нужен запущенный LLM и curl):

```bash
bash test/api-smoke.sh
```

Прежние Svelte-контрактные проверки (`site.test.mjs`) относятся к старому формату
задания; contract-details описаны в git-истории, текущие правила — `TASK.md`.
