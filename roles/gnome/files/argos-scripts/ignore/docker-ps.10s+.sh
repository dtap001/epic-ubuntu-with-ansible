#!/usr/bin/env bash
WIDTH=1921
if [ "$WIDTH" -lt 1921 ]; then
  echo ""
  exit 1
fi
echo "📦 $(docker ps -q | wc -l)"
echo "---"

if [ "$ARGOS_MENU_OPEN" == "true" ]; then
    RESULT=$(docker ps -q| awk 1 ORS="\\\\n")
    echo "📦 Running containers:\n---------------------------\n$RESULT | font=monospace bash=top"
else
    echo "Loading..."
fi
