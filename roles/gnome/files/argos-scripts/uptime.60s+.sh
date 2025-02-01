#!/usr/bin/env bash

WIDTH=1921
if [ "$WIDTH" -lt 1921 ]; then
  echo " "
  exit 1
fi

UPTIME=$(uptime -p | sed 's/up\s*//g' | sed 's/\s*days/d/g' | sed 's/\s*hours/h/g' | sed 's/\s*minutes/m/g')
echo "🕒 $UPTIME"
echo "---"


if [ "$ARGOS_MENU_OPEN" == "true" ]; then
    echo "❗ 🕒 $UPTIME | font=monospace bash=top"
else
    echo "Loading..."
fi


