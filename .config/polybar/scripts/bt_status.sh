#!/usr/bin/env bash
# Polybar Bluetooth status — colors from Xresources

# --- Icons (Nerd Font) ---
ICON_OFF="󰂲"     # off
ICON_ON="󰂯"      # on, not connected
ICON_CONN="󰂱"    # connected

# --- Xresources helpers ---
have_xrdb() { command -v xrdb >/dev/null 2>&1 && xrdb -query >/dev/null 2>&1; }

get_xrdb() {
  # get_xrdb color6 | foreground | background
  local key="$1"
  xrdb -query 2>/dev/null | awk -v k="$key" '
    BEGIN{ IGNORECASE=1 }
    {
      s=tolower($1)
      # match "*.key:" or "*key:" or "app*.key:" or "app*key:"
      if (s ~ "\\*\\." k ":" || s ~ "\\*" k ":") { print $2; exit }
    }'
}

if have_xrdb; then
  XR_COLOR6=$(get_xrdb color6)   # cyan (often the accent)
  XR_COLOR4=$(get_xrdb color4)   # blue
  XR_COLOR2=$(get_xrdb color2)   # green
  XR_COLOR8=$(get_xrdb color8)   # bright black (muted)
else
  XR_COLOR6= XR_COLOR4= XR_COLOR2= XR_COLOR8=
fi

# Allow env overrides; then Xresources; then hard defaults
C_MUTED="${BT_COLOR_MUTED:-${XR_COLOR8:-#6272a4}}"
C_ACTIVE="${BT_COLOR_ACTIVE:-${XR_COLOR6:-${XR_COLOR4:-#8be9fd}}}"
C_CONN="${BT_COLOR_CONN:-${XR_COLOR2:-#50fa7b}}"

# emit with Polybar color tags only if hex looks valid
paint() {
  local hex="$1" text="$2"
  if [[ "$hex" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
    printf "%%{F%s}%s%%{F-}" "$hex" "$text"
  else
    printf "%s" "$text"
  fi
}

# --- Bluetooth status ---
power=$(bluetoothctl show 2>/dev/null | awk '/Powered:/ {print $2}')

if [[ "$power" != "yes" ]]; then
  paint "$C_MUTED" "$ICON_OFF"
  exit 0
fi

if bluetoothctl devices Connected 2>/dev/null | grep -q '^Device'; then
  paint "$C_CONN" "$ICON_CONN"
else
  paint "$C_ACTIVE" "$ICON_ON"
fi
