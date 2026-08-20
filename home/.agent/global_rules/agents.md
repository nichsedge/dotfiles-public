# Global Agent Guidelines (Antigravity / Antigravity IDE / agy)

## ⚡ Modern Standards & Strict "No Backward Compatibility"

* **No Backward Compatibility / Modern Only**: Do not create or maintain backward compatibility shims, legacy module aliases, fallback imports, or deprecated wrappers. Always target the latest standards and clean, modern implementations. Let obsolete patterns and versions die.
* **Modern Tooling & Runtimes**: Always use the newest supported language features, runtime versions, and modern tooling (e.g. `uv`, modern build systems, current APIs).

## 🐍 Python Tooling

> **Python Tooling:** Use `uv` exclusively for all Python tasks. Do not use `pip` or `python` directly.
> * **Install:** `uv add <package>`
> * **Execute:** `uv run <script.py>` or `uv run python -m <module>`
> * **Scripts:** Use `uv run` with inline dependency metadata for standalone scripts.
> * **Environment:** Assume a `uv` managed virtualenv; never manually create `venv`.