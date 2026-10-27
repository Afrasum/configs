#!/bin/zsh
# Weekly backup of Mac configs into this repo. Cheap diff first; only if
# something changed is Claude asked to copy, commit and push (see prompt.md).
set -u
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

REPO="${0:A:h:h}"
STATE="$HOME/.local/state/configs-sync"
mkdir -p "$STATE"
LOG="$STATE/sync.log"

notify() {
  osascript -e "display notification \"${2//\"/\\\"}\" with title \"$1\"" >/dev/null 2>&1
}

# live -> repo pairs (files and dirs)
pairs=(
  "$HOME/.zshrc"                   .zshrc
  "$HOME/.zprofile"                .zprofile
  "$HOME/.zshenv"                  .zshenv
  "$HOME/.p10k.zsh"                .p10k.zsh
  "$HOME/.gitconfig"               .gitconfig
  "$HOME/.gitignore_global"        .gitignore_global
  "$HOME/.config/tmux/tmux.conf"   .tmux/tmux.conf
  "$HOME/.config/btop/btop.conf"   btop/btop.conf
  "$HOME/.config/fd"               fd
  "$HOME/.config/gh/config.yml"    gh/config.yml
  "$HOME/.config/ghostty/config"   ghostty/config
  "$HOME/.config/git"              git
  "$HOME/.config/nvim"             nvim
  "$HOME/.config/raycast/scripts"  raycast/scripts
  "$HOME/.claude/CLAUDE.md"        claude/CLAUDE.md
  "$HOME/.claude/settings.json"    claude/settings.json
  "$HOME/.claude/keybindings.json" claude/keybindings.json
  "$HOME/.claude/statusline.sh"    claude/statusline.sh
)

changes=()
for live dest in "${pairs[@]}"; do
  [[ -e "$live" ]] || continue
  if [[ -d "$live" ]]; then
    out=$(diff -rq -x .DS_Store -x '*.log' -x '*.bak' -x .claude -x '.git' "$REPO/$dest" "$live" 2>&1)
  else
    out=$(cmp -s "$REPO/$dest" "$live" || echo "changed: $live")
  fi
  [[ -n "$out" ]] && changes+=("$out")
done

# karabiner.json deliberately differs from the repo (vim-layer kept there),
# so compare against the hash of the live file at the last sync instead.
kb="$HOME/.config/karabiner/karabiner.json"
kb_hash=$(shasum -a 256 "$kb" | cut -d' ' -f1)
[[ "$kb_hash" != "$(cat "$STATE/karabiner.sha" 2>/dev/null)" ]] && changes+=("changed: $kb")

if [[ "${1:-}" == --check ]]; then
  print -l "${changes[@]}"
  exit 0
fi

push() {
  [[ -z "$(git -C "$REPO" log --oneline @{u}.. 2>/dev/null)" ]] && return 0
  git -C "$REPO" push -q >>"$LOG" 2>&1 || { notify "Configs-sync" "git push feilet, se $LOG"; return 1; }
  print "pushed" >>"$LOG"
}

print "=== $(date '+%F %T')" >>"$LOG"
if (( ${#changes} == 0 )); then
  print "no changes" >>"$LOG"
  push
  exit
fi
print -l "${changes[@]}" >>"$LOG"

# prompt goes on stdin: --allowedTools is variadic and would swallow it
summary=$({ cat "$REPO/sync/prompt.md"; print "\nEndringer funnet av forhåndssjekken:"; print -l "${changes[@]}"; } |
  (cd "$REPO" && claude -p --model sonnet \
    --permission-mode acceptEdits \
    --allowedTools "Read,Edit,Write,Bash(cp:*),Bash(diff:*),Bash(cmp:*),Bash(jq:*),Bash(git:*),Bash(ls:*),Bash(cat:*),Bash(mkdir:*)") 2>>"$LOG")
rc=$?
print "$summary" >>"$LOG"

if (( rc != 0 )); then
  notify "Configs-sync feilet" "Se $LOG"
  exit 1
fi

print "$kb_hash" >"$STATE/karabiner.sha"
push || exit 1
notify "Configs-sync" "$(print "$summary" | grep '^SUMMARY:' | tail -1 | sed 's/^SUMMARY: *//')"
