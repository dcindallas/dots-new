#!/bin/bash

# Start flipclock (or your desired command) after 2 minutes of idle time
xidlehook \
  --timer 120 \
  "flipclock" \
  ""
