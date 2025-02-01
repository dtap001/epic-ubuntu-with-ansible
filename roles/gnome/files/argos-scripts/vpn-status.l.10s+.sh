#!/usr/bin/env bash
WIDTH=1921
if [ "$WIDTH" -lt 1920 ]; then
  echo " "
  exit 1
fi

RESULT=$(ip_address=$(ip address show dev tun0 | awk '/inet / {print $2}' | cut -d'/' -f1) && [ -n "$ip_address" ] && echo "✅ VPN $ip_address" || echo "📛 VPN ")

echo "$RESULT"
echo "---"

if [ "$ARGOS_MENU_OPEN" == "true" ]; then
    echo "$RESULT | font=monospace bash=top"
else
    echo "Loading..."
fi

