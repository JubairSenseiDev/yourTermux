#!/usr/bin/env bash
#
# yourTermux - Installer
# Author: JubairSenseiDev
#
# This is a thin wrapper around yourtermux.sh (the menu-driven controller).
# It opens the install menu where the user picks Minimal or Full install.
#
# Usage:
#   git clone --depth=1 https://github.com/JubairSenseiDev/yourTermux.git
#   cd yourTermux
#   ./install.sh                # opens install menu (Minimal / Full)
#

set -uo pipefail
YT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If yourtermux.sh exists, delegate to it
if [[ -x "$YT_DIR/yourtermux.sh" ]]; then
  exec bash "$YT_DIR/yourtermux.sh" install
fi

# ── Fallback: legacy installer (if yourtermux.sh is missing) ──────────────

HELPERS=(
  colors animation banner package switchcase
  dotfiles clone themes nvchad utility
  stat signal screen cursor finish
)

for HELPER in ${HELPERS[@]}; do
  source $(pwd)/helper/${HELPER}.sh
done

# Install the standalone banner scripts (banner.sh/py/go/js) into the user's
# system so the `yourtermux-banner` command works after install.
function installBannerScripts() {

  setCursor off

  echo -e "‏‏‎‏‏‎ ‎ ‎‏‏‎  ‎📦 Installing yourTermux banner scripts"
  sleep 1s

  BANNER_DEST="$HOME/.local/share/yourtermux/banner"
  mkdir -p "$BANNER_DEST"

  for f in banner.sh banner.py banner.js banner.go; do
    if [[ -f "$(pwd)/banner/${f}" ]]; then
      cp "$(pwd)/banner/${f}" "$BANNER_DEST/${f}"
      chmod +x "$BANNER_DEST/${f}" 2>/dev/null || true
    fi
  done

  # If go is available, compile banner.go into a static binary for speed
  if command -v go >/dev/null 2>&1; then
    (
      cd "$BANNER_DEST"
      go build -o banner-go banner.go 2>/dev/null && rm -f banner.go
    ) || true
  fi

  # The yourtermux-banner launcher is already shipped in .local/bin/ via dotfiles
  chmod +x "$HOME/.local/bin/yourtermux-banner" 2>/dev/null || true

  setCursor on
}

function main() {

  trap 'handleInterruptByUser "Interrupt by User"' 2

  clear
  banner

  packages
  switchCase "Install" "Packages" installPackages

  dotFiles
  backupDotFiles
  switchCase "Install" "Dotfiles" installDotFiles

  repositories
  switchCase "Clone" "Repositories" cloneRepository

  zshTheme
  switchCase "Install" "ZSH Themes" installZshTheme

  NvChad
  utility

  # Install standalone banner scripts so `yourtermux-banner` works
  installBannerScripts

  mainAlert

}

screenSize main
