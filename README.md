# dotfiles

My macOS shell + git + ssh setup. zsh, starship, fzf, zoxide, auto-activated Python venvs.

## Install on a fresh Mac

```bash
# Prereq: Homebrew + the three QoL tools
brew install starship fzf zoxide gh
"$(brew --prefix)"/opt/fzf/install --all --no-bash --no-fish

# Clone and link
git clone git@github.com:elyesj23/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh

# New shell
exec zsh
```

## What's in here

| File | Purpose |
| --- | --- |
| `.zshrc` | Interactive zsh config: PATH, history, completions, aliases, starship init, fzf, zoxide, auto-venv hook, `gcof` fuzzy branch checkout |
| `.zprofile` | Login-shell config: Homebrew shellenv |
| `.gitconfig` | Git defaults + aliases (`st`, `co`, `cb`, `lg`, `lga`, `last`, `unstage`, `wip`, `root`) |
| `.gitignore_global` | macOS junk, editor caches, `.env*`, logs |
| `.ssh/config` | Sane `Host *` defaults + GitHub/GitLab entries (UseKeychain, AddKeysToAgent, keepalives) |
| `.config/starship.toml` | Two-line plain-ASCII prompt with truncated branch + Python venv badge |

## Local overrides

`.zshrc` sources `~/.zshrc.local` at the end if it exists. Put machine-specific tweaks (work env vars, project paths, secrets you actually want in shell scope) there. Never commit it.

## Update

Pull new changes and re-run the installer (idempotent):

```bash
cd ~/dotfiles && git pull && ./install.sh
```

## Rollback

`install.sh` backs up any pre-existing real file as `*.bak.<timestamp>` before symlinking.
