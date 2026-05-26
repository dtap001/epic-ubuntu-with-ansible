#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# When run via sudo, $USER is root; use the invoking user for paths and vault key.
REAL_USER="${SUDO_USER:-${USER}}"
export EPIC_REPO_ROOT="$SCRIPT_DIR"
export EPIC_REAL_USER="$REAL_USER"

"$SCRIPT_DIR/.scripts/prepare.sh"
"$SCRIPT_DIR/.scripts/setup.sh"

HOSTNAME=$(hostname)
VAULT_KEY_PATH="/home/${REAL_USER}/.ansible/vault-key"

echo "Executing main playbook -i $SCRIPT_DIR/inventories/inventory.yml $SCRIPT_DIR/configure.playbook.yml --limit $HOSTNAME --vault-password-file $VAULT_KEY_PATH"
ansible-playbook --ask-become-pass \
  -i "$SCRIPT_DIR/inventories/inventory.yml" \
  "$SCRIPT_DIR/configure.playbook.yml" \
  --limit "$HOSTNAME" \
  --vault-password-file "$VAULT_KEY_PATH"