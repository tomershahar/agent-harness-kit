#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0
pass() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

echo "--- harness-onboard tests ---"

bash -n "$REPO_ROOT/skills/harness-onboard/scripts/harness-onboard.sh" \
  && pass "harness-onboard.sh syntax valid" \
  || fail "harness-onboard.sh syntax invalid"

# Integration: full harness — should show project name, run commands, next steps, active features
TMP_PROJECT=$(mktemp -d)
git -C "$TMP_PROJECT" init -q
git -C "$TMP_PROJECT" config user.email "test@test.com"
git -C "$TMP_PROJECT" config user.name "Test"

cat > "$TMP_PROJECT/AGENTS.md" << 'EOF'
# AGENTS.md — my-test-app
## Overview
A test application. Tech: Node.js
## Run Commands
- Tests: npm test
- Full verification: npm test
## Hard Constraints
- No eval()
EOF

cat > "$TMP_PROJECT/PROGRESS.md" << 'EOF'
# PROGRESS.md

## Next Steps
1. Add authentication
2. Write API tests
EOF

cat > "$TMP_PROJECT/feature_list.json" << 'EOF'
{
  "project": "my-test-app",
  "features": [
    {"id": "auth", "name": "Authentication", "status": "active"},
    {"id": "api", "name": "REST API", "status": "passing"}
  ]
}
EOF

git -C "$TMP_PROJECT" add . && git -C "$TMP_PROJECT" commit -q -m "initial"

cd "$TMP_PROJECT"
OUTPUT=$(bash "$REPO_ROOT/skills/harness-onboard/scripts/harness-onboard.sh" 2>/dev/null)

echo "$OUTPUT" | grep -q "my-test-app" \
  && pass "onboard shows project name" \
  || fail "onboard missing project name"

echo "$OUTPUT" | grep -q "npm test" \
  && pass "onboard shows run commands" \
  || fail "onboard missing run commands"

echo "$OUTPUT" | grep -q "authentication\|Authentication\|Next Steps" \
  && pass "onboard shows next steps from PROGRESS.md" \
  || fail "onboard missing next steps"

echo "$OUTPUT" | grep -q "active\|Authentication" \
  && pass "onboard shows active features" \
  || fail "onboard missing active features"

# Integration: no harness — should warn
TMP_EMPTY=$(mktemp -d)
git -C "$TMP_EMPTY" init -q
git -C "$TMP_EMPTY" config user.email "test@test.com"
git -C "$TMP_EMPTY" config user.name "Test"
touch "$TMP_EMPTY/README.md"
git -C "$TMP_EMPTY" add . && git -C "$TMP_EMPTY" commit -q -m "init"
cd "$TMP_EMPTY"
EMPTY_OUTPUT=$(bash "$REPO_ROOT/skills/harness-onboard/scripts/harness-onboard.sh" 2>/dev/null)
echo "$EMPTY_OUTPUT" | grep -qi "no harness\|harness-init\|missing\|not.*found\|AGENTS.md" \
  && pass "onboard warns when no harness found" \
  || fail "onboard missing warning for un-harnessed repo"

rm -rf "$TMP_PROJECT" "$TMP_EMPTY"

echo ""
echo "harness-onboard: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
