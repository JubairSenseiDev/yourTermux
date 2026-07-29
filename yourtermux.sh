#!/usr/bin/env bash
#
# yourtermux.sh — Single-entry menu-driven controller for yourTermux
# Author: JubairSenseiDev
#
# Run it:
#   ./yourtermux.sh
#   ./yourtermux.sh install        # jump straight to install menu
#   ./yourtermux.sh banner         # jump straight to banner customizer
#   ./yourtermux.sh keys           # jump straight to key customizer
#   ./yourtermux.sh suggestions    # jump straight to command suggestions
#
# No file editing needed — everything is done from menus.
#

set -uo pipefail

# ── Constants ──────────────────────────────────────────────────────────────
YT_VERSION="1.0.0"
YT_AUTHOR="JubairSenseiDev"
YT_REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YT_HOME_CONFIG="${HOME}/.config/yourtermux"
YT_BANNER_DIR="${HOME}/.local/share/yourtermux/banner"
YT_BANNER_LAUNCHER="${HOME}/.local/bin/yourtermux-banner"
YT_TERMUX_PROPS="${HOME}/.termux/termux.properties"
YT_ALIASES_FILE="${HOME}/.aliases"
YT_ZSHRC_FILE="${HOME}/.zshrc"

# ── Colors (only if TTY) ──────────────────────────────────────────────────
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  C_RESET="\033[0m"
  C_BOLD="\033[1m"
  C_DIM="\033[2m"
  C_RED="\033[1;31m"
  C_GREEN="\033[1;32m"
  C_YELLOW="\033[1;33m"
  C_BLUE="\033[1;34m"
  C_MAGENTA="\033[1;35m"
  C_CYAN="\033[1;36m"
  C_WHITE="\033[1;37m"
  C_BG_BLUE="\033[44;1;37m"
  C_BG_GREEN="\033[42;1;30m"
  C_BG_YELLOW="\033[43;1;30m"
else
  C_RESET=""; C_BOLD=""; C_DIM=""; C_RED=""; C_GREEN=""; C_YELLOW=""
  C_BLUE=""; C_MAGENTA=""; C_CYAN=""; C_WHITE=""
  C_BG_BLUE=""; C_BG_GREEN=""; C_BG_YELLOW=""
fi

# ── Helpers ────────────────────────────────────────────────────────────────
print_banner() {
  echo -e "${C_CYAN}"
  cat <<'BANNER'
    __   __ _______ _______ _______ ___   _______
    \ \ / /|  ___  |  ___  |  ___  |   | |  _____|
     \ V / | |   | | |   | | |   | |   | | |_____
      | |  | |   | | |   | | |   | |   | |_____  |
      | |  | |___| | |___| | |___| |___| |_____|
      |_|  |_______|_______|_______|_______|_____|
BANNER
  echo -e "${C_RESET}"
  echo -e "    ${C_YELLOW}Version ${C_WHITE}: ${C_GREEN}${YT_VERSION}"
  echo -e "    ${C_YELLOW}Author  ${C_WHITE}: ${C_MAGENTA}${YT_AUTHOR}"
  echo -e "    ${C_RESET}"
}

print_header() {
  local title="$1"
  echo
  echo -e "  ${C_BG_BLUE} ${C_BOLD} ${title} ${C_RESET}"
  echo -e "  ${C_DIM}$(printf '%.0s─' $(seq 1 $((${#title} + 4))))${C_RESET}"
  echo
}

print_ok()    { echo -e "  ${C_GREEN}✔ $*${C_RESET}"; }
print_warn()  { echo -e "  ${C_YELLOW}⚠ $*${C_RESET}"; }
print_err()   { echo -e "  ${C_RED}✘ $*${C_RESET}"; }
print_info()  { echo -e "  ${C_BLUE}ℹ $*${C_RESET}"; }
print_dim()   { echo -e "  ${C_DIM}$*${C_RESET}"; }

pause_enter() {
  echo
  if [[ -t 0 ]]; then
    read -rp $'\033[2m  Press Enter to continue...\033[0m' _
  else
    read -rp $'\033[2m  Press Enter to continue...\033[0m' _
  fi
}

confirm() {
  local prompt="$1"
  local default="${2:-y}"
  local yn
  if [[ "$default" == "y" ]]; then
    if [[ -t 0 ]]; then
      read -rp "$(echo -e "  ${C_YELLOW}${prompt} [Y/n] ${C_RESET}")" yn
    else
      read -rp "$(echo -e "  ${C_YELLOW}${prompt} [Y/n] ${C_RESET}")" yn
    fi
    [[ -z "$yn" || "$yn" =~ ^[Yy]$ ]]
  else
    if [[ -t 0 ]]; then
      read -rp "$(echo -e "  ${C_YELLOW}${prompt} [y/N] ${C_RESET}")" yn
    else
      read -rp "$(echo -e "  ${C_YELLOW}${prompt} [y/N] ${C_RESET}")" yn
    fi
    [[ "$yn" =~ ^[Yy]$ ]]
  fi
}

# read wrapper that uses /dev/tty when interactive, stdin otherwise
yt_read() {
  if [[ -t 0 ]]; then
    read "$@"
  else
    read "$@"
  fi
}

ensure_dirs() {
  mkdir -p "$YT_HOME_CONFIG" "$YT_BANNER_DIR" "$HOME/.local/bin" "$HOME/.termux" 2>/dev/null
}

# ── Banner customizer ────────────────────────────────────────────────────
# Lets the user pick preset ASCII art OR type their own one-line banner,
# then choose color, and write a tiny banner.sh to ~/.local/share/yourtermux/banner/banner-custom.sh
# plus update the yourtermux-banner launcher to prefer it.

banner_presets() {
  cat <<'EOF'
┌──── PRESET BANNERS ────┐
│  1. Block big (default) │
│  2. Slant                │
│  3. Simple single-line   │
│  4. Boxed                │
│  5. Hacker green         │
│  6. Custom text (you type) │
└──────────────────────────┘
EOF
}

banner_preset_art() {
  case "$1" in
    1) # Block big (default)
      cat <<'ART'
    __   __ _______ _______ _______ ___   _______
    \ \ / /|  ___  |  ___  |  ___  |   | |  _____|
     \ V / | |   | | |   | | |   | |   | | |_____
      | |  | |   | | |   | | |   | |   | |_____  |
      | |  | |___| | |___| | |___| |___| |_____|
      |_|  |_______|_______|_______|_______|_____|
ART
      ;;
    2) # Slant
      cat <<'ART'
       __                          __
      / /_  ____  _________  ____  / /_
     / __ \/ __ \/ ___/ __ \/ __ \/ __/
    / /_/ / /_/ / /  / /_/ / / / / /_
   /_.___/\____/_/   \__,_/_/ /_/\__/
ART
      ;;
    3) # Simple single-line
      echo "  >> yourTermux :: by ${YT_AUTHOR} :: v${YT_VERSION} <<"
      ;;
    4) # Boxed
      cat <<ART
  ┌─────────────────────────────────────────────┐
  │          yourTermux  v${YT_VERSION}                │
  │          by ${YT_AUTHOR}                  │
  └─────────────────────────────────────────────┘
ART
      ;;
    5) # Hacker green
      cat <<'ART'
  ▓▓▓ yourTermux ▓▓▓
  [ ACCESS GRANTED ]
  user: jubair
  ver : 1.0.0
ART
      ;;
  esac
}

banner_customize_menu() {
  while true; do
    clear
    print_banner
    print_header "BANNER CUSTOMIZER"
    echo -e "  Create your own banner. Pick a preset or write your own text."
    echo
    banner_presets
    echo
    echo -e "  ${C_DIM}0. Back to main menu${C_RESET}"
    echo
    read -rp "$(echo -e "  ${C_BOLD}Choice${C_RESET} [0-6]: ")" choice

    case "$choice" in
      0) return 0 ;;
      [1-5])
        banner_write_preset "$choice"
        ;;
      6)
        banner_write_custom
        ;;
      *) print_err "Invalid choice"; sleep 1 ;;
    esac
  done
}

banner_pick_color() {
  # Sets the global BANNER_PICKED_COLOR variable
  echo
  echo -e "  Pick banner color:"
  echo -e "    ${C_RED}1${C_RESET}. Red     ${C_GREEN}2${C_RESET}. Green    ${C_YELLOW}3${C_RESET}. Yellow"
  echo -e "    ${C_BLUE}4${C_RESET}. Blue    ${C_MAGENTA}5${C_RESET}. Magenta  ${C_CYAN}6${C_RESET}. Cyan"
  echo -e "    ${C_WHITE}7${C_RESET}. White   8. No color"
  echo
  read -rp "$(echo -e "  ${C_BOLD}Color${C_RESET} [1-8, default 6]: ")" color
  case "${color:-6}" in
    1) BANNER_PICKED_COLOR="red" ;;
    2) BANNER_PICKED_COLOR="green" ;;
    3) BANNER_PICKED_COLOR="yellow" ;;
    4) BANNER_PICKED_COLOR="blue" ;;
    5) BANNER_PICKED_COLOR="magenta" ;;
    6) BANNER_PICKED_COLOR="cyan" ;;
    7) BANNER_PICKED_COLOR="white" ;;
    8) BANNER_PICKED_COLOR="none" ;;
    *) BANNER_PICKED_COLOR="cyan" ;;
  esac
}

banner_write_preset() {
  local preset="$1"
  banner_pick_color
  local color="$BANNER_PICKED_COLOR"

  local art
  art=$(banner_preset_art "$preset")

  banner_save "preset-${preset}" "$color" "$art"
}

banner_write_custom() {
  echo
  echo -e "  ${C_DIM}Type your banner text (multi-line supported). Press Ctrl+D when done.${C_RESET}"
  echo
  local art=""
  while IFS= read -r line; do
    art+="${line}"$'\n'
  done

  if [[ -z "$art" ]]; then
    print_err "Empty banner, cancelled."
    pause_enter
    return 1
  fi

  local color
  banner_pick_color
  color="$BANNER_PICKED_COLOR"

  banner_save "custom" "$color" "$art"
}

banner_save() {
  local name="$1"
  local color="$2"
  local art="$3"

  ensure_dirs

  local color_code=""
  case "$color" in
    red)     color_code='\033[1;31m' ;;
    green)   color_code='\033[1;32m' ;;
    yellow)  color_code='\033[1;33m' ;;
    blue)    color_code='\033[1;34m' ;;
    magenta) color_code='\033[1;35m' ;;
    cyan)    color_code='\033[1;36m' ;;
    white)   color_code='\033[1;37m' ;;
    none)    color_code='' ;;
  esac

  local file="$YT_BANNER_DIR/banner-custom.sh"

  # Build the art as a single-quoted bash string (escape any single quotes inside)
  local art_escaped="${art//\'/\'\\\'\'}"

  # Write the banner script using printf for safe variable embedding.
  # color_code is already a literal string like \033[1;35m (no shell expansion).
  {
    printf '%s\n' '#!/usr/bin/env bash'
    printf '# Auto-generated by yourtermux.sh — custom banner: %s\n' "$name"
    printf '# Author: %s\n' "$YT_AUTHOR"
    printf '# Color: %s\n' "$color"
    printf '# Generated: %s\n' "$(date)"
    printf '\n'
    printf "ART='%s'\n" "$art_escaped"
    printf '\n'
    printf 'if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then\n'
    printf "  C='%s'\n" "$color_code"
    printf "  R=\$'\\\\033[0m'\n"
    printf 'else\n'
    printf '  C=""\n'
    printf '  R=""\n'
    printf 'fi\n'
    printf '\n'
    printf 'printf %%b "${C}${ART}${R}"\n'
    printf 'printf "\\n"\n'
    printf 'printf "    Version : %s\\n"\n' "$YT_VERSION"
    printf 'printf "    Author  : %s\\n"\n' "$YT_AUTHOR"
    printf 'printf "\\n"\n'
  } >"$file"
  chmod +x "$file"

  # Write the launcher to prefer the custom banner
  cat >"$YT_BANNER_LAUNCHER" <<'EOF'
#!/usr/bin/env bash
# yourtermux-banner launcher — auto-generated by yourtermux.sh
set -euo pipefail

BANNER_DIR="${HOME}/.local/share/yourtermux/banner"

if [[ -x "$BANNER_DIR/banner-custom.sh" ]]; then
  exec bash "$BANNER_DIR/banner-custom.sh" "$@"
elif [[ -x "$BANNER_DIR/banner-go" ]]; then
  exec "$BANNER_DIR/banner-go" "$@"
elif [[ -r "$BANNER_DIR/banner.sh" ]]; then
  exec bash "$BANNER_DIR/banner.sh" "$@"
elif command -v python3 >/dev/null 2>&1 && [[ -r "$BANNER_DIR/banner.py" ]]; then
  exec python3 "$BANNER_DIR/banner.py" "$@"
elif command -v node >/dev/null 2>&1 && [[ -r "$BANNER_DIR/banner.js" ]]; then
  exec node "$BANNER_DIR/banner.js" "$@"
else
  echo "yourtermux-banner: no banner implementation found." >&2
  exit 1
fi
EOF
  chmod +x "$YT_BANNER_LAUNCHER"

  print_ok "Banner saved to: $file"
  echo
  print_info "Preview:"
  echo
  bash "$file"
  pause_enter
}

banner_show_now() {
  if [[ -x "$YT_BANNER_LAUNCHER" ]]; then
    "$YT_BANNER_LAUNCHER"
  else
    print_warn "No banner installed yet. Use 'Banner customizer' first."
  fi
  pause_enter
}

# ── Key customizer ────────────────────────────────────────────────────────
# Lets the user build a custom extra-keys row for Termux.
# Focus: ⌨ (keyboard toggle), Shift, Tab, Enter, arrows, F1-F9, brackets.

key_presets() {
  cat <<'EOF'
┌─── KEY LAYOUT PRESETS ───┐
│ 1. Minimal (Shift Tab Enter ⌨)        │
│ 2. Coder (brackets + arrows + ⌨)      │
│ 3. Power user (F1-F9 + CTRL/ALT + ⌨)  │
│ 4. Default Termux (no extra keys)     │
│ 5. Build your own (row by row)        │
└──────────────────────────────────────┘
EOF
}

key_customize_menu() {
  while true; do
    clear
    print_banner
    print_header "KEY CUSTOMIZER"
    echo -e "  Customize the bottom button row above the keyboard."
    echo -e "  ${C_DIM}Special keys: ⌨ (toggle keyboard), Shift, Tab, Enter, CTRL, ALT, ESC${C_RESET}"
    echo
    key_presets
    echo
    echo -e "  ${C_DIM}0. Back to main menu${C_RESET}"
    echo
    read -rp "$(echo -e "  ${C_BOLD}Choice${C_RESET} [0-5]: ")" choice

    case "$choice" in
      0) return 0 ;;
      1) key_apply_preset_minimal ;;
      2) key_apply_preset_coder ;;
      3) key_apply_preset_power ;;
      4) key_apply_preset_default ;;
      5) key_build_custom ;;
      *) print_err "Invalid choice"; sleep 1 ;;
    esac
  done
}

key_write_props() {
  local extra_keys="$1"
  ensure_dirs

  # Backup current
  if [[ -f "$YT_TERMUX_PROPS" ]]; then
    cp "$YT_TERMUX_PROPS" "${YT_TERMUX_PROPS}.bak.$(date +%s)" 2>/dev/null
  fi

  cat >"$YT_TERMUX_PROPS" <<EOF
# yourTermux - Termux properties
# Author: ${YT_AUTHOR}
# Generated: $(date)
# Customize keys: ./yourtermux.sh keys

extra-keys = [ \\
${extra_keys} \\
]

allow-external-apps = true

# Session shortcuts (Volume Down + key)
shortcut.create-session = ctrl + t
shortcut.next-session = ctrl + 2
shortcut.previous-session = ctrl + 1
shortcut.rename-session = ctrl + u

# Scroll shortcuts
shortcut.scroll-up = ctrl + b
shortcut.scroll-down = ctrl + f

terminal-cursor-blink-rate = 600
EOF

  # Reload if termux-reload-settings is available
  if command -v termux-reload-settings >/dev/null 2>&1; then
    termux-reload-settings 2>/dev/null || true
    print_ok "Keys updated and Termux settings reloaded."
  else
    print_ok "Keys written. Run: termux-reload-settings"
  fi

  echo
  print_info "Current config:"
  echo
  cat "$YT_TERMUX_PROPS"
  pause_enter
}

key_apply_preset_minimal() {
  # Minimal: just the essentials — Shift, Tab, Enter, ⌨
  local keys="    ['SHIFT','TAB','ENTER',{key: KEYBOARD, popup: DRAWER}]"
  key_write_props "$keys"
}

key_apply_preset_coder() {
  # Coder: brackets + arrows + ⌨
  local keys="    ['CTRL','TAB','SHIFT',{key: KEYBOARD, popup: DRAWER},'LEFT','DOWN','UP','RIGHT'],
    ['ESC','/','\\\\','\$','{','}','(',')','-']"
  key_write_props "$keys"
}

key_apply_preset_power() {
  # Power user: F1-F9 + CTRL/ALT + ⌨ + arrows + brackets
  local keys="    ['F1','F2','F3','ESC','CTRL','ALT','TAB','HOME','UP','END'],
    ['F4','F5','F6',{key: KEYBOARD, popup: DRAWER},'-','<','>','(',')','LEFT','DOWN','RIGHT'],
    ['F7','F8','F9','/','\\\\','\$','{','}','[',']']"
  key_write_props "$keys"
}

key_apply_preset_default() {
  # Default Termux — no extra keys row
  local keys=""
  if [[ -f "$YT_TERMUX_PROPS" ]]; then
    cp "$YT_TERMUX_PROPS" "${YT_TERMUX_PROPS}.bak.$(date +%s)" 2>/dev/null
  fi
  cat >"$YT_TERMUX_PROPS" <<EOF
# yourTermux - Termux properties (default - no extra keys)
# Author: ${YT_AUTHOR}
# Generated: $(date)

allow-external-apps = true
terminal-cursor-blink-rate = 600
EOF
  if command -v termux-reload-settings >/dev/null 2>&1; then
    termux-reload-settings 2>/dev/null || true
    print_ok "Extra keys removed. Settings reloaded."
  else
    print_ok "Extra keys removed. Run: termux-reload-settings"
  fi
  pause_enter
}

key_build_custom() {
  clear
  print_banner
  print_header "BUILD CUSTOM KEY ROW"
  echo -e "  Build your own key row. Available keys:"
  echo
  echo -e "  ${C_CYAN}Modifiers${C_RESET}: CTRL  ALT  SHIFT  ESC  TAB  ENTER"
  echo -e "  ${C_CYAN}Arrows${C_RESET}:    LEFT  RIGHT  UP  DOWN  HOME  END"
  echo -e "  ${C_CYAN}Function${C_RESET}:  F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12"
  echo -e "  ${C_CYAN}Symbols${C_RESET}:   -  =  /  \\  \$  |  <  >  (  )  {  }  [  ]"
  echo -e "  ${C_CYAN}Special${C_RESET}:   ⌨ (keyboard toggle), DRAWER, BACKSLASH"
  echo
  echo -e "  ${C_DIM}Type keys separated by spaces. Empty line = end row.${C_RESET}"
  echo -e "  ${C_DIM}For ⌨ keyboard button, type: KEYBOARD${C_RESET}"
  echo

  local rows=()
  local row_num=1
  while [[ ${#rows[@]} -lt 5 ]]; do
    echo -e "  ${C_BOLD}Row ${row_num}${C_RESET} (or empty to finish):"
    read -rp "  > " line
    if [[ -z "$line" ]]; then
      break
    fi
    # Parse space-separated keys, build JSON-ish array
    local row_str="    ["
    local first=1
    for key in $line; do
      local upper
      upper=$(echo "$key" | tr '[:lower:]' '[:upper:]')
      local token
      case "$upper" in
        KEYBOARD|DRAWER|KEYBOARD-TOGGLE)
          token="{key: KEYBOARD, popup: DRAWER}"
          ;;
        SHIFT|CTRL|ALT|ESC|TAB|ENTER|HOME|END|LEFT|RIGHT|UP|DOWN|DELETE|BACKSLASH|PAGEUP|PAGEDOWN|INSERT)
          token="'${upper}'"
          ;;
        F[0-9]|F1[0-2])
          token="'${upper}'"
          ;;
        *)
          # Symbol or arbitrary char — wrap in quotes
          token="'${key}'"
          ;;
      esac
      if [[ $first -eq 1 ]]; then
        row_str+="$token"
        first=0
      else
        row_str+=",$token"
      fi
    done
    row_str+="]"
    if [[ $first -eq 1 ]]; then
      print_warn "Empty row, skipping."
      continue
    fi
    rows+=("$row_str")
    row_num=$((row_num + 1))
  done

  if [[ ${#rows[@]} -eq 0 ]]; then
    print_err "No rows entered."
    pause_enter
    return 1
  fi

  # Join rows with comma + backslash continuation
  local joined=""
  for i in "${!rows[@]}"; do
    if [[ $i -gt 0 ]]; then
      joined+=","
    fi
    joined+=$'\n'"${rows[$i]}"
  done

  key_write_props "$joined"
}

# ── Command suggestions manager ──────────────────────────────────────────
# Toggles the newbie-friendly aliases section in ~/.aliases on/off,
# and lets the user add their own commands.

SUGGESTION_MARKER_START="# ───── YT-HELP-START ─────"
SUGGESTION_MARKER_END="# ───── YT-HELP-END ─────"

suggestions_install_block() {
  cat <<'EOF'
# ───── YT-HELP-START ─────
# yourTermux - Newbie-friendly aliases (managed by yourtermux.sh)
# Author: JubairSenseiDev

alias banner="yourtermux-banner"
alias reload-termux="termux-reload-settings"
alias ipinfo="curl -s https://ipinfo.io"
alias topten="history | awk '{print \$2}' | sort | uniq -c | sort -rn | head -10"
alias size="du -sh"
alias bigfiles="du -ah . | sort -rh | head -20"
alias findfile="find . -iname"
alias search="grep -rn"
alias path='echo $PATH | tr ":" "\n"'
alias calc="python3"
alias today="date +'%A, %d %B %Y'"
alias weather="curl -s wttr.in | head -40"
alias sysupdate="pkg update -y && pkg upgrade -y && pkg autoclean -y && pkg autoremove -y"
alias ports="ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null"

yt-help() {
  cat <<'HELP'

  yourTermux - Quick command reference
  ─────────────────────────────────────────────────────
  Setup & customization:
    ./yourtermux.sh  Open the main menu (banner, keys, suggestions)

  Banner:
    banner           Show your custom banner
    yourtermux-banner  Same as above (auto-pick impl)

  Navigation:
    sd   cd /sdcard              dl   cd /sdcard/Download
    ds   cd /sdcard/Documents    pf   cd $PREFIX

  Package management:
    pacupgupd  pkg update && pkg upgrade
    sysupdate  Full update + autoclean + autoremove

  System info:
    ipinfo     Public IP info
    weather    Local weather
    ports      Listening TCP ports
    bigfiles   Top 20 largest files in current dir

  Files:
    search PATTERN   Recursive grep across files
    findfile NAME    Find file by name (case-insensitive)

  Type 'alias' to see all aliases.

HELP
}
# ───── YT-HELP-END ─────
EOF
}

suggestions_status() {
  if [[ -f "$YT_ALIASES_FILE" ]] && grep -q "$SUGGESTION_MARKER_START" "$YT_ALIASES_FILE"; then
    return 0  # installed
  else
    return 1  # not installed
  fi
}

suggestions_enable() {
  ensure_dirs
  touch "$YT_ALIASES_FILE"
  if suggestions_status; then
    print_warn "Already enabled."
    pause_enter
    return 0
  fi
  echo "" >>"$YT_ALIASES_FILE"
  suggestions_install_block >>"$YT_ALIASES_FILE"
  print_ok "Command suggestions enabled in $YT_ALIASES_FILE"
  print_info "Reload shell to apply:  exec \$SHELL -l"
  pause_enter
}

suggestions_disable() {
  if ! suggestions_status; then
    print_warn "Already disabled."
    pause_enter
    return 0
  fi
  # Use awk to remove the block between markers (inclusive)
  local tmp="${YT_ALIASES_FILE}.tmp.$$"
  awk -v s="$SUGGESTION_MARKER_START" -v e="$SUGGESTION_MARKER_END" '
    $0 ~ s { skip=1; next }
    $0 ~ e { skip=0; next }
    !skip { print }
  ' "$YT_ALIASES_FILE" >"$tmp" && mv "$tmp" "$YT_ALIASES_FILE"
  print_ok "Command suggestions removed from $YT_ALIASES_FILE"
  print_info "Reload shell to apply:  exec \$SHELL -l"
  pause_enter
}

suggestions_add_alias() {
  echo
  read -rp "$(echo -e "  ${C_BOLD}Alias name${C_RESET} (e.g. myip): ")" name
  [[ -z "$name" ]] && { print_warn "Cancelled."; pause_enter; return 1; }
  read -rp "$(echo -e "  ${C_BOLD}Command${C_RESET} (e.g. curl ifconfig.me): ")" cmd
  [[ -z "$cmd" ]] && { print_warn "Cancelled."; pause_enter; return 1; }

  ensure_dirs
  touch "$YT_ALIASES_FILE"
  echo "alias ${name}=\"${cmd}\"" >>"$YT_ALIASES_FILE"
  print_ok "Added: alias ${name}=\"${cmd}\""
  print_info "Reload shell to apply:  exec \$SHELL -l"
  pause_enter
}

suggestions_menu() {
  while true; do
    clear
    print_banner
    print_header "COMMAND SUGGESTIONS"
    if suggestions_status; then
      echo -e "  Status: ${C_GREEN}ENABLED${C_RESET}"
    else
      echo -e "  Status: ${C_DIM}disabled${C_RESET}"
    fi
    echo
    echo -e "  ${C_BOLD}1${C_RESET}. Enable newbie-friendly aliases + yt-help"
    echo -e "  ${C_BOLD}2${C_RESET}. Disable (remove) them"
    echo -e "  ${C_BOLD}3${C_RESET}. Add your own alias"
    echo -e "  ${C_BOLD}4${C_RESET}. Show ~/.aliases"
    echo -e "  ${C_DIM}0. Back to main menu${C_RESET}"
    echo
    read -rp "$(echo -e "  ${C_BOLD}Choice${C_RESET} [0-4]: ")" choice
    case "$choice" in
      0) return 0 ;;
      1) suggestions_enable ;;
      2) suggestions_disable ;;
      3) suggestions_add_alias ;;
      4)
        if [[ -f "$YT_ALIASES_FILE" ]]; then
          less "$YT_ALIASES_FILE"
        else
          print_warn "No ~/.aliases file yet."
          pause_enter
        fi
        ;;
      *) print_err "Invalid choice"; sleep 1 ;;
    esac
  done
}

# ── Install menu ─────────────────────────────────────────────────────────
# Two modes: Minimal (fast, just essentials) and Full (everything).

install_minimal() {
  print_header "MINIMAL INSTALL"
  echo -e "  ${C_DIM}Fast setup — only the essentials:${C_RESET}"
  echo -e "    • Custom banner (interactive)"
  echo -e "    • Bottom key row (interactive)"
  echo -e "    • Command suggestions enabled"
  echo -e "    • Default Termux theme (no zsh, no fonts, no themes)"
  echo

  if ! confirm "Proceed with MINIMAL install?"; then
    print_warn "Cancelled."
    pause_enter
    return 1
  fi

  ensure_dirs

  # 1. Banner: ask user to pick preset or skip
  echo
  if confirm "Set up a custom banner now?"; then
    banner_customize_menu
  else
    print_dim "Skipping banner setup. You can run ./yourtermux.sh banner later."
  fi

  # 2. Keys: ask user to pick preset or skip
  echo
  if confirm "Set up bottom key row now?"; then
    key_customize_menu
  else
    print_dim "Skipping key setup. You can run ./yourtermux.sh keys later."
  fi

  # 3. Suggestions: enable by default
  echo
  suggestions_enable

  print_ok "Minimal install complete!"
  echo
  print_info "Next steps:"
  echo -e "    ${C_DIM}1. Restart Termux${C_RESET}"
  echo -e "    ${C_DIM}2. Run: banner  (to see your banner)${C_RESET}"
  echo -e "    ${C_DIM}3. Run: yt-help  (to see command suggestions)${C_RESET}"
  echo
  pause_enter
}

install_full() {
  print_header "FULL INSTALL"
  echo -e "  ${C_DIM}Complete setup — installs everything:${C_RESET}"
  echo -e "    • All of the above (banner, keys, suggestions)"
  echo -e "    • ZSH + Oh My Zsh + plugins"
  echo -e "    • Nerd fonts"
  echo -e "    • Colorschemes"
  echo -e "    • NvChad (neovim)"
  echo -e "    • Color toys (pipes, bloks, etc.)"
  echo -e "    • Music player (mpd + ncmpcpp)"
  echo

  if ! confirm "Proceed with FULL install? (takes ~10-15 min)"; then
    print_warn "Cancelled."
    pause_enter
    return 1
  fi

  ensure_dirs

  # Run the original install.sh if it exists, otherwise just do basics
  if [[ -x "$YT_REPO_DIR/install.sh" ]]; then
    print_info "Running original install.sh (this takes a while)..."
    echo
    bash "$YT_REPO_DIR/install.sh"
  else
    print_warn "install.sh not found. Falling back to minimal."
    install_minimal
    return 0
  fi

  # After full install, also enable suggestions
  suggestions_enable

  print_ok "Full install complete!"
  pause_enter
}

install_menu() {
  while true; do
    clear
    print_banner
    print_header "INSTALL"
    echo -e "  ${C_BOLD}1${C_RESET}. ${C_GREEN}Minimal install${C_RESET}  — fast, just banner + keys + suggestions"
    echo -e "  ${C_BOLD}2${C_RESET}. ${C_YELLOW}Full install${C_RESET}     — everything (zsh, fonts, themes, nvim, music)"
    echo -e "  ${C_DIM}0. Back to main menu${C_RESET}"
    echo
    read -rp "$(echo -e "  ${C_BOLD}Choice${C_RESET} [0-2]: ")" choice
    case "$choice" in
      0) return 0 ;;
      1) install_minimal ;;
      2) install_full ;;
      *) print_err "Invalid choice"; sleep 1 ;;
    esac
  done
}

# ── Main menu ────────────────────────────────────────────────────────────
main_menu() {
  while true; do
    clear
    print_banner
    print_header "MAIN MENU"
    echo -e "  ${C_BOLD}1${C_RESET}. 🚀 Install         ${C_DIM}(Minimal or Full)${C_RESET}"
    echo -e "  ${C_BOLD}2${C_RESET}. 🎨 Banner          ${C_DIM}(create your own)${C_RESET}"
    echo -e "  ${C_BOLD}3${C_RESET}. ⌨  Keys            ${C_DIM}(customize bottom buttons)${C_RESET}"
    echo -e "  ${C_BOLD}4${C_RESET}. 💡 Suggestions     ${C_DIM}(command aliases + yt-help)${C_RESET}"
    echo -e "  ${C_BOLD}5${C_RESET}. 👀 Show banner     ${C_DIM}(preview current banner)${C_RESET}"
    echo -e "  ${C_BOLD}6${C_RESET}. ℹ️  About"
    echo -e "  ${C_BOLD}0${C_RESET}. ${C_RED}Exit${C_RESET}"
    echo
    read -rp "$(echo -e "  ${C_BOLD}Choice${C_RESET} [0-6]: ")" choice
    case "$choice" in
      1) install_menu ;;
      2) banner_customize_menu ;;
      3) key_customize_menu ;;
      4) suggestions_menu ;;
      5) banner_show_now ;;
      6) about ;;
      0) echo -e "  ${C_DIM}Bye 👋${C_RESET}"; exit 0 ;;
      *) print_err "Invalid choice"; sleep 1 ;;
    esac
  done
}

about() {
  print_header "ABOUT"
  cat <<EOF
  ${C_BOLD}yourTermux${C_RESET} v${YT_VERSION}
  Author: ${C_MAGENTA}${YT_AUTHOR}${C_RESET}

  Menu-driven controller for your Termux setup.
  Everything is customizable from menus — no file editing needed.

  ${C_DIM}Files this script manages:${C_RESET}
    ~/.config/yourtermux/             Config dir
    ~/.local/share/yourtermux/banner/ Banner scripts (incl. your custom one)
    ~/.local/bin/yourtermux-banner    Banner launcher
    ~/.termux/termux.properties       Custom keys
    ~/.aliases                        Command suggestions

  ${C_DIM}Quick commands:${C_RESET}
    banner                            Show your custom banner
    yt-help                           Show command cheat-sheet
    ./yourtermux.sh                   Open this menu

EOF
  pause_enter
}

# ── Entry point ──────────────────────────────────────────────────────────
main() {
  ensure_dirs

  # Direct sub-command shortcuts
  local sub="${1:-}"
  case "$sub" in
    install)     install_menu ;;
    banner)      banner_customize_menu ;;
    keys)        key_customize_menu ;;
    suggestions) suggestions_menu ;;
    about)       about ;;
    -h|--help)
      cat <<EOF
yourtermux.sh v${YT_VERSION} — menu-driven Termux controller
Author: ${YT_AUTHOR}

Usage:
  ./yourtermux.sh                Open main menu
  ./yourtermux.sh install        Jump to install menu
  ./yourtermux.sh banner         Jump to banner customizer
  ./yourtermux.sh keys           Jump to key customizer
  ./yourtermux.sh suggestions    Jump to command suggestions
  ./yourtermux.sh about          Show about info
  ./yourtermux.sh -h|--help      Show this help
EOF
      exit 0
      ;;
    "")
      main_menu
      ;;
    *)
      echo "Unknown subcommand: $sub" >&2
      echo "Run: ./yourtermux.sh --help"
      exit 2
      ;;
  esac
}

main "$@"
