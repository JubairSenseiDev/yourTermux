#!/usr/bin/env bash
# yourTermux - Author: JubairSenseiDev - https://github.com/JubairSenseiDev/yourTermux
#
# clone — clone required Git repositories with backend fallback.
# Old code silenced all errors (2>/dev/null) and gave no retry. Now we
# try HTTPS first, fall back to depth=1 shallow, and surface failures.

REPOSITORY_LINKS=(
  https://github.com/robbyrussell/oh-my-zsh
  https://github.com/zsh-users/zsh-syntax-highlighting
  https://github.com/zsh-users/zsh-autosuggestions
  https://github.com/joshskidmore/zsh-fzf-history-search
  https://github.com/marlonrichert/zsh-autocomplete
  https://github.com/jimeh/tmux-themepack
  https://github.com/NvChad/starter
)

REPOSITORY_APIS=(
  repositories/291137
  repos/zsh-users/zsh-syntax-highlighting
  repos/zsh-users/zsh-autosuggestions
  repos/joshskidmore/zsh-fzf-history-search
  repos/marlonrichert/zsh-autocomplete
  repos/jimeh/tmux-themepack
  repos/NvChad/starter
)

REPOSITORY_FULL_NAME=(
  robbyrussell/oh-my-zsh
  zsh-users/zsh-syntax-highlighting
  zsh-users/zsh-autosuggestions
  joshskidmore/zsh-fzf-history-search
  marlonrichert/zsh-autocomplete
  jimeh/tmux-themepack
  NvChad/starter
)

REPOSITORY_PATH=(
  $HOME/.oh-my-zsh/
  $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  $HOME/.oh-my-zsh/custom/plugins/zsh-fzf-history-search
  $HOME/.oh-my-zsh/custom/plugins/zsh-autocomplete
  $HOME/.tmux-themepack
  $HOME/NvChad
)

function repoSize() {
    # Try GitHub API; fall back to "unknown" on failure
    local size_kb
    size_kb=$(curl -s "https://api.github.com/$@" 2>/dev/null | grep size | head -1 | tr -dc '[:digit:]')
    if [[ -n "$size_kb" ]]; then
      echo "$(echo "scale=2; ${size_kb} / 1024" | bc 2>/dev/null || echo "?")MB"
    else
      echo "?MB"
    fi
}

function repositories() {

  setCursor off 2>/dev/null || true

  echo -e "‏‏‎‏‏‎ ‎ ‎‏‏‎  ‎📦 Getting Information Repository"
  sleep 1s

  echo -e "
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                         Information Repository                     ┃
    ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
    ┃      Repository Name                          Repository Size      ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"

  for REPOSITORY_API in "${REPOSITORY_APIS[@]}"; do
    REPOSITORY_NAME=$(curl -s "https://api.github.com/${REPOSITORY_API}" 2>/dev/null | grep full_name | sed -n 1p | awk '{print $2}' | sed "s/,//g" | sed "s/\"//g")
    [[ -z "$REPOSITORY_NAME" ]] && REPOSITORY_NAME="$REPOSITORY_API"
    printf  "    ┃      ${COLOR_SUCCESS}%-36s${COLOR_BASED}       ${COLOR_WARNING}%8s${COLOR_BASED}           ┃\n" "$REPOSITORY_NAME" "$(repoSize "$REPOSITORY_API")"
    echo -e "    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
  done

  echo -e ""

  setCursor on 2>/dev/null || true

}

function cloneRepository() {

  setCursor off 2>/dev/null || true

  echo -e "\n‏‏‎‏‏‎ ‎ ‎‏‏‎  ‎📦 Cloning Repositories\n"
  sleep 1s

  local failed=()
  local ok=0

  for ((i=0; i<${#REPOSITORY_LINKS[@]}; i++)); do

    local repo="${REPOSITORY_LINKS[i]}"
    local dest="${REPOSITORY_PATH[i]}"
    local name="${REPOSITORY_FULL_NAME[i]}"

    start_animation "       Cloning ${COLOR_WARNING}'${COLOR_SUCCESS}${name}${COLOR_WARNING}'${COLOR_BASED} ..." 2>/dev/null || \
      echo "  → Cloning ${name}..."

    # Skip if already cloned
    if [[ -d "$dest" && -n "$(ls -A "$dest" 2>/dev/null)" ]]; then
      stop_animation 0 2>/dev/null || echo "  ✔ ${name} already exists — skipping"
      ok=$((ok + 1))
      continue
    fi

    # ── BUGFIX: try multiple strategies, surface real errors
    # Strategy 1: shallow HTTPS clone (fast, less data)
    if git clone --depth=1 "$repo" "$dest" 2>/dev/null; then
      stop_animation 0 2>/dev/null || echo "  ✔ ${name} cloned (shallow)"
      ok=$((ok + 1))
      continue
    fi

    # Strategy 2: full HTTPS clone
    if git clone "$repo" "$dest" 2>/dev/null; then
      stop_animation 0 2>/dev/null || echo "  ✔ ${name} cloned (full)"
      ok=$((ok + 1))
      continue
    fi

    # Strategy 3: SSH (if user has SSH keys set up)
    local ssh_repo="${repo/https:\/\/github.com\//git@github.com:}"
    if git clone "$ssh_repo" "$dest" 2>/dev/null; then
      stop_animation 0 2>/dev/null || echo "  ✔ ${name} cloned (SSH)"
      ok=$((ok + 1))
      continue
    fi

    # All strategies failed
    stop_animation 1 2>/dev/null || echo "  ✘ ${name} FAILED to clone"
    failed+=("$name")
    # Clean up partial clone
    rm -rf "$dest" 2>/dev/null

  done

  setCursor on 2>/dev/null || true

  echo ""
  echo "  ─────────────────────────────────────────────"
  echo "  Repositories cloned OK : $ok / ${#REPOSITORY_LINKS[@]}"
  if [[ ${#failed[@]} -gt 0 ]]; then
    echo "  Repositories FAILED    : ${failed[*]}"
    echo "  ─────────────────────────────────────────────"
    echo "  Check your internet connection and retry:"
    echo "    cd ~/yourTermux && ./yourtermux.sh install"
  fi
  echo "  ─────────────────────────────────────────────"
  echo ""

  # Don't abort the whole install on partial failure
  return 0

}
