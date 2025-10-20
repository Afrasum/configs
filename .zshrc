if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if type brew &>/dev/null; then
  autoload -Uz compinit
  compinit
fi

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ---- History setup -----
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
setopt HIST_IGNORE_ALL_DUPS

# Substring-søk i historikk (↑/↓ hopper gjennom kommandoer som inneholder teksten)
if [ -f /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
  source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
fi
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ---- Autocompletion og highlighting -----
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ---- Eza (better ls) -----
alias ls="eza --icons=always"
alias ls='eza -1 --icons=always'

# ---- Zoxide (better cd) -----
eval "$(zoxide init zsh)"
alias cd="z"

alias c="claude"

# ---- pyenv ----
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

autoload bashcompinit && bashcompinit
source $(brew --prefix)/etc/bash_completion.d/az

. "$HOME/.local/bin/env"
