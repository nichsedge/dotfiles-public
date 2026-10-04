# Global Agent Guidelines (Antigravity / Antigravity IDE / agy)

## ⚡ Modern Standards & Strict "No Backward Compatibility"

* **No Backward Compatibility / Modern Only**: Do not create or maintain backward compatibility shims, legacy module aliases, fallback imports, or deprecated wrappers. Always target the latest standards and clean, modern implementations. Let obsolete patterns and versions die.
* **Modern Tooling & Runtimes**: Always use the newest supported language features, runtime versions, and modern tooling (e.g. `uv`, modern build systems, current APIs).
* **Strict `uv run` Syntax**: NEVER write or recommend `uv run python <script.py>`. Always use direct script/module execution: `uv run <script.py>`, `uv run <entrypoint>` (e.g. `uv run idx <cmd>`), or `uv run <tool>` (e.g. `uv run pytest`, `uv run ruff`).
* **Proactive Documentation Sync**: Whenever tools, scripts, CLI entry points, or dependencies are added, modified, or removed, immediately update both `README.md` and repository guidelines (`AGENTS.md`) in the same turn.
* **Workstation Data Architecture & SSOT Compliance**: Strictly obey the data topology in `~/Projects/DATA_ARCHITECTURE.md`. Structured personal ERP data belongs exclusively in `~/Projects/ierp` (`events.db`), unstructured knowledge/notes belong in `~/Projects/digital-graveyard` (`content/`), and domain telemetry/records belong in their respective recorders (`atracker`, `portfolio-integration`, `sansfinance`, `fitly`). Never invent siloed databases or rogue data stores in consumer apps like `nichsedge.github.io`.

## 🐍 Python Tooling

> **Python Tooling:** Use `uv` exclusively for all Python tasks. Do not use `pip` or `python` directly.
> * **Install:** `uv add <package>`
> * **Execute:** `uv run <script.py>` or direct entrypoints (e.g. `uv run ruff`, `uv run pytest`). Never use `uv run python <script.py>`.
> * **Scripts:** Use `uv run` with inline dependency metadata for standalone scripts (`# /// script`).
> * **Environment:** Assume a `uv` managed virtualenv; never manually create `venv`.