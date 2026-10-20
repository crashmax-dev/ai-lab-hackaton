# Local LLM Mini Hackathon

A 30-minute mini hackathon about building websites powered by local LLMs.

Topic: **preventive medicine** — privacy-first health tools where user data never leaves the machine.

## About local LLM

A **local LLM** is a large language model that runs entirely on your own hardware —
laptop, workstation, server or edge device — instead of a remote cloud API.
The model weights live on your disk, and inference happens on your CPU / GPU / NPU.

Why it matters:

- **Privacy** — data never leaves the machine (GDPR/HIPAA-friendly by design);
- **Offline** — works without internet;
- **Predictable cost** — no pay-per-token, only hardware;
- **Control** — you pick the model, version, quantization and runtime;
- **Low latency** — no network round-trip in simple scenarios.

Typical stack covered in this project:
**Ollama**, **Llama.cpp**, **LM Studio** (GGUF) and the Intel stack —
**OpenVINO**, **OVMS**, **ONNX Runtime**.

Key idea to remember: **quantization** (e.g. GGUF `Q4_K_M`, INT8/INT4)
makes models 2–4× smaller with minimal quality loss —
that's what lets a 7B model run comfortably on an office laptop.

## Presentation

The slide deck lives in [`presentation.html`](presentation.html) —
a self-contained HTML file (23 slides, terminal/TUI theme, in Russian).

### Quick start

Serve it with any static HTTP server on port 4000:

```bash
python3 -m http.server 4000 --bind 0.0.0.0
```

Then open in a browser:

```
http://localhost:4000/presentation.html
```

Or from another machine in the same network: `http://<host-ip>:4000/presentation.html`.

(Alternatively, just open `presentation.html` directly in a browser — no server required.)

### Keyboard shortcuts

| Key | Action |
|---|---|
| `←` / `→` | previous / next slide |
| `Space`, `PgUp` / `PgDn` | navigate |
| `Home` / `End` | first / last slide |
| `P` | print / export to PDF |

Navigation buttons and a progress bar are available in the bottom status bar.
