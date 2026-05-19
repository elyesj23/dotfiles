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

# SSH is strict about permissions; enforce after linking.
chmod 700 "$HOME/.ssh"
chmod 600 "$DOTFILES/.ssh/config"

echo
echo "Done. Open a new terminal or run 'exec zsh' to pick up changes."
