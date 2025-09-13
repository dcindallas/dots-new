#!/usr/bin/env bash

ROFI_CMD=(rofi -dmenu -i -p "Bluetooth" -theme ~/.config/rofi/dc-theme.rasi)

power_state() {
  bluetoothctl show | awk '/Powered:/ {print $2}'
}
toggle_power() {
  [[ "$(power_state)" == "yes" ]] && bluetoothctl power off >/dev/null || bluetoothctl power on >/dev/null
}
scan_on()  { bluetoothctl scan on  >/dev/null & disown; }
scan_off() { bluetoothctl scan off >/dev/null; }

menu() {
  local items
  local pwr="$(power_state)"
  if [[ "$pwr" != "yes" ]]; then
    items="  Power On"
  else
    items="  Power Off
  Scan (10s)
— — — — — — —"
    # List paired devices with connection status
    while read -r line; do
      mac=$(awk '{print $2}' <<<"$line")
      name=$(cut -d' ' -f3- <<<"$line")
      if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
        items+="
  $name  [$mac]  (disconnect)"
      else
        items+="
  $name  [$mac]  (connect)"
      fi
    done < <(bluetoothctl paired-devices | sed 's/^Device //')
  fi
  echo -e "$items"
}

action() {
  local choice="$1"
  case "$choice" in
    "  Power On")  bluetoothctl power on >/dev/null ;;
    "  Power Off") bluetoothctl power off >/dev/null ;;
    "  Scan (10s)") scan_on; sleep 10; scan_off ;;
    *)
      # Parse "…  name  [MAC]  (connect|disconnect)"
      mac=$(sed -n 's/.*\[\([A-F0-9:]\+\)\].*/\1/p' <<<"$choice")
      [[ -z "$mac" ]] && exit 0
      if grep -q "(connect)" <<<"$choice"; then
        bluetoothctl connect "$mac" >/dev/null
      else
        bluetoothctl disconnect "$mac" >/dev/null
      fi
    ;;
  esac
}

# Ensure bluetoothctl exists
command -v bluetoothctl >/dev/null || { notify-send "Bluetooth" "bluez-utils not installed"; exit 1; }

# Show menu; if powered off, only one action appears
selection=$(menu | "${ROFI_CMD[@]}")
[[ -z "$selection" ]] && exit 0
action "$selection"
