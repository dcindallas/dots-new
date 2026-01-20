#!/usr/bin/env bash
set -euo pipefail

SLEEP_HAS_UPDATES="${SLEEP_HAS_UPDATES:-10}"
SLEEP_NO_UPDATES="${SLEEP_NO_UPDATES:-1800}"

plural() { (( $1 == 1 )) && echo "Update" || echo "Updates"; }

# Temp DB (safe repo check)
CHECKUP_DB="${TMPDIR:-/tmp}/checkup-db-${USER}"
LOCKFILE="${CHECKUP_DB}/db.lck"

cleanup() {
  rm -f "$LOCKFILE" 2>/dev/null || true
}
trap cleanup INT TERM EXIT

count_repo() {
  local dbpath

  command -v fakeroot >/dev/null 2>&1 || { echo 0; return; }

  dbpath="$(pacman-conf DBPath 2>/dev/null || true)"
  [[ -n "${dbpath:-}" && -d "$dbpath" ]] || dbpath="/var/lib/pacman"

  mkdir -p "$CHECKUP_DB"
  ln -sfn "${dbpath}/local" "$CHECKUP_DB" >/dev/null 2>&1 || true

  # Refresh sync db into temp dbpath; ignore transient failures
  fakeroot -- pacman -Sy --dbpath "$CHECKUP_DB" --logfile /dev/null >/dev/null 2>&1 || true

  # Count upgrades from refreshed temp db
  pacman -Qu --dbpath "$CHECKUP_DB" 2>/dev/null | grep -v '\[.*\]' | wc -l
}

count_aur() {
  if command -v yay >/dev/null 2>&1; then
    (yay -Qua 2>/dev/null || true) | wc -l
  else
    echo 0
  fi
}

# Initial output so polybar is happy
echo "rch"

while :; do
  repo="$(count_repo)"
  if (( repo > 0 )); then
    echo "$repo $(plural "$repo")"
    sleep "$SLEEP_HAS_UPDATES"
    continue
  fi

  aur="$(count_aur)"
  if (( aur > 0 )); then
    echo "$aur $(plural "$aur")"
    sleep "$SLEEP_HAS_UPDATES"
  else
    echo " rch"
    sleep "$SLEEP_NO_UPDATES"
  fi
done
