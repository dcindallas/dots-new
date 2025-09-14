k#!/usr/bin/env bash
# i3/Xorg • Polybar KDE Connect (qdbus way), Rofi themed via kdeconnect.rasi

set -euo pipefail

# ---------- Config (override via env or polybar env-) ----------
LOCATION="${LOCATION:-0}"
YOFFSET="${YOFFSET:-0}"
XOFFSET="${XOFFSET:-0}"
WIDTH="${WIDTH:-12}"
WIDTH_WIDE="${WIDTH_WIDE:-24}"
THEME="${THEME:-$HOME/.config/rofi/kdeconnect.rasi}"

ICON_SMARTPHONE=''
ICON_TABLET=''
SEPARATOR='|'

# ---------- Colors from Xresources (Base16 Twilight) ----------
xrdbq() { xrdb -query 2>/dev/null | awk -v k="$1" '$1==k":"{print $2}'; }
xcol(){ local k="$1" def="$2" v; v="$(xrdbq "$k")"; [ -n "$v" ] && { printf "%s" "$v"; return; }; printf "#%s" "$def"; }
BASE05="$(xcol base05 fefef9)"; BASE08="$(xcol base08 cf6a4c)"; BASE0A="$(xcol base0A f9ee98)"
BASE0B="$(xcol base0B 8f9d6a)"; BASE02="$(xcol base02 464b50)"; BASE07="$(xcol base07 ffffff)"
# Polybar label colors
COLOR_DISCONNECTED="${COLOR_DISCONNECTED:-$BASE02}"  # dim
COLOR_NEWDEVICE="${COLOR_NEWDEVICE:-$BASE0A}"        # yellow
COLOR_BATTERY_90="${COLOR_BATTERY_90:-$BASE07}"
COLOR_BATTERY_80="${COLOR_BATTERY_80:-$BASE05}"
COLOR_BATTERY_70="${COLOR_BATTERY_70:-$BASE05}"
COLOR_BATTERY_60="${COLOR_BATTERY_60:-$BASE05}"
COLOR_BATTERY_50="${COLOR_BATTERY_50:-$BASE05}"
COLOR_BATTERY_LOW="${COLOR_BATTERY_LOW:-$BASE08}"    # red

# ---------- Helpers ----------
have(){ command -v "$1" >/dev/null 2>&1; }
rofi_dmenu() {
  rofi -sep '|' -dmenu -i -p "$1" \
       -location "$LOCATION" -yoffset "$YOFFSET" -xoffset "$XOFFSET" \
       -theme "$THEME" -width "$2" -hide-scrollbar -line-padding "$3" -padding "$4" -lines "$5"
}

get_icon () {
  local level="$1" type="${2:-phone}" icon
  [ "$type" = "tablet" ] && icon="$ICON_TABLET" || icon="$ICON_SMARTPHONE"
  case "$level" in
    -1) printf "%%{F%s}%s%%{F-}" "$COLOR_DISCONNECTED" "$icon" ;;
    -2) printf "%%{F%s}%s%%{F-}" "$COLOR_NEWDEVICE"   "$icon" ;;
    5*) printf "%%{F%s}%s%%{F-}" "$COLOR_BATTERY_50"   "$icon" ;;
    6*) printf "%%{F%s}%s%%{F-}" "$COLOR_BATTERY_60"   "$icon" ;;
    7*) printf "%%{F%s}%s%%{F-}" "$COLOR_BATTERY_70"   "$icon" ;;
    8*) printf "%%{F%s}%s%%{F-}" "$COLOR_BATTERY_80"   "$icon" ;;
    9*|100) printf "%%{F%s}%s%%{F-}" "$COLOR_BATTERY_90" "$icon" ;;
    *)  printf "%%{F%s}%s%%{F-}" "$COLOR_BATTERY_LOW"  "$icon" ;;
  esac
}

# ---------- DBus paths ----------
BUS="org.kde.kdeconnect"
ROOT="/modules/kdeconnect"

# ---------- Actions ----------
show_menu () {
  local dev_name="$1" dev_id="$2" dev_batt="${3:---}"
  local choice
  choice="$(echo "Battery: ${dev_batt}%|Ping|Find Device|Send File|Browse Files|Unpair" \
           | rofi_dmenu "$dev_name" "$WIDTH" 4 20 6)" || exit 0
  case "$choice" in
    *Ping) qdbus "$BUS" "$ROOT/devices/$dev_id/ping" org.kde.kdeconnect.device.ping.sendPing ;;
    *'Find Device') qdbus "$BUS" "$ROOT/devices/$dev_id/findmyphone" org.kde.kdeconnect.device.findmyphone.ring ;;
    *'Send File')
        # zenity fits your other scripts; swap to path prompt if you prefer pure rofi
        sel="$(zenity --file-selection 2>/dev/null || true)"; [ -n "$sel" ] || exit 0
        qdbus "$BUS" "$ROOT/devices/$dev_id/share" org.kde.kdeconnect.device.share.shareUrl "file://$sel"
        ;;
    *'Browse Files')
        if [ "$(qdbus --literal "$BUS" "$ROOT/devices/$dev_id/sftp" org.kde.kdeconnect.device.sftp.isMounted)" = "false" ]; then
          qdbus "$BUS" "$ROOT/devices/$dev_id/sftp" org.kde.kdeconnect.device.sftp.mount
        fi
        qdbus "$BUS" "$ROOT/devices/$dev_id/sftp" org.kde.kdeconnect.device.sftp.startBrowsing
        ;;
    *Unpair) qdbus "$BUS" "$ROOT/devices/$dev_id" org.kde.kdeconnect.device.unpair ;;
  esac
}

show_pair_menu () {
  local dev_name="$1" dev_id="$2"
  local choice
  choice="$(echo "Accept|Reject" | rofi_dmenu "$dev_name has sent a pairing request" "$WIDTH_WIDE" 4 20 2)" || exit 0
  case "$choice" in
    Accept) qdbus "$BUS" "$ROOT/devices/$dev_id" org.kde.kdeconnect.device.acceptPairing ;;
    *)      qdbus "$BUS" "$ROOT/devices/$dev_id" org.kde.kdeconnect.device.rejectPairing ;;
  esac
}

show_quick_pair () {
  local dev_name="$1" dev_id="$2"
  local choice
  choice="$(echo "Pair Device" | rofi_dmenu "$dev_name" "$WIDTH" 1 20 1)" || exit 0
  [ "$choice" = "Pair Device" ] && qdbus "$BUS" "$ROOT/devices/$dev_id" org.kde.kdeconnect.device.requestPair
}

# ---------- Polybar output (clickable areas) ----------
show_devices (){
  local out="" devices ids item id name type reachable trusted batt icon
  IFS=$',' read -r -a ids <<<"$(qdbus --literal "$BUS" "$ROOT" org.kde.kdeconnect.daemon.devices)"
  for item in "${ids[@]}"; do
    id="$(awk -F'["|"]' '{print $2}' <<<"$item")"
    [ -z "$id" ] && continue
    name="$(qdbus "$BUS" "$ROOT/devices/$id" org.kde.kdeconnect.device.name)"
    type="$(qdbus "$BUS" "$ROOT/devices/$id" org.kde.kdeconnect.device.type)"
    reachable="$(qdbus "$BUS" "$ROOT/devices/$id" org.kde.kdeconnect.device.isReachable)"
    trusted="$(qdbus "$BUS" "$ROOT/devices/$id" org.kde.kdeconnect.device.isTrusted)"

    if [ "$reachable" = "true" ] && [ "$trusted" = "true" ]; then
      batt="$(qdbus "$BUS" "$ROOT/devices/$id/battery" org.kde.kdeconnect.device.battery.charge 2>/dev/null || echo "")"
      icon="$(get_icon "${batt:--1}" "$type")"
      out+="%{A1:$0 -m -n '$name' -i $id -b ${batt:-0}:}$icon%{A}$SEPARATOR"
    elif [ "$reachable" = "false" ] && [ "$trusted" = "true" ]; then
      out+="$(get_icon -1 "$type")$SEPARATOR"
    else
      haspair="$(qdbus "$BUS" "$ROOT/devices/$id" org.kde.kdeconnect.device.hasPairingRequests)"
      [ "$haspair" = "true" ] && show_pair_menu "$name" "$id"
      icon="$(get_icon -2 "$type")"
      out+="%{A1:$0 -p -n '$name' -i $id:}$icon%{A}$SEPARATOR"
    fi
  done
  [ -n "$out" ] && printf "%s" "${out::-1}" || printf ""
}

# ---------- CLI ----------
unset DEV_ID DEV_NAME DEV_BATTERY
while getopts 'din:b:mp' c; do
  case $c in
    d) show_devices; exit 0 ;;
    i) DEV_ID=$OPTARG ;;
    n) DEV_NAME=$OPTARG ;;
    b) DEV_BATTERY=$OPTARG ;;
    m) show_menu "$DEV_NAME" "$DEV_ID" "${DEV_BATTERY:-}"; exit 0 ;;
    p) show_quick_pair "$DEV_NAME" "$DEV_ID"; exit 0 ;;
  esac
done

# Default: print devices for Polybar
show_devices

