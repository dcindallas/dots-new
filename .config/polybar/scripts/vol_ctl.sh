#!/usr/bin/env bash
# up | down | toggle-mute

case "$1" in
  up)          pactl set-sink-volume @DEFAULT_SINK@ +5% ;;
  down)        pactl set-sink-volume @DEFAULT_SINK@ -5% ;;
  toggle-mute) pactl set-sink-mute   @DEFAULT_SINK@ toggle ;;
esac
