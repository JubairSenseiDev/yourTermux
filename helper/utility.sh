#!/usr/bin/env bash
# yourTermux - Author: JubairSenseiDev - https://github.com/JubairSenseiDev/yourTermux
#
# utility — post-install tweaks: copy font, change shell, hide motd.
# Each step is wrapped in safe-run so a single failure doesn't abort all.

function utility() {

  echo -e "\n‏‏‎‏‏‎ ‎ ‎‏‏‎  ‎📦 Running utility setup\n"

  # 1. Copy nerd font to system fonts (if exists)
  local src_font=""
  for cand in \
    "$HOME/.fonts/JetBrains Mono Medium Nerd Font Complete.ttf" \
    "$HOME/.fonts/JetBrains Mono Bold Nerd Font Complete.ttf" \
    "$HOME/.fonts/Fira Code Medium Nerd Font Complete Mono.ttf"; do
    if [[ -f "$cand" ]]; then
      src_font="$cand"
      break
    fi
  done

  if [[ -n "$src_font" ]]; then
    mkdir -p "$PREFIX/share/fonts/TTF" 2>/dev/null
    if cp "$src_font" "$PREFIX/share/fonts/TTF/" 2>/dev/null; then
      echo "  ✔ Copied nerd font to \$PREFIX/share/fonts/TTF/"
    else
      echo "  ⚠ Could not copy font — continuing"
    fi
  else
    echo "  ⚠ No nerd font found in ~/.fonts — skipping font install"
  fi

  # 2. Change default shell to zsh (only if zsh is installed)
  if command -v zsh >/dev/null 2>&1; then
    if chsh -s zsh 2>/dev/null; then
      echo "  ✔ Default shell set to zsh"
    else
      echo "  ⚠ chsh failed — you can manually run: chsh -s zsh"
    fi
  else
    echo "  ⚠ zsh not installed — skipping chsh. Install with: pkg install zsh"
  fi

  # 3. Hide stock Termux motd (backup instead of delete)
  if [[ -f "$PREFIX/etc/motd" ]]; then
    mkdir -p "$HOME/motd"
    if mv "$PREFIX/etc/motd" "$HOME/motd/motd.backup" 2>/dev/null; then
      echo "  ✔ Backed up \$PREFIX/etc/motd to ~/motd/motd.backup"
    else
      echo "  ⚠ Could not move motd (permission denied?) — continuing"
    fi
  fi

}
