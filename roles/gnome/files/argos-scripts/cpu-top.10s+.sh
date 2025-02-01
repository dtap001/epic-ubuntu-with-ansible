#!/usr/bin/env bash
RESULT=$(ps -eo %cpu,cmd --sort=-%cpu | awk 'NR==2 {print "🔥", $1"%", $2}')
WIDTH=1921
if [ "$WIDTH" -lt 1921 ]; then
  echo " "
  exit 1
fi
echo "$RESULT"
echo "---"

if [ "$ARGOS_MENU_OPEN" == "true" ]; then
    echo "$RESULT | font=monospace bash=top"
else
    echo "Loading..."
fi








