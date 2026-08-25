#!/usr/bin/env bash

# freeram installer

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="$SCRIPT_DIR/freeram"
SOURCE_MAN="$SCRIPT_DIR/freeram.1"
INSTALL_ROOT="${FREERAM_INSTALL_ROOT:-}"
EFFECTIVE_UID="${FREERAM_EUID:-$EUID}"
TARGET_DIR="$INSTALL_ROOT/usr/local/bin"
TARGET_FILE="$TARGET_DIR/freeram"
MAN_DIR="$INSTALL_ROOT/usr/local/share/man/man1"
MAN_FILE="$MAN_DIR/freeram.1"
LOG_FILE="$INSTALL_ROOT/var/log/freeram.log"
HISTORY_DIR="$INSTALL_ROOT/var/lib/freeram"
AUTO_YES=false

error() { printf 'freeram installer: %s\n' "$*" >&2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) AUTO_YES=true ;;
    -h|--help)
      printf 'Usage: sudo ./install.sh [--yes]\n'
      exit 0
      ;;
    *) error "Unknown option: $1"; exit 2 ;;
  esac
  shift
done

[[ "$EFFECTIVE_UID" == "0" ]] || { error "Installation requires root privileges; re-run with sudo."; exit 1; }
[[ -f "$SOURCE_FILE" ]] || { error "Main script not found: $SOURCE_FILE"; exit 1; }
[[ -f "$SOURCE_MAN" ]] || { error "Man page not found: $SOURCE_MAN"; exit 1; }

if [[ -e "$TARGET_FILE" && "$AUTO_YES" != "true" ]]; then
  [[ -t 0 ]] || { error "freeram is already installed; use --yes to reinstall non-interactively."; exit 2; }
  read -r -p "freeram is already installed. Reinstall? [y/N]: " reply
  [[ "$reply" =~ ^[Yy]$ ]] || { printf 'Cancelled\n'; exit 0; }
fi

printf 'freeram Installer\n=================\n'
printf 'Installing binary and man page...\n'

mkdir -p "$TARGET_DIR" "$MAN_DIR" "$(dirname "$LOG_FILE")" "$HISTORY_DIR" || {
  error "Failed to create installation directories."
  exit 1
}

cp "$SOURCE_FILE" "$TARGET_FILE" || { error "Failed to install $TARGET_FILE"; exit 1; }
chmod 0755 "$TARGET_FILE" || { error "Failed to set executable permissions on $TARGET_FILE"; exit 1; }

cp "$SOURCE_MAN" "$MAN_FILE" || { error "Failed to install $MAN_FILE"; exit 1; }
chmod 0644 "$MAN_FILE" || { error "Failed to set permissions on $MAN_FILE"; exit 1; }

touch "$LOG_FILE" || { error "Failed to create $LOG_FILE"; exit 1; }
chmod 0644 "$LOG_FILE" || { error "Failed to set permissions on $LOG_FILE"; exit 1; }
chmod 0755 "$HISTORY_DIR" || { error "Failed to set permissions on $HISTORY_DIR"; exit 1; }

printf '\nInstallation complete.\n'
printf 'Binary: %s\n' "$TARGET_FILE"
printf 'Man page: %s\n' "$MAN_FILE"
printf 'Log: %s\n' "$LOG_FILE"
printf '\nExamples:\n'
printf '  sudo freeram\n'
printf '  sudo freeram --yes\n'
printf '  sudo freeram --yes --silent\n'
printf '  freeram --test\n'
printf '  freeram --stats\n'
