#!/usr/bin/env bash
# Wi-Fi status for Polybar — strict Base16 Xresources (no fallbacks)

ICON_ON=""        # radio on, not connected
ICON_OFF=""       # radio off
ICON_CONN=""      # connected


# Get EXACT Base16 key from Xresources: returns empty if missing
xr_base16() {
  local key="$1"
  xrdb -query 2>/dev/null | awk -v k="$key" '
    BEGIN{IGNORECASE=1}
    $1=="*."k":" { print $2; exit }'
}

COL_OFF="$(xr_base16 base03)"  # grey for radio off
COL_ON="$(xr_base16 base0A)"   # yellow for on (not connected)
COL_CONN="$(xr_base16 base0B)" # green for connected

paint() {
  local hex="$1" txt="$2"
  if [[ "$hex" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
    printf '%%{F%s}%s%%{F-}\n' "$hex" "$txt"
  else
    printf '%s\n' "$txt"
  fi
}

# ---- status via nmcli ----
wifi_radio=$(nmcli -t -f WIFI general 2>/dev/null | tr '[:upper:]' '[:lower:]')

if [[ "$wifi_radio" != "enabled" ]]; then
  paint "$COL_OFF" "$ICON_OFF"
  exit 0
fi

if nmcli -t -f DEVICE,TYPE,STATE device 2>/dev/null | awk -F: '$2=="wifi" && $3=="connected"' | grep -q .; then
  paint "$COL_CONN" "$ICON_CONN"
else
  paint "$COL_ON" "$ICON_ON"
fi
