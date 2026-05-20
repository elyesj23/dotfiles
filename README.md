# dotfiles

My personal macOS dev setup — zsh, starship, and a curated stack of CLI tools that make terminal life actually enjoyable. Built for an AI engineer who lives in the terminal and wants things fast, visual, and out of the way.

> **Before you clone and run:** this repo is personalised to my machine. If you use it as a base, update the `[user]` block in `.gitconfig` with your own name and email, and review `.zshrc` for anything machine-specific. Running `install.sh` blindly on your machine will symlink my config over yours — back up first.

---

## What you get

### Prompt
[Starship](https://starship.rs) with Catppuccin Mocha colours and Nerd Font icons — shows git branch, status, Python venv, command duration, and a red `no venv` badge when a `.venv` exists but isn't active.

### Shell
| Plugin | What it does |
|--------|-------------|
| zsh-autosuggestions | Fish-like inline history suggestions (→ to accept) |
| zsh-syntax-highlighting | Commands turn green when valid, red when not |
| zsh-you-should-use | Reminds you when you type a command you have an alias for |
| atuin | Searchable shell history across sessions with timestamps |
| zoxide | Smarter `cd` — `z foo` jumps to the most-used dir matching `foo` |
| fzf | Fuzzy finder wired to Ctrl+R (history), Ctrl+T (files), Alt+C (dirs) |
| direnv | Per-directory env vars — drop a `.envrc` in any project, it auto-loads on `cd` |

### CLI tools
| Tool | Replaces | Why |
|------|----------|-----|
| eza | ls | Icons, git status, tree view |
| bat | cat | Syntax highlighting, line numbers |
| git-delta | git's built-in diff | Side-by-side diffs with line numbers |
| ripgrep | grep | Much faster, smarter defaults |
| fd | find | Simpler syntax, faster |
| xh | curl | Readable output, sane defaults |
| btop | htop | Visual CPU/RAM/network monitor |
| lazygit | git CLI | Full TUI for git — stage, diff, rebase visually |
| atuin | Ctrl+R | Searchable, timestamped history with cwd context |
| fx | jq | Interactive JSON explorer |
| llm | — | AI from the terminal: `llm "explain this"` or `cat file \| llm "summarise"` |
| uv | pip | 10–100× faster Python package management |
| mise | nvm/pyenv | Per-project Python/Node version switching, auto-activates on `cd` |
| gitleaks | — | Secret scanner — wired into the global pre-commit hook |

### Shell functions (no install needed)
```
mkcd <name>      mkdir + cd in one shot
killport 3000    kill whatever process is on that port
serve            spin up a local HTTP server in the current directory
extract <file>   unzip/untar anything regardless of format
up 2             go up N directories
tmpdir           create a temp dir and cd into it
copypath         copy current path to clipboard
myip             print your public IP
envs [filter]    list env vars, optionally filtered
gcof             fuzzy git branch checkout with fzf
ai "question"    LLM shortcut with free model fallback chain
newvenv          create a .venv and activate it with uv
```

### Git
- delta for diffs (side-by-side, line numbers, syntax highlighting)
- A full set of aliases (`gs`, `gl`, `gco`, `gcof`, `gd`, `gds`, `lz` for lazygit)
- `rerere` enabled — git remembers conflict resolutions
- `histogram` diff algorithm (better than default)
- `zdiff3` conflict style (shows the common ancestor)

### Pre-commit hook (global, applies to every repo)
Runs before every `git commit` on this machine — not committed to any repo, invisible to teammates.

| Check | Details |
|-------|---------|
| Branch guard | Blocks direct commits to `main` or `master` |
| Secret scanning | gitleaks with 150+ built-in patterns (API keys, tokens, credentials) |
| Large files | Blocks files over 500KB staged by accident |
| Python lint | Runs `ruff check` + `ruff format --check` on staged `.py` files |

Bypass with `git commit --no-verify` if you genuinely need to skip it.

---

## Install on a fresh Mac

```bash
# 1. Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Clone
git clone git@github.com:elyesj23/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 3. Link + install everything
./install.sh

# 4. Apply macOS system defaults (one-time)
./macos.sh

# 5. Reload shell
exec zsh
```

`install.sh` is idempotent — safe to re-run after pulling updates. Any existing files are backed up to `*.bak.<timestamp>` before being replaced.

---

## Per-project env vars

Create a `.envrc` in any project root — direnv loads it on `cd` and unloads on `cd` away:

```bash
# .envrc
export ANTHROPIC_API_KEY=sk-ant-...
export DATABASE_URL=postgres://...
```

Run `direnv allow` once after creating or editing the file. Never commit `.envrc` files with secrets — `.env*` is already in `.gitignore_global`.

---

## Machine-specific overrides

`.zshrc` sources `~/.zshrc.local` at the end if it exists. Put anything machine-specific there — work credentials, project paths, private aliases. Never commit it.

---

## Update

```bash
cd ~/dotfiles && git pull && ./install.sh
```

## Rollback

Every file that was replaced gets backed up as `*.bak.<timestamp>` — check your home directory.
