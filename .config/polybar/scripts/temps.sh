#!/usr/bin/env bash
# Arch + Polybar: temps + cpu% + mem% with warn coloring

LANG=C

# ---------- COLORS (Smokula) ----------
normal="%{F#8f9d6a}"   # green-ish OK
warn="%{F#cf6a4c}"     # red/orange warn
reset="%{F-}"

# ---------- THRESHOLDS ----------
cpu_temp_warn_f=185    # ~85°C
gpu_temp_warn_f=176    # ~80°C
cpu_usage_warn=80      # %
mem_usage_warn=80      # %

# ---------- TEMPS (°F) ----------
# CPU (Tctl)
cpu_temp_c=$(sensors 2>/dev/null | awk '/Tctl:/ {print int($2); exit}')
# GPU (edge)
gpu_temp_c=$(sensors 2>/dev/null | awk '/edge:/ {print int($2); exit}')

# Fallback if empty
cpu_temp_c=${cpu_temp_c:-0}
gpu_temp_c=${gpu_temp_c:-0}

cpu_temp=$(( (cpu_temp_c * 9 / 5) + 32 ))
gpu_temp=$(( (gpu_temp_c * 9 / 5) + 32 ))

cpu_temp_out="${cpu_temp}°F"
gpu_temp_out="${gpu_temp}°F"

[[ $cpu_temp -ge $cpu_temp_warn_f ]] && cpu_temp_out="$warn$cpu_temp_out$reset"
[[ $gpu_temp -ge $gpu_temp_warn_f ]] && gpu_temp_out="$warn$gpu_temp_out$reset"

# ---------- CPU USAGE (%) ----------
# Calculate from /proc/stat using deltas across runs
state=/tmp/polybar_cpu_stat
read cpu a b c d e f g h i j < /proc/stat
# total = user+nice+system+idle+iowait+irq+softirq+steal+guest+guest_nice
total=$((a+b+c+d+e+f+g+h+i+j))
idle=$((d+e))

if [[ -f $state ]]; then
    read -r prev_total prev_idle < "$state"
    dt=$(( total - prev_total ))
    di=$(( idle  - prev_idle  ))
    cpu_used=$(( dt - di ))
    cpu_pct=$(( dt > 0 ? (100 * cpu_used / dt) : 0 ))
else
    cpu_pct=0
fi
printf "%s %s\n" "$total" "$idle" > "$state"

cpu_pct_out="${cpu_pct}%"
[[ $cpu_pct -ge $cpu_usage_warn ]] && cpu_pct_out="$warn$cpu_pct_out$reset"

# ---------- MEM USAGE (%) ----------
# Use MemAvailable for realistic “used”
read -r _ MemTotal _ < <(grep -m1 '^MemTotal:' /proc/meminfo)
read -r _ MemAvail _ < <(grep -m1 '^MemAvailable:' /proc/meminfo)
# values are in kB
used_kb=$(( MemTotal - MemAvail ))
mem_pct=$(( (100 * used_kb) / MemTotal ))

mem_pct_out="${mem_pct}%"
[[ $mem_pct -ge $mem_usage_warn ]] && mem_pct_out="$warn$mem_pct_out$reset"

# ---------- OUTPUT (keep spacing) ----------
# keep labels uncolored; color only values like your original
echo -n "CPU: $normal$cpu_temp_out$reset"
echo -n "  GPU: $normal$gpu_temp_out$reset"
echo -n "  CPU%: $normal$cpu_pct_out$reset"
echo    "  MEM: $normal$mem_pct_out$reset"
