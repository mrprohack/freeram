#!/usr/bin/env bash

# freeram installer
# Installs freeram to system

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="$SCRIPT_DIR/freeram"
TARGET_DIR="/usr/local/bin"
TARGET_FILE="$TARGET_DIR/freeram"
LOG_FILE="/var/log/freeram.log"
HISTORY_DIR="/var/lib/freeram"

echo "freeram Installer"
echo "================="

# Check if source exists
[[ -f "$SOURCE_FILE" ]] || { echo "Error: freeram script not found in $SCRIPT_DIR" >&2; exit 1; }

# Check if already installed
if [[ -f "$TARGET_FILE" ]]; then
  echo "freeram is already installed at $TARGET_FILE"
  read -p "Reinstall? (y/n): " -n 1; echo
  [[ ! $REPLY =~ ^[Yy] ]] && { echo "Cancelled"; exit 0; }
fi

# Install script
echo "Installing freeram to $TARGET_FILE..."
cp "$SOURCE_FILE" "$TARGET_FILE"
chmod +x "$TARGET_FILE"

# Setup log file
echo "Setting up log file..."
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

# Setup history directory
echo "Setting up history directory..."
mkdir -p "$HISTORY_DIR"
chmod 755 "$HISTORY_DIR"

# Create symlink for convenience
ln -sf "$TARGET_FILE" /usr/local/bin/freeram 2>/dev/null || true

echo ""
echo "Installation complete!"
echo ""
echo "Usage:"
echo "  sudo freeram           # Interactive mode"
echo "  sudo freeram -y        # Auto-confirm"
echo "  sudo freeram -s        # Silent mode"
echo "  sudo freeram --stats   # Show statistics"
echo ""
echo "Log file: $LOG_FILE"
