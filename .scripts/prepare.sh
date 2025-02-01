#!/bin/bash

# Define the path for the temporary file
TMP_FILE="/tmp/install_dependencies_last_run"

# Get the current timestamp
CURRENT_TIME=$(date +%s)

# Check if the temporary file exists and get its last modification time
if [ -f "$TMP_FILE" ]; then
    LAST_MOD_TIME=$(stat -c %Y "$TMP_FILE")
    # Check if the last modification was more than 24 hours ago
    if [ $((CURRENT_TIME - LAST_MOD_TIME)) -le 86400 ]; then
        echo "Script already run today. Exiting."
        exit 0
    fi
fi

# Run the installation commands
echo "Installing dependencies"
sudo apt update
sudo apt-get install git ansible ansible-lint -y
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq
sudo chmod +x /usr/bin/yq

# Update the timestamp of the temporary file
touch "$TMP_FILE"
