#!/usr/bin/env bash

echo "🦄"
echo "---"

echo "---"
echo "️docker stop all | bash='echo "killing all containers" && docker stop "$(docker ps -a -q)"'  terminal=true"
echo "docker system prune | bash='echo "system prune" && docker system prune -a'  terminal=true"