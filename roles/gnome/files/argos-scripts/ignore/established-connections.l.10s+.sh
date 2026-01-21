#!/usr/bin/env bash

echo "🔗"
echo "---"
FILENAME="/tmp/established-connections.result"

netstat -atp 2>&1 |  grep ESTA | awk '{print $5}' | awk -F':' '{print $1 "\t" $NF}' > "$FILENAME"

if [ "$ARGOS_MENU_OPEN" == "true" ]; then
    RESULT=$(tail -n +3 "$FILENAME" | column -t | awk 1 ORS="\\\\n")
    echo "🔗 Established connections:\n---------------------------\n$RESULT | font=monospace bash=top"
else
    echo "Loading..."
fi
