#!/bin/bash

add_leading_spaces() {
  while IFS= read -r line; do
    echo "  $line"
  done
}

yaml_file=$1
tmp_file=$(mktemp)

if [ ! -f "$yaml_file" ]; then
  echo "Error: File '$yaml_file' not found."
  exit 1
fi

# Check if yq is installed
if ! command -v yq &> /dev/null; then
  echo "Error: yq command not found. Please install yq."
  exit 1
fi

# Get all keys from the YAML file
keys=$(yq eval 'keys' "$yaml_file" | sed 's/^- //')

# Iterate over each key
for key in $keys; do
  if [[ $key == "user" ]] ; then
      echo -e "$key: |- \n  $USER" >> "$tmp_file"
      continue
  fi
  # Get the current value of the key
  current_value=$(yq eval ".${key}" "$yaml_file")

  # Format the current value with two leading whitespaces
  formatted_current_value=$(echo "$current_value" | add_leading_spaces)

  # Ask user if the value is okay
  echo "Current value for '$key':"
  echo "$formatted_current_value"
  read -p "Is this value okay? [Y/n]: " confirm
  if [[ "$confirm" =~ ^[Nn]$ ]]; then
    echo "Enter new value for '$key' (end input with Ctrl+D):"
    new_value=$(cat)  # Read multi-line input until Ctrl+D
    # read -p "Enter new value for '$key': " new_value

    # Format the new value with two leading whitespaces
    formatted_new_value=$(echo "$new_value" | add_leading_spaces)

    # Escape quotes for YAML compatibility
    formatted_new_value=$(echo "$formatted_new_value" | sed 's/"/\\"/g')
    echo -e "$key: |-\n$formatted_new_value" >> "$tmp_file"
  else
    echo -e "$key: |-\n$formatted_current_value" >> "$tmp_file"
  fi
done

# Replace the original file with the updated temporary file
mv "$tmp_file" "$yaml_file"
echo "Updated values saved to '$yaml_file'"
