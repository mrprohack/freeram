#!/usr/bin/env bash

# freeram uninstaller

set -euo pipefail

TARGET_FILE="/usr/local/bin/freeram"
LOG_FILE="/var/log/freeram.log"
HISTORY_DIR="/var/lib/freeram"

echo "freeram Uninstaller"
echo "==================="

# Check if installed
[[ -f "$TARGET_FILE" ]] || { echo "freeram is not installed" >&2; exit 1; }

read -p "Remove freeram? (y/n): " -n 1; echo
[[ ! $REPLY =~ ^[Yy] ]] && { echo "Cancelled"; exit 0; }

# Remove script
echo "Removing freeram..."
rm -f "$TARGET_FILE"

# Ask about logs
echo ""
read -p "Remove log file? (y/n): " -n 1; echo
[[ $REPLY =~ ^[Yy] ]] && rm -f "$LOG_FILE" && echo "Removed $LOG_FILE"

# Ask about history
echo ""
read -p "Remove history directory? (y/n): " -n 1; echo
[[ $REPLY =~ ^[Yy] ]] && rm -rf "$HISTORY_DIR" && echo "Removed $HISTORY_DIR"

echo ""
echo "freeram has been uninstalled."
