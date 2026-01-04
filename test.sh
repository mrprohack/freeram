#!/usr/bin/env bash

# freeram test suite

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FREERAM="$SCRIPT_DIR/freeram"
PASS=0
FAIL=0

pass() { echo "✓ $1"; ((PASS++)); }
fail() { echo "✗ $1"; ((FAIL++)); }

echo "freeram Test Suite"
echo "=================="
echo ""

# Test 1: Syntax check
if bash -n "$FREERAM" 2>/dev/null; then
  pass "Syntax check"
else
  fail "Syntax check"
fi

# Test 2: Help option
if "$FREERAM" -h 2>/dev/null | grep -q "Usage"; then
  pass "Help option (-h)"
else
  fail "Help option (-h)"
fi

# Test 3: Version option
if "$FREERAM" -v 2>/dev/null | grep -q "freeram"; then
  pass "Version option (-v)"
else
  fail "Version option (-v)"
fi

# Test 4: Test mode
if "$FREERAM" -t 2>/dev/null | grep -q "TEST MODE"; then
  pass "Test mode (-t)"
else
  fail "Test mode (-t)"
fi

# Test 5: Stats option (should not error)
if "$FREERAM" --stats 2>/dev/null | grep -q "Statistics"; then
  pass "Stats option (--stats)"
else
  fail "Stats option (--stats)"
fi

# Test 6: Run as non-root (should fail)
if ! "$FREERAM" -y 2>/dev/null; then
  pass "Non-root rejection"
else
  fail "Non-root rejection"
fi

# Test 7: Memory reading
MEM_FREE=$("$FREERAM" --stats 2>/dev/null | grep "Free:" | grep -oE '[0-9]+')
if [[ -n "$MEM_FREE" ]] && [[ "$MEM_FREE" -gt 0 ]]; then
  pass "Memory reading ($MEM_FREE MiB)"
else
  fail "Memory reading"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
exit $FAIL
