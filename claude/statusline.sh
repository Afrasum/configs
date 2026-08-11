#!/usr/bin/env bash
# Claude Code status line — docs: https://code.claude.com/docs/en/statusline
#
# Renders in its own row ABOVE the built-in footer badges (it does not replace
# them), so this line deliberately skips what the footer already shows —
# PR badge, permission mode, vim mode.
#
# Line 1: who/where — model · effort · session · dir · branch · diffstat
# Line 2: what it costs — context bar · rate limits · $ · clock
#
# 256-color escapes only: TERM is tmux-256color, where truecolor needs an
# explicit tmux Tc/RGB override. No OSC 8 links (unreliable through tmux).

input=$(cat)

# One jq pass for every field, emitted one value per line. Absent/null becomes
# an empty string, so each segment can be guarded with [ -n ... ]. Nullability
# is real: used_percentage is null early in a session and after /compact;
# effort / session_name / worktree / agent are absent entirely rather than null.
#
# One-per-line rather than @tsv + `IFS=$'\t' read`: bash's read collapses
# consecutive delimiters even when IFS is non-whitespace, which silently
# shifts every field after two adjacent empty values.
i=0
F=()
while IFS= read -r _line; do
  F[$i]=$_line
  i=$((i + 1))
done <<EOF
$(printf '%s' "$input" | jq -r '
  [ .model.display_name,
    .effort.level,
    .fast_mode,
    .session_name,
    .workspace.current_dir,
    .workspace.git_worktree,
    .worktree.name,
    .cost.total_cost_usd,
    .cost.total_lines_added,
    .cost.total_lines_removed,
    .context_window.used_percentage,
    .context_window.context_window_size,
    .rate_limits.five_hour.used_percentage,
    .rate_limits.five_hour.resets_at,
    .rate_limits.seven_day.used_percentage,
    .agent.name
  ] | map(if . == null then "" else tostring | gsub("[\n\r]"; " ") end) | .[]
' 2>/dev/null)
EOF

model=${F[0]}    effort=${F[1]}   fast=${F[2]}     sname=${F[3]}
cdir=${F[4]}     gwt=${F[5]}      wtname=${F[6]}   cost=${F[7]}
added=${F[8]}    removed=${F[9]}  ctxpct=${F[10]}  ctxsize=${F[11]}
rl5=${F[12]}     rl5r=${F[13]}    rl7=${F[14]}     agent=${F[15]}

R=$'\033[0m'
DIM=$'\033[38;5;240m'
GREY=$'\033[38;5;245m'
BLUE=$'\033[38;5;75m'
PURPLE=$'\033[38;5;141m'
YELLOW=$'\033[38;5;179m'
GREEN=$'\033[38;5;78m'
RED=$'\033[38;5;203m'
CYAN=$'\033[38;5;80m'

# pct -> color: green under 50, yellow under 75, red at/above 75
heat() {
  local p=${1%%.*}
  [ -z "$p" ] && p=0
  if   [ "$p" -ge 75 ]; then printf '%s' "$RED"
  elif [ "$p" -ge 50 ]; then printf '%s' "$YELLOW"
  else                       printf '%s' "$GREEN"
  fi
}

# pct -> 10-cell bar
bar() {
  local p=${1%%.*} n i out=''
  [ -z "$p" ] && p=0
  n=$(( (p + 5) / 10 ))
  [ "$n" -gt 10 ] && n=10
  [ "$n" -lt 0 ] && n=0
  for ((i = 0; i < 10; i++)); do
    if [ "$i" -lt "$n" ]; then out+='▓'; else out+='░'; fi
  done
  printf '%s' "$out"
}

# epoch -> "2h14m" / "43m" until that moment
until_reset() {
  local s=$(( ${1%%.*} - $(date +%s) ))
  [ "$s" -lt 0 ] && s=0
  if [ "$s" -ge 3600 ]; then printf '%dh%02dm' $((s / 3600)) $(((s % 3600) / 60))
  else printf '%dm' $((s / 60))
  fi
}

# ---------- line 1 ----------
l1=""
[ -n "$model" ] && l1+="${PURPLE}◆ ${model}${R}"
[ -n "$effort" ] && l1+="${DIM}·${effort}${R}"
[ "$fast" = "true" ] && l1+="${YELLOW}⚡${R}"
[ -n "$agent" ] && l1+=" ${CYAN}[${agent}]${R}"
[ -n "$sname" ] && l1+=" ${GREY}${sname:0:24}${R}"

if [ -n "$cdir" ]; then
  l1+=" ${BLUE}${cdir##*/}${R}"
  branch=$(git --no-optional-locks -C "$cdir" branch --show-current 2>/dev/null)
  if [ -n "$branch" ]; then
    # -uno: skip stat-ing untracked trees; this runs every refreshInterval
    if [ -n "$(git --no-optional-locks -C "$cdir" status --porcelain -uno 2>/dev/null)" ]; then
      l1+=" ${YELLOW}⎇ ${branch}*${R}"
    else
      l1+=" ${YELLOW}⎇ ${branch}${R}"
    fi
  fi
fi

wt="${wtname:-$gwt}"
[ -n "$wt" ] && l1+=" ${CYAN}⑃ ${wt}${R}"

if [ "${added:-0}" != "0" ] || [ "${removed:-0}" != "0" ]; then
  l1+=" ${GREEN}+${added:-0}${R}${DIM}/${R}${RED}-${removed:-0}${R}"
fi

# ---------- line 2 ----------
l2=""
if [ -n "$ctxpct" ]; then
  c=$(heat "$ctxpct")
  l2+="${DIM}ctx ${R}${c}$(bar "$ctxpct") ${ctxpct%%.*}%${R}"
else
  l2+="${DIM}ctx $(bar 0)  —${R}"
fi
[ -n "$ctxsize" ] && [ "$ctxsize" -ge 1000000 ] 2>/dev/null && l2+="${DIM} of 1M${R}"

if [ -n "$rl5" ]; then
  l2+="${DIM} · ${R}$(heat "$rl5")5h ${rl5%%.*}%${R}"
  [ -n "$rl5r" ] && l2+="${DIM}→$(until_reset "$rl5r")${R}"
fi
if [ -n "$rl7" ]; then
  l2+="${DIM} · ${R}$(heat "$rl7")7d ${rl7%%.*}%${R}"
fi

if [ -n "$cost" ]; then
  usd=$(printf '%.2f' "$cost" 2>/dev/null)
  [ -n "$usd" ] && [ "$usd" != "0.00" ] && l2+="${DIM} · \$${usd}${R}"
fi

l2+="${DIM} · $(date +%H:%M)${R}"

# Each line printed becomes its own row; skip line 1 entirely if nothing
# populated it (malformed or empty stdin) rather than emitting a blank row.
[ -n "$l1" ] && printf '%s\n' "$l1"
printf '%s\n' "$l2"
