#!/bin/bash
set -euo pipefail

# --- CONFIG ---
API_KEY="d9b47f3f48563b443d5c4504f09b9071"
CITY_ID="4710178"
UNITS="imperial"  # "metric" for °C
ROFI_THEME="$HOME/.config/rofi/weather.rasi"

# --- ICON MAP (emoji, one per condition) ---
icon_for_main() {
  case "$1" in
    Clear)          printf "☀️" ;;
    Clouds)         printf "☁️" ;;
    Rain|Drizzle)   printf "🌧️" ;;
    Thunderstorm)   printf "⛈️" ;;
    Snow)           printf "🌨️" ;;
    Mist|Fog|Haze|Smoke|Dust|Sand|Ash) printf "🌫️" ;;
    Squall)         printf "🌬️" ;;
    Tornado)        printf "🌪️" ;;
    *)              printf "❓" ;;
  esac
}

# --- FETCH ---
current="$(curl -sf "http://api.openweathermap.org/data/2.5/weather?id=$CITY_ID&units=$UNITS&appid=$API_KEY" || true)"
forecast="$(curl -sf "http://api.openweathermap.org/data/2.5/forecast?id=$CITY_ID&units=$UNITS&appid=$API_KEY" || true)"

if [[ -z "$current" ]]; then
  echo "Weather unavailable" | rofi -dmenu -p "Weather" -lines 1 -theme "$ROFI_THEME" >/dev/null
  exit 0
fi

# --- CURRENT ---
name=$(echo "$current" | jq -r .name)
c_main=$(echo "$current" | jq -r .weather[0].main)
c_desc=$(echo "$current" | jq -r .weather[0].description | awk '{print tolower($0)}')
c_icon=$(icon_for_main "$c_main")
c_temp=$(printf "%.0f" "$(echo "$current" | jq -r .main.temp)")
c_feels=$(printf "%.0f" "$(echo "$current" | jq -r .main.feels_like)")
c_hum=$(echo "$current" | jq -r .main.humidity)
c_wind=$(printf "%.0f" "$(echo "$current" | jq -r .wind.speed)")

unit_sym="°F"
[[ "$UNITS" == "metric" ]] && unit_sym="°C"

now_hdr="<b>Now</b>"
now_line="${c_icon}  ${name} • ${c_desc} • ${c_temp}${unit_sym} (feels ${c_feels}${unit_sym}) • 💧${c_hum}% • 🌬️ ${c_wind} mph"

# --- NEXT 12 HOURS (4 x 3h entries) ---
hour_hdr="\n<b>Next 12 hours</b>"
hour_lines=""
if [[ -n "$forecast" ]]; then
  # Build compact JSON: take first 4 entries (3h step)
  next12=$(echo "$forecast" | jq -r '
    .list[:4] |
    map({t:.dt, m:.weather[0].main, d:.weather[0].description, temp:(.main.temp|floor), wind:(.wind.speed|floor)})')

  # Iterate rows
  count=$(echo "$next12" | jq 'length')
  if [[ "$count" -gt 0 ]]; then
    for i in $(seq 0 $((count-1))); do
      t=$(echo "$next12" | jq -r ".[$i].t")
      m=$(echo "$next12" | jq -r ".[$i].m")
      d=$(echo "$next12" | jq -r ".[$i].d" | awk '{print tolower($0)}')
      temp=$(echo "$next12" | jq -r ".[$i].temp")
      wind=$(echo "$next12" | jq -r ".[$i].wind")
      icon=$(icon_for_main "$m")
      time=$(date -d "@$t" +"%I:%M %p")
      hour_lines+="${icon}  ${time} • ${d} • ${temp}${unit_sym} • 🌬️ ${wind} mph\n"
    done
  fi
fi
[[ -z "$hour_lines" ]] && hour_lines="(no forecast data)\n"

# --- 5-DAY SUMMARY (hi/lo per day + dominant condition) ---
day_hdr="\n<b>5-day</b>"
day_lines=""
if [[ -n "$forecast" ]]; then
  days=$(echo "$forecast" | jq -r '
    .list
    | group_by(.dt_txt[0:10])
    | .[:5]
    | map({
        date: (.[0].dt | strftime("%a %m/%d")),
        hi: (max_by(.main.temp_max).main.temp_max | ceil),
        lo: (min_by(.main.temp_min).main.temp_min | floor),
        main: ((group_by(.weather[0].main) | max_by(length))[0].weather[0].main)
      })
  ')
  count=$(echo "$days" | jq 'length')
  if [[ "$count" -gt 0 ]]; then
    for i in $(seq 0 $((count-1))); do
      date_lbl=$(echo "$days" | jq -r ".[$i].date")
      main=$(echo "$days" | jq -r ".[$i].main")
      hi=$(printf "%.0f" "$(echo "$days" | jq -r ".[$i].hi")")
      lo=$(printf "%.0f" "$(echo "$days" | jq -r ".[$i].lo")")
      icon=$(icon_for_main "$main")
      day_lines+="${date_lbl} • ${icon} ${main} • ↑${hi}${unit_sym} ↓${lo}${unit_sym}\n"
    done
  fi
fi
[[ -z "$day_lines" ]] && day_lines="(no daily data)\n"

# --- MENU TEXT (with headers, markup on) ---
menu="$(printf "%s\n%s\n%s\n%s\n%s\n%s" "$now_hdr" "$now_line" "$hour_hdr" "$hour_lines" "$day_hdr" "$day_lines" | sed '/^$/d')"

# Auto-size lines (cap to 20 for sanity)
lines=$(echo -e "$menu" | wc -l)
[[ "$lines" -gt 20 ]] && lines=20

# --- SHOW ---
echo -e "$menu" | rofi -dmenu -i -p "Weather" -lines "$lines" -theme "$ROFI_THEME" -markup-rows >/dev/null
