#!/usr/bin/env bash

# freeram uninstaller

set -euo pipefail

INSTALL_ROOT="${FREERAM_INSTALL_ROOT:-}"
EFFECTIVE_UID="${FREERAM_EUID:-$EUID}"
TARGET_FILE="$INSTALL_ROOT/usr/local/bin/freeram"
MAN_FILE="$INSTALL_ROOT/usr/local/share/man/man1/freeram.1"
LOG_FILE="$INSTALL_ROOT/var/log/freeram.log"
HISTORY_DIR="$INSTALL_ROOT/var/lib/freeram"
AUTO_YES=false
PURGE=false

error() { printf 'freeram uninstaller: %s\n' "$*" >&2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) AUTO_YES=true ;;
    --purge) PURGE=true ;;
    -h|--help)
      printf 'Usage: sudo ./uninstall.sh [--yes] [--purge]\n'
      printf '  --purge  Also remove freeram log and history data.\n'
      exit 0
      ;;
    *) error "Unknown option: $1"; exit 2 ;;
  esac
  shift
done

[[ "$EFFECTIVE_UID" == "0" ]] || { error "Uninstallation requires root privileges; re-run with sudo."; exit 1; }

if [[ ! -e "$TARGET_FILE" && ! -e "$MAN_FILE" ]]; then
  error "freeram is not installed under ${INSTALL_ROOT:-/}."
  exit 1
fi

if [[ "$AUTO_YES" != "true" ]]; then
  [[ -t 0 ]] || { error "Confirmation requires a terminal; use --yes for non-interactive removal."; exit 2; }
  read -r -p "Remove freeram? [y/N]: " reply
  [[ "$reply" =~ ^[Yy]$ ]] || { printf 'Cancelled\n'; exit 0; }
fi

printf 'freeram Uninstaller\n===================\n'
rm -f "$TARGET_FILE" "$MAN_FILE" || { error "Failed to remove installed program files."; exit 1; }

if [[ "$PURGE" == "true" ]]; then
  rm -f "$LOG_FILE" || { error "Failed to remove $LOG_FILE"; exit 1; }
  rm -rf "$HISTORY_DIR" || { error "Failed to remove $HISTORY_DIR"; exit 1; }
  printf 'Removed freeram, log, and history data.\n'
else
  printf 'Removed freeram program files. Log and history data were kept.\n'
  printf 'Use --purge to remove data during uninstall.\n'
fi
