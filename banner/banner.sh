#!/usr/bin/env bash
#
# yourTermux - Standalone banner script (Bash)
# Author: JubairSenseiDev
#
# Pure bash implementation, no external dependencies.
# Uses ANSI escape codes for color (graceful fallback to plain text
# when stdout is not a TTY or when colors are disabled).
#
# Usage:
#   ./banner.sh                # default cyan banner
#   ./banner.sh --color green  # override banner color
#   ./banner.sh --no-color     # disable colors
#   ./banner.sh --help
#
# Wire into shell start (optional):
#   echo 'command -v yourtermux-banner >/dev/null && yourtermux-banner' >> ~/.bashrc
#

set -euo pipefail

VERSION="1.0.0"
BUILD_DATE="$(date +'%d %B %Y')"
AUTHOR="JubairSenseiDev"
TAGLINE="Termux setup for new users"

# --- Color handling --------------------------------------------------------

BANNER_COLOR="cyan"
NO_COLOR=0

if [[ ! -t 1 ]]; then
  NO_COLOR=1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --color)
      BANNER_COLOR="${2:-cyan}"
      shift 2
      ;;
    --no-color)
      NO_COLOR=1
      shift
      ;;
    --help|-h)
      cat <<EOF
yourTermux banner (bash)

Usage: $0 [OPTIONS]

Options:
  --color COLOR   Banner color: red, green, yellow, blue, magenta, cyan, white (default: cyan)
  --no-color      Disable ANSI colors
  --help, -h      Show this help message

Environment:
  NO_COLOR        If set, colors are disabled (respects https://no-color.org)
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -n "${NO_COLOR:-}" ]]; then
  NO_COLOR=1
fi

if [[ "$NO_COLOR" -eq 0 ]]; then
  case "$BANNER_COLOR" in
    red)     C="\033[1;31m" ;;
    green)   C="\033[1;32m" ;;
    yellow)  C="\033[1;33m" ;;
    blue)    C="\033[1;34m" ;;
    magenta) C="\033[1;35m" ;;
    cyan)    C="\033[1;36m" ;;
    white)   C="\033[1;37m" ;;
    *)       C="\033[1;36m" ;;
  esac
  Y="\033[1;33m"; W="\033[1;37m"; G="\033[1;32m"; M="\033[1;35m"; B="\033[1;34m"
  D="\033[2m"; R="\033[0m"
else
  C=""; Y=""; W=""; G=""; M=""; B=""; D=""; R=""
fi

# --- Banner ----------------------------------------------------------------

printf "${C}"
printf '    __   __ _______ _______ _______ ___   _______ \n'
printf '    \ \ / /|  ___  |  ___  |  ___  |   | |  _____|\n'
printf '     \ V / | |   | | |   | | |   | |   | | |_____ \n'
printf '      | |  | |   | | |   | | |   | |   | |_____  |\n'
printf '      | |  | |___| | |___| | |___| |___| |_____| |\n'
printf '      |_|  |_______|_______|_______|_______|_____|\n'
printf "${R}"
printf '    %sVersion %s: %s%s\n' "$Y" "$W" "$G" "$VERSION"
printf '    %sBuild   %s: %s%s\n' "$Y" "$W" "$G" "$BUILD_DATE"
printf '    %sAuthor  %s: %s%s\n' "$Y" "$W" "$M" "$AUTHOR"
printf '    %sTagline %s: %s%s\n' "$Y" "$W" "$B" "$TAGLINE"
printf '\n'
printf '    %sQuick keys : F1=help  ESC=back  TAB=complete  CTRL+T=new session%s\n' "$D" "$R"
printf '    %sCommands   : chcolor  chfont  chzsh  pacupg  sd  pf%s\n' "$D" "$R"
printf '\n'

exit 0
