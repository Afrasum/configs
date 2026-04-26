# --- Powerlevel10k instant prompt ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Completions ---
autoload -Uz compinit && compinit

# --- Theme ---
source ~/.local/share/powerlevel10k/powerlevel10k.zsh-theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# --- History ---
HISTFILE=$HOME/.zhistory
SAVEHIST=10000
HISTSIZE=10000
setopt share_history hist_expire_dups_first hist_ignore_dups hist_verify HIST_IGNORE_ALL_DUPS

# --- Plugins ---
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.local/share/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh   # MUST be last

# --- PATH ---
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# --- eza / zoxide ---
alias ls='eza -1 --icons=always'
eval "$(zoxide init zsh)"
alias cd='z'

# --- fzf keybindings ---
[[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[[ -f /usr/share/doc/fzf/examples/completion.zsh   ]] && source /usr/share/doc/fzf/examples/completion.zsh

# --- Aliases ---
alias c='clear'
alias lg='lazygit'
alias venv='source .venv/bin/activate'
alias ..='cd ..'
alias gs='git status'
alias gd='git diff'
alias dps='docker ps'
alias dlog='docker logs -f'

# Pi-spesifikt
alias temp='vcgencmd measure_temp'
alias throttled='vcgencmd get_throttled'

# --- fnm (Node) ---
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --use-on-cd --shell zsh)"
fi
alias cl='claude'
