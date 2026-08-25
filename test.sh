#!/usr/bin/env bash

# freeram regression test suite

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FREERAM="$SCRIPT_DIR/freeram"
PASS=0
FAIL=0
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

pass() { printf '✓ %s\n' "$1"; PASS=$((PASS + 1)); }
fail() { printf '✗ %s\n' "$1"; FAIL=$((FAIL + 1)); }

assert_success() {
  local name="$1"; shift
  if "$@" >"$TMP_DIR/out" 2>"$TMP_DIR/err"; then pass "$name"; else fail "$name"; cat "$TMP_DIR/err" >&2; fi
}

assert_failure_contains() {
  local name="$1" expected="$2"; shift 2
  if "$@" >"$TMP_DIR/out" 2>"$TMP_DIR/err"; then
    fail "$name (unexpected success)"
  elif grep -Fq "$expected" "$TMP_DIR/err"; then
    pass "$name"
  else
    fail "$name (missing error: $expected)"
    cat "$TMP_DIR/err" >&2
  fi
}

assert_output_contains() {
  local name="$1" expected="$2"; shift 2
  if "$@" >"$TMP_DIR/out" 2>"$TMP_DIR/err" && grep -Fq "$expected" "$TMP_DIR/out"; then
    pass "$name"
  else
    fail "$name (missing output: $expected)"
    cat "$TMP_DIR/out" >&2
    cat "$TMP_DIR/err" >&2
  fi
}

cat >"$TMP_DIR/meminfo" <<'MEMINFO'
MemTotal:        8000000 kB
MemFree:         2048000 kB
Buffers:          128000 kB
Cached:          1024000 kB
SReclaimable:     256000 kB
Shmem:             64000 kB
MEMINFO

printf 'freeram Test Suite\n==================\n\n'

assert_success "Main script syntax" bash -n "$FREERAM"
assert_success "Installer syntax" bash -n "$SCRIPT_DIR/install.sh"
assert_success "Uninstaller syntax" bash -n "$SCRIPT_DIR/uninstall.sh"
assert_output_contains "Help option" "Usage:" "$FREERAM" --help
assert_output_contains "Version option" "freeram" "$FREERAM" --version
assert_failure_contains "Unknown option rejected" "Unknown option" "$FREERAM" --definitely-invalid

# Read-only commands must work without root. FREERAM_EUID is a test hook used
# to make this deterministic even when the suite itself runs as root.
assert_output_contains "Dry run works without root" "TEST MODE" env FREERAM_EUID=1000 FREERAM_MEMINFO="$TMP_DIR/meminfo" "$FREERAM" --test
assert_output_contains "Stats work without root" "Memory Statistics" env FREERAM_EUID=1000 FREERAM_MEMINFO="$TMP_DIR/meminfo" HISTORY="$TMP_DIR/missing-history" "$FREERAM" --stats

assert_failure_contains "Silent mode requires --yes" "requires --yes" env FREERAM_EUID=0 FREERAM_MEMINFO="$TMP_DIR/meminfo" FREERAM_DROP_CACHES="$TMP_DIR/drop-caches" "$FREERAM" --silent
assert_failure_contains "Cleaning requires root" "root privileges" env FREERAM_EUID=1000 FREERAM_MEMINFO="$TMP_DIR/meminfo" FREERAM_DROP_CACHES="$TMP_DIR/drop-caches" "$FREERAM" --yes
assert_failure_contains "Missing meminfo is reported" "Cannot read memory information" env FREERAM_EUID=1000 FREERAM_MEMINFO="$TMP_DIR/does-not-exist" "$FREERAM" --stats

# Cache-write failure must stop before success/history logging.
mkdir "$TMP_DIR/not-a-file"
if env FREERAM_EUID=0 FREERAM_MEMINFO="$TMP_DIR/meminfo" FREERAM_DROP_CACHES="$TMP_DIR/not-a-file" LOG="$TMP_DIR/freeram.log" HISTORY="$TMP_DIR/history" "$FREERAM" --yes >"$TMP_DIR/out" 2>"$TMP_DIR/err"; then
  fail "Cache-write failure returns non-zero"
elif grep -Fq "Failed to drop caches" "$TMP_DIR/err" && [[ ! -e "$TMP_DIR/history" ]] && ! grep -Fq "Freed" "$TMP_DIR/out"; then
  pass "Cache-write failure stops cleanly"
else
  fail "Cache-write failure stops cleanly"
  cat "$TMP_DIR/out" >&2
  cat "$TMP_DIR/err" >&2
fi

# Installer/uninstaller behavior is tested under a temporary filesystem root so
# the suite never modifies /usr or /var on the CI runner.
INSTALL_ROOT="$TMP_DIR/install-root"
assert_failure_contains "Installer requires root" "root privileges" env FREERAM_EUID=1000 FREERAM_INSTALL_ROOT="$INSTALL_ROOT" "$SCRIPT_DIR/install.sh" --yes
assert_success "Installer supports isolated root" env FREERAM_EUID=0 FREERAM_INSTALL_ROOT="$INSTALL_ROOT" "$SCRIPT_DIR/install.sh" --yes
if [[ -x "$INSTALL_ROOT/usr/local/bin/freeram" && -f "$INSTALL_ROOT/usr/local/share/man/man1/freeram.1" && -f "$INSTALL_ROOT/var/log/freeram.log" && -d "$INSTALL_ROOT/var/lib/freeram" ]]; then
  pass "Installer creates binary, man page, log, and history directory"
else
  fail "Installer creates binary, man page, log, and history directory"
fi
assert_failure_contains "Uninstaller requires root" "root privileges" env FREERAM_EUID=1000 FREERAM_INSTALL_ROOT="$INSTALL_ROOT" "$SCRIPT_DIR/uninstall.sh" --yes --purge
assert_success "Uninstaller supports non-interactive purge" env FREERAM_EUID=0 FREERAM_INSTALL_ROOT="$INSTALL_ROOT" "$SCRIPT_DIR/uninstall.sh" --yes --purge
if [[ ! -e "$INSTALL_ROOT/usr/local/bin/freeram" && ! -e "$INSTALL_ROOT/usr/local/share/man/man1/freeram.1" && ! -e "$INSTALL_ROOT/var/log/freeram.log" && ! -e "$INSTALL_ROOT/var/lib/freeram" ]]; then
  pass "Uninstaller purge removes installed files and data"
else
  fail "Uninstaller purge removes installed files and data"
fi

printf '\nResults: %d passed, %d failed\n' "$PASS" "$FAIL"
(( FAIL == 0 ))
