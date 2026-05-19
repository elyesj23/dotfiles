# ~/.zshrc — interactive shell config
# Originals backed up to ~/dotfiles-backup-<timestamp>/

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
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
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
# Aliases
# ──────────────────────────────────────────────────────────────────────────────
alias ls='ls -G'
alias ll='ls -lhG'
alias la='ls -lhAG'
alias l='ls -CF'
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
  if [[ -n "$venv" ]]; then
    if [[ "${VIRTUAL_ENV:-}" != "$venv" ]]; then
      [[ -n "${VIRTUAL_ENV:-}" ]] && type deactivate >/dev/null 2>&1 && deactivate >/dev/null 2>&1
      source "$venv/bin/activate"
    fi
  else
    [[ -n "${VIRTUAL_ENV:-}" ]] && type deactivate >/dev/null 2>&1 && deactivate >/dev/null 2>&1
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _auto_venv
_auto_venv

# ──────────────────────────────────────────────────────────────────────────────
# Local overrides (machine-specific, never commit)
# ──────────────────────────────────────────────────────────────────────────────
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
