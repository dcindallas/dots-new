#!/usr/bin/env bash
# Wi-Fi status for Polybar — Base16 from Xresources (auto-normalizes hex)

set -u

ICON_ON=""   # radio on, not connected
ICON_OFF=""  # radio off
ICON_CONN="" # connected

# Read Base16 key from Xresources (case-insensitive). Returns raw value or empty.
xr_base16() {
  local key="$1"
  xrdb -query 2>/dev/null | awk -v k="$key" '
    BEGIN{IGNORECASE=1}
    $1=="*."k":" { print $2; exit }'
}

# Normalize to "#RRGGBB" if possible; otherwise empty.
norm_hex() {
  local h="${1:-}"
  h="${h//\"/}"   # strip quotes if present
  h="${h#\#}"     # strip leading '#'
  if [[ "$h" =~ ^[0-9A-Fa-f]{6}$ ]]; then
    printf '#%s' "$h"
  else
    printf ''
  fi
}

# Paint text with polybar color tags if hex is valid.
paint() {
  local hex="${1:-}" txt="${2:-}"
  if [[ "$hex" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
    printf '%%{F%s}%s%%{F-}\n' "$hex" "$txt"
  else
    printf '%s\n' "$txt"
  fi
}

# Base16 mappings (typical Base16 meaning)
# base03: comment/grey
# base0A: yellow
# base0B: green
COL_OFF="$(norm_hex "$(xr_base16 base03)")"
COL_ON="$(norm_hex "$(xr_base16 base0A)")"
COL_CONN="$(norm_hex "$(xr_base16 base0B)")"

# ---- status via nmcli ----
wifi_radio="$(nmcli -t -f WIFI general 2>/dev/null | tr '[:upper:]' '[:lower:]')"

# If nmcli failed, just show "on" icon uncolored
if [[ -z "${wifi_radio:-}" ]]; then
  printf '%s\n' "$ICON_ON"
  exit 0
fi

if [[ "$wifi_radio" != "enabled" ]]; then
  paint "$COL_OFF" "$ICON_OFF"
  exit 0
fi

if nmcli -t -f DEVICE,TYPE,STATE device 2>/dev/null \
  | awk -F: '$2=="wifi" && $3=="connected"' \
  | grep -q .; then
  paint "$COL_CONN" "$ICON_CONN"
else
  paint "$COL_ON" "$ICON_ON"
fi
