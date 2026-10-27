Du kjører ukentlig backup av Mac-configs inn i dette repoet (~/Projects/configs). Forhåndssjekken nederst lister hva som avviker fra macen.

Mapping (live → repo):
- `~/.zshrc`, `~/.zprofile`, `~/.zshenv`, `~/.p10k.zsh`, `~/.gitconfig`, `~/.gitignore_global` → repo-roten
- `~/.config/tmux/tmux.conf` → `.tmux/tmux.conf`
- `~/.config/{btop,fd,gh,ghostty,git,nvim,karabiner}` → `<navn>/`
- `~/.config/raycast/scripts` → `raycast/scripts`
- `~/.claude/{CLAUDE.md,settings.json,keybindings.json,statusline.sh}` → `claude/`

Regler:
- Kopier det som faktisk er endret fra macen til repoet. Nye filer i en sporet mappe (f.eks. ny nvim-plugin) skal med.
- Aldri kopier hemmeligheter: `gh/hosts.yml`, tokens, API-nøkler, `.env`. Hvis en fil inneholder noe som ser ut som en hemmelighet, hopp over den og nevn det.
- Hopp over støy: `*.bak`, `*.log`, `automatic_backups/`, `karabiner/assets/`, `nvim/.claude/`, lockfiler som bare er rot.
- karabiner.json: IKKE kopier blindt. Repoet beholder bevisst regelen "Caps Lock vim-layer med visual mode" som macen mangler, og regelen "test lambda" skal ikke med. Sammenlign regel for regel med jq og overfør bare reelle endringer (nye/endrede regler, endringer utenfor complex_modifications), og bevar vim-layer.
- Ikke endre noe på macen, bare i repoet.
- Commit i logiske biter (én per verktøy/endring), conventional-commit-stil som i `git log` (f.eks. `feat(nvim): ...`). Ingen Co-Authored-By-linjer.
- `git push` til slutt. Hvis det viser seg at ingenting reelt skal kopieres, ikke commit.

Siste linje i svaret ditt MÅ være én linje på formen:
SUMMARY: <kort norsk oppsummering, maks ~120 tegn, f.eks. "3 commits pushet: zsh-alias, ghostty auto-update, nvim typst">
eller `SUMMARY: Ingen reelle endringer` hvis ingenting ble gjort.
