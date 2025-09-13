#!/bin/bash

# Export DBUS session address from dunst
pid=$(pgrep -u "$USER" -x dunst)
[[ -z "$pid" ]] && exit 1

address=$(tr '\0' '\n' < /proc/"$pid"/environ | grep DBUS_SESSION_BUS_ADDRESS | cut -d= -f2-)
[[ -n "$address" ]] && echo "$address" > ~/.cache/dbus-dunst.address
