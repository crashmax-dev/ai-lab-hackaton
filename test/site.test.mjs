#!/usr/bin/env node
// Контрактный тест сайта-участника (см. раздел 6 TASK.md).
// Без зависимостей: нужен только Node >= 18 (global fetch).
//
// Использование:
//   node test/site.test.mjs [siteUrl]
//   node test/site.test.mjs http://localhost:5173        # vite dev
//   node test/site.test.mjs http://localhost:4173        # vite preview / static

const base = process.argv[2] ?? 'http://localhost:5173';
let failed = false;
function check(name, ok, detail = '') {
  if (ok) { console.log(`PASS: ${name}`); return; }
  failed = true;
  console.error(`FAIL: ${name}${detail ? ` — ${detail}` : ''}`);
}

async function getText(path) {
  try {
    const res = await fetch(new URL(path, base));
    return res.ok ? await res.text() : null;
  } catch { return null; }
}

const index = await getText('/');
check(`GET / → 200 (${base})`, index !== null, 'сайт не запущен? (npm run dev)');
check('маунт-точка <div id="app">', index?.includes('id="app"') ?? false);
check('на главной есть <form>', /<form/i.test(index ?? ''));

const health = await getText('/health.html');
check('GET /health.html → 200', health !== null, 'файл health.html в корне сайта обязателен');
check('контракт health: id="health-json"', health?.includes('id="health-json"') ?? false);
check('health.json содержит contract-поля', /status|llmReachable/.test(health ?? ''));

if (failed) {
  console.error('SITE TESTS FAILED');
  process.exit(1);
}
console.log('SITE TESTS PASSED');
