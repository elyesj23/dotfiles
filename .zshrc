# ~/.zshrc — interactive shell config
# Originals backed up to ~/dotfiles-backup-<timestamp>/

# ──────────────────────────────────────────────────────────────────────────────
# fastfetch  —  system info on new terminal sessions
# ──────────────────────────────────────────────────────────────────────────────
if command -v fastfetch >/dev/null 2>&1 && [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
  fastfetch
fi

# ──────────────────────────────────────────────────────────────────────────────
# PATH (deduped, prepends in priority order)
# Note: Homebrew shellenv runs in ~/.zprofile for login shells.
# ──────────────────────────────────────────────────────────────────────────────
typeset -U path PATH        # auto-dedupe entries
path=(
  "$HOME/.local/bin"
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  $path
)
export PATH

# ──────────────────────────────────────────────────────────────────────────────
# History
# ──────────────────────────────────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# ──────────────────────────────────────────────────────────────────────────────
# Shell options
# ──────────────────────────────────────────────────────────────────────────────
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP

# ──────────────────────────────────────────────────────────────────────────────
# Completion
# ──────────────────────────────────────────────────────────────────────────────
if command -v brew >/dev/null 2>&1; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
fi
autoload -Uz compinit
if [[ -n "$HOME/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors ''

# ──────────────────────────────────────────────────────────────────────────────
# Editor & pager
# ──────────────────────────────────────────────────────────────────────────────
export EDITOR="cursor --wait"
export VISUAL="$EDITOR"
export PAGER="less"
export LESS="-FRX"

# ──────────────────────────────────────────────────────────────────────────────
# direnv  —  per-directory .envrc files (API keys, env vars scoped to project)
# ──────────────────────────────────────────────────────────────────────────────
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Aliases
# ──────────────────────────────────────────────────────────────────────────────
# eza  —  replaces ls with icons + git status (requires Nerd Font)
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza --icons --git --long --group-directories-first'
  alias la='eza --icons --git --long --all --group-directories-first'
  alias l='eza --icons --group-directories-first'
  alias lt='eza --icons --tree --level=2 --group-directories-first'
else
  alias ls='ls -G'
  alias ll='ls -lhG'
  alias la='ls -lhAG'
  alias l='ls -CF'
fi
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -pv'
alias grep='grep --color=auto'
alias rg='rg --smart-case'
alias path='echo $PATH | tr ":" "\n"'
alias reload='exec zsh'

# Git
alias g='git'
alias gs='git status -sb'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gp='git pull --ff-only'
alias gpu='git push'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate -20'
alias gll='git log --oneline --graph --decorate --all'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# bat  —  cat with syntax highlighting (-pp = plain, no pager, drop-in replacement)
if command -v bat >/dev/null 2>&1; then
  alias cat='bat -pp'
fi

# lazygit  —  visual git TUI
if command -v lazygit >/dev/null 2>&1; then
  alias lz='lazygit'
fi

# ──────────────────────────────────────────────────────────────────────────────
# Starship prompt
# ──────────────────────────────────────────────────────────────────────────────
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# ──────────────────────────────────────────────────────────────────────────────
# zoxide  —  smarter cd. `z foo` jumps to most-used dir matching `foo`.
# ──────────────────────────────────────────────────────────────────────────────
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# ──────────────────────────────────────────────────────────────────────────────
# fzf  —  Ctrl+R history, Ctrl+T files, Alt+C dirs
# ──────────────────────────────────────────────────────────────────────────────
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"
export FZF_DEFAULT_OPTS="--height 40% --reverse --border --info=inline"

# ──────────────────────────────────────────────────────────────────────────────
# atuin  —  must be after fzf so it wins the Ctrl+R binding
# ──────────────────────────────────────────────────────────────────────────────
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# Fuzzy git branch checkout — local + remote, deduped
gcof() {
  local branch
  branch=$(
    git for-each-ref --format='%(refname:short)' refs/heads/ refs/remotes/ 2>/dev/null \
      | grep -v 'HEAD$' \
      | sed 's|^origin/||' \
      | awk '!seen[$0]++' \
      | fzf --prompt='checkout ❯ '
  ) || return
  [[ -n "$branch" ]] && git checkout "$branch"
}

# ──────────────────────────────────────────────────────────────────────────────
# Auto-activate Python venv on cd  (looks for .venv or venv walking up)
# ──────────────────────────────────────────────────────────────────────────────
_auto_venv() {
  emulate -L zsh
  local d="$PWD" venv=""
  while [[ "$d" != "/" && "$d" != "$HOME" ]]; do
    if [[ -f "$d/.venv/bin/activate" ]]; then venv="$d/.venv"; break; fi
    if [[ -f "$d/venv/bin/activate"  ]]; then venv="$d/venv";  break; fi
    d="${d:h}"
  done

  _deactivate_venv() {
    if type deactivate >/dev/null 2>&1; then
      deactivate >/dev/null 2>&1
    else
      unset VIRTUAL_ENV VIRTUAL_ENV_PROMPT
    fi
  }

  if [[ -n "$venv" ]]; then
    # re-source if venv changed OR if deactivate is missing (after exec zsh)
    if [[ "${VIRTUAL_ENV:-}" != "$venv" ]] || ! type deactivate >/dev/null 2>&1; then
      [[ -n "${VIRTUAL_ENV:-}" ]] && _deactivate_venv
      source "$venv/bin/activate"
    fi
  else
    [[ -n "${VIRTUAL_ENV:-}" ]] && _deactivate_venv
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _auto_venv
_auto_venv

# ──────────────────────────────────────────────────────────────────────────────
# Shell utilities — no dependencies, pure zsh
# ──────────────────────────────────────────────────────────────────────────────

# mkdir + cd in one
mkcd() { mkdir -p "$1" && cd "$1"; }

# kill whatever is on a port
killport() {
  local pid
  pid=$(lsof -ti tcp:"$1")
  if [[ -z "$pid" ]]; then
    echo "nothing on port $1"
    return 1
  fi
  echo "killing $pid on port $1"
  kill -9 $pid
}

# quick HTTP server in current folder
serve() { python3 -m http.server "${1:-8000}"; }

# universal archive extractor
extract() {
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;;
    *.tar)     tar xf  "$1" ;;
    *.zip)     unzip   "$1" ;;
    *.gz)      gunzip  "$1" ;;
    *.bz2)     bunzip2 "$1" ;;
    *.rar)     unrar x "$1" ;;
    *.7z)      7z x    "$1" ;;
    *)         echo "unknown format: $1" ;;
  esac
}

# go up N directories
up() { cd "$(printf '../%.0s' $(seq 1 "${1:-1}"))"; }

# create a temp dir and cd into it
tmpdir() { cd "$(mktemp -d)"; }

# list env vars, optionally filtered
envs() { env | sort | grep -i "${1:-.}"; }

# copy current path to clipboard
copypath() { pwd | tr -d '\n' | pbcopy && echo "copied: $(pwd)"; }

# public IP
myip() { curl -s https://api.ipify.org && echo; }

# scan all devices on current wifi
scan() {
  local ip
  ip=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)
  if [[ -z "$ip" ]]; then echo "not connected to wifi"; return 1; fi
  local subnet="${ip%.*}.0/24"
  local tmpfile=$(mktemp)

  setopt LOCAL_OPTIONS NO_MONITOR NO_NOTIFY

  sudo -v || return 1
  sudo nmap -sn -R --system-dns "$subnet" > "$tmpfile" 2>/dev/null &
  local nmap_pid=$!

  local frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
  local i=1
  while kill -0 $nmap_pid 2>/dev/null; do
    printf "\r  ${frames[$i]} scanning your network..."
    i=$(( (i % ${#frames}) + 1 ))
    sleep 0.08
  done
  wait $nmap_pid 2>/dev/null
  printf "\r\033[K"

  echo "Devices on your network:\n"
  awk '
    function clean(h) {
      gsub(/\.fritz\.box$/, "", h)
      gsub(/\.local$/, "", h)
      gsub(/\.home$/, "", h)
      if (h == "fritz.box" || h == "router" || h == "gateway") return "Router"
      gsub(/-mbp$/, " MacBook Pro", h)
      gsub(/-mbair$/, " MacBook Air", h)
      gsub(/-imac$/, " iMac", h)
      if (h == "iphone") return "iPhone"
      if (h == "ipad") return "iPad"
      if (h == "appletv") return "Apple TV"
      if (h == "homepod") return "HomePod"
      gsub(/-/, " ", h)
      return toupper(substr(h,1,1)) substr(h,2)
    }
    /Nmap scan report for/ {
      if (current_ip != "") {
        count++
        name = (current_mac == "") ? "This Mac" : clean(current_host)
        printf "  %-28s %s\n", name, current_ip
      }
      if (NF >= 6) {
        current_host = $5
        current_ip = $NF
        gsub(/[()]/, "", current_ip)
      } else {
        current_host = ""
        current_ip = $5
      }
      current_mac = ""
    }
    /MAC Address:/ { current_mac = $3 }
    END {
      if (current_ip != "") {
        count++
        name = (current_mac == "") ? "This Mac" : clean(current_host)
        printf "  %-28s %s\n", name, current_ip
      }
      printf "\n  %d devices on your network\n", count+0
    }
  ' "$tmpfile"
  rm -f "$tmpfile"
}

# ──────────────────────────────────────────────────────────────────────────────
# pip  —  block accidental global installs; route through uv for speed
# ──────────────────────────────────────────────────────────────────────────────
pip() {
  if [[ "$1" == "install" && -z "$VIRTUAL_ENV" ]]; then
    echo "no venv active. run: newvenv"
    echo "to install globally anyway: command pip $@"
    return 1
  fi
  uv pip "$@"
}

alias newvenv='uv venv && source .venv/bin/activate'

# ──────────────────────────────────────────────────────────────────────────────
# llm  —  AI from the terminal. Usage: llm "question"  or  cmd | llm "question"
# `ai` is a resilient wrapper that falls back if the free model is rate-limited.
# ──────────────────────────────────────────────────────────────────────────────
ai() {
  local models=(
    "openrouter/deepseek/deepseek-v4-flash:free"
    "openrouter/meta-llama/llama-3.3-70b-instruct:free"
    "openrouter/openai/gpt-oss-20b:free"
  )
  for model in "${models[@]}"; do
    llm -m "$model" "$@" && return
  done
  echo "all free models failed" >&2
  return 1
}

# ──────────────────────────────────────────────────────────────────────────────
# mise  —  runtime version manager + task runner (python, node, etc. per project)
# ──────────────────────────────────────────────────────────────────────────────
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Local overrides (machine-specific, never commit)
# ──────────────────────────────────────────────────────────────────────────────
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ──────────────────────────────────────────────────────────────────────────────
# zsh-autosuggestions  —  fish-like history suggestions (→ to accept)
# zsh-you-should-use   —  reminds you when you forget your own aliases
# zsh-syntax-highlighting  —  real-time command highlighting (must be last)
# ──────────────────────────────────────────────────────────────────────────────
[[ -f "$(brew --prefix)/share/zsh-you-should-use/you-should-use.plugin.zsh" ]] && \
  source "$(brew --prefix)/share/zsh-you-should-use/you-should-use.plugin.zsh"
[[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Tab: accept autosuggestion if one is showing, otherwise normal completion
_tab_or_autosuggest() {
  if [[ -n "$POSTDISPLAY" ]]; then
    zle autosuggest-accept
  else
    zle expand-or-complete
  fi
}
zle -N _tab_or_autosuggest
bindkey '^I' _tab_or_autosuggest

[[ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
