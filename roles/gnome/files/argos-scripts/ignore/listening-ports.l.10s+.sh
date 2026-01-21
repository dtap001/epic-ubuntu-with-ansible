#!/usr/bin/env bash

echo "👂🏼"
echo "---"
FILENAME="/tmp/listening-ports.result"

netstat -tuln | awk '{print $4}' | sort | uniq | grep -v '^:::' > "$FILENAME"

if [ "$ARGOS_MENU_OPEN" == "true" ]; then
    RESULT=$(tail -n +3 "$FILENAME" | column -t | awk 1 ORS="\\\\n")
    echo "👂🏼 Listening ports:\n---------------------------\n$RESULT | font=monospace bash=top"
else
    echo "Loading..."
fi
