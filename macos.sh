#!/usr/bin/env bash
# One-time macOS system defaults for a developer setup.
# Run once after a fresh install: ./macos.sh
# Most changes take effect after restarting the affected app or logging out.

set -euo pipefail

echo "Applying macOS defaults..."

# ── Keyboard ──────────────────────────────────────────────────────────────────
# Fastest key repeat — essential for coding (hold backspace, arrow keys, etc.)
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable autocorrect, auto-capitalise, smart quotes — all annoying in terminal
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# ── Trackpad ──────────────────────────────────────────────────────────────────
# Tap to click (don't need to physically press down)
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# ── Finder ────────────────────────────────────────────────────────────────────
# Show all file extensions (.py, .jpg, .env etc.)
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show hidden files (dotfiles visible in Finder)
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show full path in Finder title bar
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Show path bar and status bar at bottom of Finder
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Default to list view in Finder (cleaner than icon view)
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Search current folder by default (not the whole Mac)
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Keep folders on top when sorting
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Remove items from Trash after 30 days
defaults write com.apple.finder FXRemoveOldTrashItems -bool true

# ── Screenshots ───────────────────────────────────────────────────────────────
# Save to ~/Desktop/Screenshots instead of cluttering Desktop
mkdir -p "$HOME/Desktop/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Desktop/Screenshots"

# Save as PNG (default) — change to jpg if you want smaller files
defaults write com.apple.screencapture type -string "png"

# Remove shadow from window screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# ── Dock ──────────────────────────────────────────────────────────────────────
# Instant show/hide when auto-hide is on (no delay)
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3

# Show only active apps in Dock (minimalist — remove if you want pinned apps)
# defaults write com.apple.dock static-only -bool true

# Smaller dock size
defaults write com.apple.dock tilesize -int 48

# Don't show recent apps in Dock
defaults write com.apple.dock show-recents -bool false

# ── Menu Bar ──────────────────────────────────────────────────────────────────
# Show battery percentage
defaults write com.apple.controlcenter "NSStatusItem Visible BatteryShowPercentage" -bool true

# ── TextEdit ──────────────────────────────────────────────────────────────────
# Default to plain text (not rich text) — useful for quick notes
defaults write com.apple.TextEdit RichText -int 0
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# ── Safari / WebKit (useful even if you use Chrome) ───────────────────────────
# Show full URL in address bar
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# ── Activity Monitor ──────────────────────────────────────────────────────────
# Show all processes (not just user processes)
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# ── Crash Reporter ────────────────────────────────────────────────────────────
# Disable crash reporter dialogs popping up
defaults write com.apple.CrashReporter DialogType -string "none"

# ── Restart affected apps ─────────────────────────────────────────────────────
echo "Restarting Finder and Dock..."
killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true

echo ""
echo "Done. Log out and back in for all changes to take effect."
