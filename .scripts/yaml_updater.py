#!/usr/bin/env python3
"""Interactive YAML updater.

Reimplementation of `yaml_updater.sh` in Python.

- Uses `yq` to read YAML keys and values.
- Writes each top-level key as a YAML literal block (`|-`) for multi-line strings.
- Writes objects (maps) and lists (sequences) as proper YAML, not strings.
- Writes booleans as YAML booleans (true/false).

Usage:
    yaml_updater.py <yaml-file>
"""
import os
import re
import shutil
import subprocess
import sys
import tempfile


def add_leading_spaces(text: str) -> str:
    """Indent all lines by two spaces (for YAML block style)."""
    if text is None:
        return ""
    lines = text.rstrip("\n").splitlines()
    if not lines:
        return "  "
    return "\n".join("  " + line for line in lines)


def get_yq_value(yaml_file: str, key: str) -> str:
    """Get the raw YAML value for a given key."""
    try:
        return subprocess.check_output(
            ["yq", "eval", f".{key}", yaml_file],
            text=True,
        )
    except subprocess.CalledProcessError:
        return ""


def get_yq_type(yaml_file: str, key: str) -> str:
    """Get the YAML type of a key (e.g. !!str, !!seq, !!map, !!bool)."""
    try:
        return subprocess.check_output(
            ["yq", "eval", f".{key} | tag", yaml_file],
            text=True,
        ).strip()
    except subprocess.CalledProcessError:
        return "!!str"


def main():
    if len(sys.argv) < 2:
        print("Usage: yaml_updater.py <yaml-file>")
        sys.exit(1)

    yaml_file = sys.argv[1]

    if not os.path.isfile(yaml_file):
        print(f"Error: File '{yaml_file}' not found.")
        sys.exit(1)

    if shutil.which("yq") is None:
        print("Error: yq command not found. Please install yq.")
        sys.exit(1)

    try:
        keys_output = subprocess.check_output(
            ["yq", "eval", "keys", yaml_file], text=True
        )
    except subprocess.CalledProcessError as e:
        print("Error: failed to read keys from YAML via yq:", e)
        sys.exit(1)

    keys = [line.lstrip("- ").strip() for line in keys_output.splitlines() if line.strip()]

    # Create temporary file in the same directory to avoid cross-device issues
    target_dir = os.path.dirname(os.path.abspath(yaml_file)) or "."
    fd, tmp_path = tempfile.mkstemp(dir=target_dir)
    os.close(fd)

    try:
        with open(tmp_path, "w", encoding="utf-8") as out:
            for key in keys:
                # Special-case for "user"
                if key == "user":
                    out.write(f"{key}: |-\n  {os.environ.get('USER', '')}\n")
                    continue

                current_value = get_yq_value(yaml_file, key)
                current_value_raw = current_value.strip()
                value_type = get_yq_type(yaml_file, key)

                is_bool_key = bool(re.search(r"(_role_enabled$|^enabled_)", key))
                is_object_or_list = value_type in ("!!map", "!!seq")

                formatted_current_value = add_leading_spaces(current_value)

                print(f"\nCurrent value for '{key}':")
                print(formatted_current_value)

                confirm = input("Is this value okay? [Y/n]: ").strip()
                if confirm.lower().startswith("n"):
                    if is_bool_key:
                        # Ask until a valid boolean is entered
                        while True:
                            new_value = input(
                                f"Enter new value for '{key}' [true/false]: "
                            ).strip().lower()
                            if new_value in ("true", "false", "y", "n", "yes", "no"):
                                if new_value in ("y", "yes"):
                                    new_value = "true"
                                elif new_value in ("n", "no"):
                                    new_value = "false"
                                out.write(f"{key}: {new_value}\n")
                                break
                            else:
                                print("Please enter 'true' or 'false' (or y/n).")
                    else:
                        new_value = input(f"Enter new value for '{key}': ")
                        formatted_new_value = add_leading_spaces(new_value)
                        out.write(f"{key}: |-\n{formatted_new_value}\n")
                else:
                    # Write the existing value with the correct YAML style
                    if is_bool_key and current_value_raw.lower() in ("true", "false"):
                        out.write(f"{key}: {current_value_raw.lower()}\n")
                    elif is_object_or_list:
                        # Maps or lists: write as-is, no literal block
                        out.write(f"{key}:\n{formatted_current_value}\n")
                    else:
                        # Scalars or strings: write with literal block
                        out.write(f"{key}: |-\n{formatted_current_value}\n")

        os.replace(tmp_path, yaml_file)
        print(f"\n✅ Updated values saved to '{yaml_file}'")

    finally:
        if os.path.exists(tmp_path):
            try:
                os.remove(tmp_path)
            except Exception:
                pass


if __name__ == "__main__":
    main()
