> **Python Tooling:** Use `uv` exclusively for all Python tasks. Do not use `pip` or `python` directly.
> * **Install:** `uv add <package>`
> * **Execute:** `uv run <script.py>` or `uv run python -m <module>`
> * **Scripts:** Use `uv run` with inline dependency metadata for standalone scripts.
> * **Environment:** Assume a `uv` managed virtualenv; never manually create `venv`.