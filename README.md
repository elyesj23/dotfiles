# dotfiles

My macOS shell + git + ssh setup. zsh, starship, fzf, zoxide, direnv, auto-activated Python venvs.

## Install on a fresh Mac

```bash
# Prereq: Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Clone, link, and install all packages
git clone git@github.com:elyesj23/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh

# New shell
exec zsh
```

## What's in here

| File | Purpose |
| --- | --- |
| `.zshrc` | Interactive zsh config: PATH, history, completions, aliases, direnv, bat, starship, fzf, zoxide, auto-venv hook, autosuggestions, syntax-highlighting |
| `.zprofile` | Login-shell config: Homebrew shellenv |
| `.gitconfig` | Git defaults + delta diffs + aliases (`st`, `co`, `cb`, `lg`, `lga`, `last`, `unstage`, `wip`, `root`) |
| `.gitignore_global` | macOS junk, editor caches, `.env*`, logs |
| `.ssh/config` | Sane `Host *` defaults + GitHub/GitLab entries (UseKeychain, AddKeysToAgent, keepalives) |
| `.config/starship.toml` | Two-line plain-ASCII prompt with truncated branch + Python venv badge |

## Per-project API keys with direnv

Create a `.envrc` in any project root — direnv auto-loads it on `cd` and unloads on `cd` away:

```bash
# .envrc
export ANTHROPIC_API_KEY=sk-ant-...
export MODEL=claude-sonnet-4-6
```

Run `direnv allow` once after creating/editing the file. Never commit `.envrc` files that contain secrets (`.env*` is already in `.gitignore_global`).

## Local overrides

`.zshrc` sources `~/.zshrc.local` at the end if it exists. Put machine-specific tweaks (work env vars, project paths, secrets you actually want in shell scope) there. Never commit it.

## Update

Pull new changes and re-run the installer (idempotent):

```bash
cd ~/dotfiles && git pull && ./install.sh
```

## Rollback

`install.sh` backs up any pre-existing real file as `*.bak.<timestamp>` before symlinking.
