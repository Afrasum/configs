# --- Homebrew environment ---
eval "$(/opt/homebrew/bin/brew shellenv)"

# --- PostgreSQL 15 client tools ---
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# --- uv (Python manager) ---
# uv doesn't require a shell hook - just ensure it's in PATH via Homebrew

# --- Homebrew zsh site-functions (for completions) ---
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

export PATH="$PATH:/Applications/microchip/xc8/v3.10/bin"


# Added by Toolbox App
export PATH="$PATH:/Users/afras/Library/Application Support/JetBrains/Toolbox/scripts"

