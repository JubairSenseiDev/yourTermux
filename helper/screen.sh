#!/usr/bin/env bash
# yourTermux - Author: JubairSenseiDev - https://github.com/JubairSenseiDev/yourTermux
#
# screenSize — runs the given function if the terminal is big enough,
# OR if YT_MIN_SCREEN=1 is set (skips the gate entirely).
# Falls back to running the function anyway with a warning if the
# screen is too small and YT_MIN_SCREEN is not set, but only after
# giving the user a chance to zoom out.

function screenSize() {

  local REQUIRE_COLS=101
  local REQUIRE_ROWS=39

  # Allow override via env var
  if [[ -n "${YT_MIN_SCREEN:-}" ]]; then
    "${1}"
    return $?
  fi

  local CURRENT_COLS="${COLUMNS:-0}"
  local CURRENT_ROWS="${LINES:-0}"

  # Try to detect via tput if COLUMNS/LINES not set
  if [[ -z "$COLUMNS" || -z "$LINES" ]] && command -v tput >/dev/null 2>&1; then
    CURRENT_COLS=$(tput cols 2>/dev/null || echo 0)
    CURRENT_ROWS=$(tput lines 2>/dev/null || echo 0)
  fi

  if [[ "$CURRENT_COLS" -gt 0 && "$CURRENT_ROWS" -gt 0 ]]; then

    if (( CURRENT_COLS >= REQUIRE_COLS && CURRENT_ROWS >= REQUIRE_ROWS )); then
      "${1}"
      return $?
    fi

    # Too small — warn but still run, instead of hard-blocking the user.
    # Old behavior was to silently abort the whole install. Now we continue
    # with a warning so the user can still complete setup on mobile screens.
    if [[ -n "${COLOR_WARNING:-}" ]]; then
      stat "INFO" "Warning" "Screen size: ${CURRENT_COLS}x${CURRENT_ROWS} (recommended ${REQUIRE_COLS}x${REQUIRE_ROWS}). Some tables may wrap — continuing anyway."
    else
      echo "  ⚠ Screen size: ${CURRENT_COLS}x${CURRENT_ROWS} (recommended ${REQUIRE_COLS}x${REQUIRE_ROWS}). Some tables may wrap — continuing anyway."
    fi
    "${1}"
    return $?

  else

    # Can't detect — just run, don't block.
    if [[ -n "${COLOR_WARNING:-}" ]]; then
      stat "INFO" "Warning" "Cannot detect screen size — continuing anyway."
    else
      echo "  ⚠ Cannot detect screen size — continuing anyway."
    fi
    "${1}"
    return $?

  fi

}
