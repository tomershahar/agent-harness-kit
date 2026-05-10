#!/usr/bin/env bash
# run-all.sh — Run all harness skill tests
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOTAL_PASS=0
TOTAL_FAIL=0

run_suite() {
  local script="$1"
  local output
  output=$(bash "$script" 2>/dev/null)
  echo "$output"
  local passed failed
  passed=$(echo "$output" | grep -oE '[0-9]+ passed' | grep -oE '[0-9]+' || echo 0)
  failed=$(echo "$output" | grep -oE '[0-9]+ failed' | grep -oE '[0-9]+' || echo 0)
  TOTAL_PASS=$((TOTAL_PASS + passed))
  TOTAL_FAIL=$((TOTAL_FAIL + failed))
}

echo "=== agent-harness-kit test suite ==="
echo ""

run_suite "$REPO_ROOT/tests/test-harness-init.sh"
echo ""
run_suite "$REPO_ROOT/tests/test-harness-audit.sh"
echo ""
run_suite "$REPO_ROOT/tests/test-harness-handoff.sh"
echo ""
run_suite "$REPO_ROOT/tests/test-harness-onboard.sh"
echo ""

echo "=== Total: $TOTAL_PASS passed, $TOTAL_FAIL failed ==="
[ "$TOTAL_FAIL" -eq 0 ] || exit 1
