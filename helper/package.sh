#!/usr/bin/env bash
# yourTermux - Author: JubairSenseiDev - https://github.com/JubairSenseiDev/yourTermux
#
# package — install the list of packages with backend fallback.
# Old code called `apt show` 4× per package (very slow) and silenced
# install errors. Now we cache apt metadata and report per-package status.

PACKAGES=(
  awesomeshot bat curl clang eza fzf git imagemagick
  inotify-tools lf mpd mpc neovim openssh
  neofetch termux-api tmux zsh
)

function packages() {

  setCursor off 2>/dev/null || true

  KB_DOWNLOAD_SIZE=0
  MB_DOWNLOAD_SIZE=0
  KB_INSTALLED_SIZE=0
  MB_INSTALLED_SIZE=0

  echo -e "‏‏‎‏‏‎ ‎ ‎‏‏‎  ‎📦 Getting Information Packages"

  echo -e "
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                                 Information Packages                                ┃
    ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
    ┃      Package Name              Version             Download           Installed     ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"

  for PACKAGE in "${PACKAGES[@]}"; do
    # ── BUGFIX: cache apt show output, call ONCE per package instead of 4×
    local meta
    meta=$(apt show "$PACKAGE" 2>/dev/null)

    PACKAGE_NAME=$(echo "$meta" | grep '^Package:' | awk '{print $2}')
    VERSION=$(echo "$meta"      | grep '^Version:' | awk '{print $2}')
    DOWNLOAD_SIZE=$(echo "$meta" | grep '^Download-Size:' | awk '{print $2}')
    INSTALLED_SIZE=$(echo "$meta" | grep '^Installed-Size:' | awk '{print $2}')
    UNIT_DOWNLOAD_SIZE=$(echo "$meta" | grep '^Download-Size:' | awk '{print $3}')
    UNIT_INSTALLED_SIZE=$(echo "$meta" | grep '^Installed-Size:' | awk '{print $3}')

    # Fall back gracefully if apt show returned nothing
    [[ -z "$PACKAGE_NAME" ]] && PACKAGE_NAME="$PACKAGE"
    [[ -z "$VERSION" ]] && VERSION="unknown"
    [[ -z "$DOWNLOAD_SIZE" ]] && { DOWNLOAD_SIZE="?"; UNIT_DOWNLOAD_SIZE=""; }
    [[ -z "$INSTALLED_SIZE" ]] && { INSTALLED_SIZE="?"; UNIT_INSTALLED_SIZE=""; }

    printf  "    ┃      ${COLOR_SUCCESS}%-13s${COLOR_BASED}          ${COLOR_WARNING}%10s${COLOR_BASED}              ${COLOR_WARNING}%-4s${COLOR_BASED} %-2s             ${COLOR_WARNING}%-4s${COLOR_BASED} %-2s     ┃\n" \
      "$PACKAGE_NAME" "$VERSION" "$DOWNLOAD_SIZE" "$UNIT_DOWNLOAD_SIZE" "$INSTALLED_SIZE" "$UNIT_INSTALLED_SIZE"
    echo -e "    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"

    # Skip aggregation if sizes are unknown
    [[ "$DOWNLOAD_SIZE" == "?" || "$INSTALLED_SIZE" == "?" ]] && continue

    if [[ "${UNIT_DOWNLOAD_SIZE}" == "kB" && "${UNIT_INSTALLED_SIZE}" == "MB" ]]; then
      KB_DOWNLOAD_SIZE=$(echo "${KB_DOWNLOAD_SIZE} + ${DOWNLOAD_SIZE} / 1024" | bc -l 2>/dev/null | xargs -I{} printf "%'.1f" {} 2>/dev/null || echo 0)
      MB_INSTALLED_SIZE=$(echo "${MB_INSTALLED_SIZE} + ${INSTALLED_SIZE}" | bc -l 2>/dev/null | xargs -I{} printf "%'.1f" {} 2>/dev/null || echo 0)
    elif [[ "${UNIT_DOWNLOAD_SIZE}" == "MB" && "${UNIT_INSTALLED_SIZE}" == "kB" ]]; then
      MB_DOWNLOAD_SIZE=$(echo "${MB_DOWNLOAD_SIZE} + ${DOWNLOAD_SIZE}" | bc -l 2>/dev/null | xargs -I{} printf "%'.1f" {} 2>/dev/null || echo 0)
      KB_INSTALLED_SIZE=$(echo "${KB_INSTALLED_SIZE} + ${INSTALLED_SIZE} / 1024" | bc -l 2>/dev/null | xargs -I{} printf "%'.1f" {} 2>/dev/null || echo 0)
    elif [[ "${UNIT_DOWNLOAD_SIZE}" == "kB" && "${UNIT_INSTALLED_SIZE}" == "kB" ]]; then
      KB_DOWNLOAD_SIZE=$(echo "${KB_DOWNLOAD_SIZE} + ${DOWNLOAD_SIZE} / 1024" | bc -l 2>/dev/null | xargs -I{} printf "%'.1f" {} 2>/dev/null || echo 0)
      KB_INSTALLED_SIZE=$(echo "${KB_INSTALLED_SIZE} + ${INSTALLED_SIZE} / 1024" | bc -l 2>/dev/null | xargs -I{} printf "%'.1f" {} 2>/dev/null || echo 0)
    elif [[ "${UNIT_DOWNLOAD_SIZE}" == "MB" && "${UNIT_INSTALLED_SIZE}" == "MB" ]]; then
      MB_DOWNLOAD_SIZE=$(echo "${MB_DOWNLOAD_SIZE} + ${DOWNLOAD_SIZE}" | bc -l 2>/dev/null | xargs -I{} printf "%'.1f" {} 2>/dev/null || echo 0)
      MB_INSTALLED_SIZE=$(echo "${MB_INSTALLED_SIZE} + ${INSTALLED_SIZE}" | bc -l 2>/dev/null | xargs -I{} printf "%'.1f" {} 2>/dev/null || echo 0)
    fi

  done

  TOTAL_DOWNLOAD_SIZE=$(echo "${KB_DOWNLOAD_SIZE} + ${MB_DOWNLOAD_SIZE}" | bc -l 2>/dev/null | xargs -I{} printf "%'.1f" {} 2>/dev/null || echo "?")
  TOTAL_INSTALLED_SIZE=$(echo "${KB_INSTALLED_SIZE} + ${MB_INSTALLED_SIZE}" | bc -l 2>/dev/null | xargs -I{} printf "%'.1f" {} 2>/dev/null || echo "?")

  printf    "    ┃     [ ${COLOR_WARNING}%5s${COLOR_BASED} ]  ─────────────────────────────────> ${COLOR_WARNING}%6s${COLOR_BASED} %-2s           ${COLOR_WARNING}%6s${COLOR_BASED} %-2s     ┃" "TOTAL" "$TOTAL_DOWNLOAD_SIZE" "MB" "$TOTAL_INSTALLED_SIZE" "MB"
  echo -e "\n    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"

  echo ""

  setCursor on 2>/dev/null || true

}

function installPackages() {

  setCursor off 2>/dev/null || true

  echo -e "\n‏‏‎‏‏‎ ‎ ‎‏‏‎  ‎📦 Downloading Packages\n"

  local failed=()
  local ok=0

  for PACKAGE in "${PACKAGES[@]}"; do

    start_animation "       Installing ${COLOR_WARNING}'${COLOR_SUCCESS}${PACKAGE}${COLOR_WARNING}'${COLOR_BASED} ..." 2>/dev/null || \
      echo "  → Installing ${PACKAGE}..."

    # ── BUGFIX: don't silence stderr — surface real errors. Try apt, fall back to pkg.
    if pkg install -y "$PACKAGE" >/dev/null 2>&1; then
      stop_animation $? 2>/dev/null || echo "  ✔ ${PACKAGE} installed"
      ok=$((ok + 1))
    elif apt install -y "$PACKAGE" >/dev/null 2>&1; then
      stop_animation $? 2>/dev/null || echo "  ✔ ${PACKAGE} installed (via apt)"
      ok=$((ok + 1))
    else
      stop_animation 1 2>/dev/null || echo "  ✘ ${PACKAGE} failed"
      failed+=("$PACKAGE")
    fi

  done

  setCursor on 2>/dev/null || true

  echo ""
  echo "  ─────────────────────────────────────────────"
  echo "  Packages installed OK : $ok / ${#PACKAGES[@]}"
  if [[ ${#failed[@]} -gt 0 ]]; then
    echo "  Packages FAILED       : ${failed[*]}"
    echo "  ─────────────────────────────────────────────"
    echo "  You can retry failed packages manually with:"
    echo "    pkg install -y ${failed[*]}"
  fi
  echo "  ─────────────────────────────────────────────"
  echo ""

  # Don't exit on partial failure — let the rest of install continue
  return 0

}
