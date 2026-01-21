#!/bin/bash
# Lightweight wrapper: run the Python implementation
exec python3 "$(dirname "$0")/yaml_updater.py" "$@"
