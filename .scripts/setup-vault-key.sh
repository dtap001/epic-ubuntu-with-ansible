#!/bin/bash
user="$1"
echo "setup_vault-key. user: $user"
FOLDER_PATH="/home/$user/.ansible"
VAULT_KEY_PATH="$FOLDER_PATH/vault-key"

# Check if folder exists
if [ ! -d "$FOLDER_PATH" ]; then
    echo "Folder doesn't exist. Creating folder..."
    mkdir -p "$FOLDER_PATH"
fi

# Check if key file exists
if [ ! -f "$VAULT_KEY_PATH" ]; then
    echo "Key file doesn't exist. Creating key file..."
    # Generate random 128-character text and save it to the file
    openssl rand -base64 128 | tr -dc 'a-zA-Z0-9' | head -c 128 > "$VAULT_KEY_PATH"
    echo "Vault key file created at $VAULT_KEY_PATH"
else
    echo "Vault key file already exists at $VAULT_KEY_PATH"
fi

get_vault_path() {
    echo "$VAULT_KEY_PATH"
}