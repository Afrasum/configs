# Global Instructions

## Git

- Do not add Co-Authored-By lines to commit messages
- Commit as you go — after each logical fix or feature is complete (tests passing, lint clean), make a commit before moving on to the next task. Do not batch many unrelated changes into one giant commit. If you realize mid-session that you have accumulated uncommitted work across several issues, stop and commit what you have in logical pieces before continuing.

## Python

- Always use `uv` for Python package management (not pip/pip3)
- Use `uv venv` for virtual environments (not python -m venv)
- For quick one-off scripts: `uv run --with <package> python script.py`
- Never use `pip install`, `pip3 install`, or `python -m venv`

## Shell

- `cd` is aliased to `z` (zoxide) — avoid using `cd` in Bash commands as it triggers zoxide warnings. Use absolute paths or `z` instead.
