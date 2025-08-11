# --- Homebrew environment ---
eval "$(/opt/homebrew/bin/brew shellenv)"

# --- PostgreSQL 15 client tools ---
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# --- pyenv (env vars + PATH for shims) ---
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# --- Homebrew zsh site-functions (for completions) ---
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
