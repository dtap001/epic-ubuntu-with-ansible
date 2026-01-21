#!/usr/bin/env bash
COUNT=$(journalctl -r --since "1 minutes ago" | grep -i error | grep -v -E -i "pciepor|alx" | wc -l)
echo "❗$COUNT"
echo "---"


if [ "$ARGOS_MENU_OPEN" == "true" ]; then
    RESULT=$(journalctl -r --since "1 minutes ago" | grep -i error | grep -v -E -i "pciepor|alx" | awk 1 ORS="\\\\n")
    echo "❗ $COUNT Errors  in journalctl in the last 1 minutes\n---------------------------\n$RESULT | font=monospace bash=top"
else
    echo "Loading..."
fi
