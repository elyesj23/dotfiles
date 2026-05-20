#!/usr/bin/env bash
# Idempotent installer: symlinks files from this repo into $HOME.
# Existing non-symlink files are backed up to *.bak.<timestamp> before linking.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FILES=(
  ".zshrc"
  ".zprofile"
  ".gitconfig"
  ".gitignore_global"
  ".ssh/config"
  ".config/starship.toml"
)

link_one() {
  local rel="$1"
  local src="$DOTFILES/$rel"
  local dst="$HOME/$rel"

  [[ -e "$src" ]] || { echo "missing in repo: $src" >&2; return 1; }

  mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" ]]; then
    if [[ "$(readlink "$dst")" == "$src" ]]; then
      echo "= $dst (already linked)"
      return 0
    fi
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    local backup="$dst.bak.$(date +%s)"
    mv "$dst" "$backup"
    echo "~ backed up existing $dst -> $backup"
  fi

  ln -s "$src" "$dst"
  echo "+ $dst -> $src"
}

for f in "${FILES[@]}"; do link_one "$f"; done

# ── Homebrew packages ─────────────────────────────────────────────────────────
BREW_PACKAGES=(
  starship fzf zoxide gh          # prompt + navigation
  zsh-autosuggestions             # fish-like history suggestions
  zsh-syntax-highlighting         # real-time command highlighting
  direnv                          # per-directory env vars (.envrc)
  llm                             # pipe anything to an LLM from the terminal
  bat                             # cat with syntax highlighting
  git-delta                       # better git diffs
  uv                              # fast Python env/package manager
  lazygit                         # visual git TUI
  atuin                           # better shell history with search
  fx                              # interactive JSON explorer
  eza                             # better ls with icons and git status
  btop                            # visual system monitor
  zsh-you-should-use              # reminds you when you forget your own aliases
  xh                              # better curl with readable output
)

echo
echo "Checking Homebrew packages..."
for pkg in "${BREW_PACKAGES[@]}"; do
  if brew list "$pkg" &>/dev/null; then
    echo "= $pkg (already installed)"
  else
    echo "+ installing $pkg"
    brew install "$pkg"
  fi
done

# fzf shell integrations (idempotent)
"$(brew --prefix)"/opt/fzf/install --all --no-bash --no-fish --no-update-rc &>/dev/null && \
  echo "= fzf shell integrations (configured)"

# SSH is strict about permissions; enforce after linking.
chmod 700 "$HOME/.ssh"
chmod 600 "$DOTFILES/.ssh/config"

echo
echo "Done. Open a new terminal or run 'exec zsh' to pick up changes."
