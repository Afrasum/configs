########## Powerlevel10k Instant Prompt ##########
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

########## Completions ##########
autoload -Uz compinit
compinit

########## Powerlevel10k Theme ##########
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

########## History ##########
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
setopt HIST_IGNORE_ALL_DUPS

########## Plugins ##########

# Autosuggestions (grey ghost text)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# History substring search (↑ / ↓ based on current input)
if [ -f /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
  source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
fi
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Syntax highlighting (must be last plugin)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

########## Better ls (eza) ##########
alias ls='eza -1 --icons=always'

########## Zoxide ##########
eval "$(zoxide init zsh)"
alias cd="z"

########## Aliases ##########
alias c='clear'
alias cl='claude'
alias lg='lazygit'
alias venv='source .venv/bin/activate'

########## Azure CLI completions ##########
autoload bashcompinit && bashcompinit
source $(brew --prefix)/etc/bash_completion.d/az

########## Docker CLI completions ##########
fpath=(/Users/afras/.docker/completions $fpath)

########## Custom env (leave untouched) ##########
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

########## Misc ##########
export STM32CubeMX_PATH=/Applications/STMicroelectronics/STM32CubeMX.app/Contents/Resources
export PATH="$PATH:/Applications/microchip/xc8/v3.10/bin"
