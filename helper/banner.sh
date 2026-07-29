#!/usr/bin/env bash
#
# yourTermux - Install-time banner (sourced by install.sh)
# Author: JubairSenseiDev
#
# This file is sourced by the main install.sh and exposes the `banner` function.
# For standalone banner scripts in multiple languages, see the /banner directory.
#

VERSION="1.0.0"
BUILD_DATE="$(date +'%d %B %Y')"
AUTHOR="JubairSenseiDev"
TAGLINE="Termux setup for new users"

# ANSI color codes (graceful fallback if not supported)
if [[ -t 1 ]]; then
  COLOR_CYAN="\033[1;36m"
  COLOR_GREEN="\033[1;32m"
  COLOR_YELLOW="\033[1;33m"
  COLOR_MAGENTA="\033[1;35m"
  COLOR_BLUE="\033[1;34m"
  COLOR_RED="\033[1;31m"
  COLOR_WHITE="\033[1;37m"
  COLOR_DIM="\033[2m"
  COLOR_RESET="\033[0m"
else
  COLOR_CYAN=""; COLOR_GREEN=""; COLOR_YELLOW=""; COLOR_MAGENTA=""
  COLOR_BLUE=""; COLOR_RED=""; COLOR_WHITE=""; COLOR_DIM=""; COLOR_RESET=""
fi

function banner() {

  echo -e "${COLOR_CYAN}"
  echo -e "    __   __ _______ _______ _______ ___   _______ "
  echo -e "    \ \ / /|  ___  |  ___  |  ___  |   | |  _____|"
  echo -e "     \ V / | |   | | |   | | |   | |   | | |_____ "
  echo -e "      | |  | |   | | |   | | |   | |   | |_____  |"
  echo -e "      | |  | |___| | |___| | |___| |___| |_____| |"
  echo -e "      |_|  |_______|_______|_______|_______|_____|"
  echo -e "${COLOR_RESET}"
  echo -e "    ${COLOR_YELLOW}Version ${COLOR_WHITE}: ${COLOR_GREEN}${VERSION}"
  echo -e "    ${COLOR_YELLOW}Build   ${COLOR_WHITE}: ${COLOR_GREEN}${BUILD_DATE}"
  echo -e "    ${COLOR_YELLOW}Author  ${COLOR_WHITE}: ${COLOR_MAGENTA}${AUTHOR}"
  echo -e "    ${COLOR_YELLOW}Tagline ${COLOR_WHITE}: ${COLOR_BLUE}${TAGLINE}"
  echo -e ""
  echo -e "    ${COLOR_DIM}Quick keys : F1=help  ESC=back  TAB=complete  CTRL+T=new session"
  echo -e "    ${COLOR_DIM}Commands   : chcolor  chfont  chzsh  pacupg  sd  pf${COLOR_RESET}"
  echo -e ""

}
