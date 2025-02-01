#!/bin/bash
./.scripts/prepare.sh
./.scripts/setup.sh

HOSTNAME=$(hostname)
VAULT_KEY_PATH="/home/$USER/.ansible/vault-key"

echo "Executing main playbook -i ./inventories/inventory.yml ./configure.playbook.yml --limit $HOSTNAME --vault-password-file $VAULT_KEY_PATH"
ansible-playbook --ask-become-pass  -i ./inventories/inventory.yml ./configure.playbook.yml --limit "$HOSTNAME" --vault-password-file "$VAULT_KEY_PATH"