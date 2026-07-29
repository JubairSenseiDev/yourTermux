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

# ── BUGFIX: detect recursion. If yourtermux.sh calls install.sh which calls
# yourtermux.sh which calls install.sh... we'd loop forever.
# Guard against that by checking an env var that yourtermux.sh sets before
# invoking this wrapper.
if [[ -n "${YT_INSTALL_RUNNING:-}" ]]; then
  echo "install.sh: detected recursion (YT_INSTALL_RUNNING is set)." >&2
  echo "  yourtermux.sh should call run_legacy_installer directly," >&2
  echo "  not exec install.sh. Aborting to prevent infinite loop." >&2
  exit 1
fi

# If yourtermux.sh exists, delegate to it
if [[ -x "$YT_DIR/yourtermux.sh" ]]; then
  exec bash "$YT_DIR/yourtermux.sh" install
fi

# ── Fallback: legacy installer (if yourtermux.sh is missing) ──────────────
# Mark that we're running the legacy install so a stray call to
# yourtermux.sh doesn't loop back into us.
export YT_INSTALL_RUNNING=1

HELPERS=(
  colors animation banner package switchcase
  dotfiles clone themes nvchad utility
  stat signal screen cursor finish
)

for HELPER in "${HELPERS[@]}"; do
  if [[ -r "$YT_DIR/helper/${HELPER}.sh" ]]; then
    # shellcheck disable=SC1090
    source "$YT_DIR/helper/${HELPER}.sh" || \
      echo "  ⚠ helper/${HELPER}.sh failed to source — skipping" >&2
  fi
done

# Install the standalone banner scripts (banner.sh/py/go/js) into the user's
# system so the `yourtermux-banner` command works after install.
function installBannerScripts() {

  setCursor off 2>/dev/null || true

  echo -e "‏‏‎‏‏‎ ‎ ‎‏‏‎  ‎📦 Installing yourTermux banner scripts"
  sleep 1s

  BANNER_DEST="$HOME/.local/share/yourtermux/banner"
  mkdir -p "$BANNER_DEST"

  for f in banner.sh banner.py banner.js banner.go; do
    if [[ -f "$YT_DIR/banner/${f}" ]]; then
      cp "$YT_DIR/banner/${f}" "$BANNER_DEST/${f}"
      chmod +x "$BANNER_DEST/${f}" 2>/dev/null || true
    fi
  done

  # If go is available, compile banner.go into a static binary for speed
  if command -v go >/dev/null 2>&1; then
    (
      cd "$BANNER_DEST"
      go build -o banner-go banner.go 2>/dev/null && rm -f banner.go
    ) || echo "  ⚠ Go compile failed — keeping banner.go source"
  fi

  # The yourtermux-banner launcher is already shipped in .local/bin/ via dotfiles
  chmod +x "$HOME/.local/bin/yourtermux-banner" 2>/dev/null || true

  setCursor on 2>/dev/null || true
}

function main() {

  trap 'handleInterruptByUser "Interrupt by User" 2>/dev/null || true' 2

  clear
  banner 2>/dev/null || echo "  yourTermux installer (legacy mode)"

  packages 2>/dev/null || echo "  ⚠ packages() failed — continuing"
  switchCase "Install" "Packages" installPackages 2>/dev/null || \
    installPackages 2>/dev/null || true

  dotFiles 2>/dev/null || echo "  ⚠ dotFiles() failed — continuing"
  backupDotFiles 2>/dev/null || echo "  ⚠ backupDotFiles() failed — continuing"
  switchCase "Install" "Dotfiles" installDotFiles 2>/dev/null || \
    installDotFiles 2>/dev/null || true

  repositories 2>/dev/null || echo "  ⚠ repositories() failed — continuing"
  switchCase "Clone" "Repositories" cloneRepository 2>/dev/null || \
    cloneRepository 2>/dev/null || true

  zshTheme 2>/dev/null || echo "  ⚠ zshTheme() failed — continuing"
  switchCase "Install" "ZSH Themes" installZshTheme 2>/dev/null || \
    installZshTheme 2>/dev/null || true

  NvChad 2>/dev/null || echo "  ⚠ NvChad() failed — continuing"
  utility 2>/dev/null || echo "  ⚠ utility() failed — continuing"

  # Install standalone banner scripts so `yourtermux-banner` works
  installBannerScripts 2>/dev/null || true

  mainAlert 2>/dev/null || echo "  ✔ Install complete"

}

screenSize main
