#!/bin/bash


HOSTNAME=$(hostname)
INVENTORIES_FILE_PATH="./inventories/inventory.yml"
INVENTORY_PATH="./inventories/host_vars/$HOSTNAME"
EXAMPLE_PATH="./inventories/host_vars/.example"

# Check if the inventory for the current hostname exists
if [ ! -e "$INVENTORY_PATH" ]; then
  echo "No inventory found for hostname '$HOSTNAME' in path $INVENTORY_PATH"

  # Prompt the user for a new hostname
  read -p "Please enter a new hostname: " newhostname

  # Check if the example inventory exists
  if [ ! -d "$EXAMPLE_PATH" ]; then
    echo "Error: Example inventory folder not found. Exiting."
    exit 1
  fi

  # Copy the example inventory folder to the new hostname's folder
  NEW_INVENTORY_PATH="./inventories/host_vars/$newhostname"
  cp -r "$EXAMPLE_PATH" "$NEW_INVENTORY_PATH"

  # Rename the example host_vars file to match the new hostname
  mv "$NEW_INVENTORY_PATH/host_vars/example.yml" "$NEW_INVENTORY_PATH/host_vars/$newhostname.yml"

  # Ensure the hostname line exists in the new host_vars file
  HOST_VARS_FILE="$NEW_INVENTORY_PATH/host_vars/$newhostname.yml"
  ./.scripts/yaml_updater.sh "$HOST_VARS_FILE"

  echo "New inventory created for hostname '$newhostname' at '$NEW_INVENTORY_PATH'."
  echo -e "\nhostname: $newhostname" >> "$HOST_VARS_FILE"
  INVENTORY_PATH="$NEW_INVENTORY_PATH/host"

  new_entry="        $newhostname:"
  echo "Adding '$new_entry; to $INVENTORIES_FILE_PATH to ensure the group vars are usable"
  if ! grep -Fxq "$new_entry" "$INVENTORIES_FILE_PATH"; then
    echo -e "\n$new_entry" | tee -a "$INVENTORIES_FILE_PATH" > /dev/null
  fi
  echo "Setting up hostname"
  sudo hostname "$newhostname"
  echo "Now check again which role you want to enable in the file: $NEW_INVENTORY_PATH/host_vars/$newhostname.yml"
fi

HOST_VARS_FILE="./inventories/host_vars/$(hostname)/host_vars/$(hostname).yml"
echo "Setting up vault key file based on host vars file: $HOST_VARS_FILE"
echo "Starting setup vault with user: $USER"
./.scripts/setup-vault-key.sh "$USER"

UPGRADE_PIDS=$(pgrep -f unattended-upgrade)

if [ -n "$UPGRADE_PIDS" ]; then
    echo "Unattended-upgrade processes found with PIDs: $UPGRADE_PIDS"
    echo "Attempting to kill each process..."

    for PID in $UPGRADE_PIDS; do
        echo "Killing process with PID: $PID"
        sudo kill -9 "$PID"
        echo "Process $PID killed successfully."
    done
else
    echo "No unattended-upgrade process running."
fi
