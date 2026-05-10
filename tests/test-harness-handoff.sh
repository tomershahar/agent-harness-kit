#!/usr/bin/env bash
# test-harness-handoff.sh — Verify harness-handoff script and templates
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

pass() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

echo "--- harness-handoff tests ---"

# Syntax check
bash -n "$REPO_ROOT/skills/harness-handoff/scripts/harness-handoff.sh" \
  && pass "harness-handoff.sh syntax valid" \
  || fail "harness-handoff.sh syntax invalid"

# SKILL.md has required frontmatter and attribution
for field in name description when_to_use license; do
  grep -q "^$field:" "$REPO_ROOT/skills/harness-handoff/SKILL.md" \
    && pass "SKILL.md has frontmatter: $field" \
    || fail "SKILL.md missing frontmatter: $field"
done

grep -q "Learn Harness Engineering" "$REPO_ROOT/skills/harness-handoff/SKILL.md" \
  && pass "SKILL.md has course attribution" \
  || fail "SKILL.md missing course attribution"

# Run handoff on a clean project — expect it to succeed and generate session-handoff.md
TMP_PROJECT=$(mktemp -d)
git -C "$TMP_PROJECT" init -q
git -C "$TMP_PROJECT" config user.email "test@test.com"
git -C "$TMP_PROJECT" config user.name "Test"
mkdir -p "$TMP_PROJECT/src"

cat > "$TMP_PROJECT/AGENTS.md" << 'EOF'
# AGENTS.md
## Overview
Test project
## Run Commands
- Tests: echo ok
EOF

echo "# PROGRESS" > "$TMP_PROJECT/PROGRESS.md"
echo '{"features":[]}' > "$TMP_PROJECT/feature_list.json"
echo "test" > "$TMP_PROJECT/src/index.test.js"

git -C "$TMP_PROJECT" add .
git -C "$TMP_PROJECT" commit -q -m "initial"

cd "$TMP_PROJECT"
HANDOFF_OUTPUT=$(bash "$REPO_ROOT/skills/harness-handoff/scripts/harness-handoff.sh" 2>/dev/null)

echo "$HANDOFF_OUTPUT" | grep -q "Handoff complete" \
  && pass "handoff completes successfully on clean project" \
  || fail "handoff did not complete on clean project"

[ -f "$TMP_PROJECT/session-handoff.md" ] \
  && pass "handoff generated session-handoff.md" \
  || fail "handoff missing session-handoff.md"

grep -q "What Was Accomplished" "$TMP_PROJECT/session-handoff.md" \
  && pass "session-handoff.md has expected sections" \
  || fail "session-handoff.md missing expected sections"

grep -q "Session $( date +%Y-%m-%d )" "$TMP_PROJECT/PROGRESS.md" \
  && pass "handoff appended to PROGRESS.md" \
  || fail "handoff did not update PROGRESS.md"

# Run handoff on a project with failing build — expect BLOCKED
TMP_BLOCKED=$(mktemp -d)
git -C "$TMP_BLOCKED" init -q
git -C "$TMP_BLOCKED" config user.email "test@test.com"
git -C "$TMP_BLOCKED" config user.name "Test"

echo '{"name":"fail","scripts":{"build":"exit 1","test":"exit 1"}}' > "$TMP_BLOCKED/package.json"
git -C "$TMP_BLOCKED" add . && git -C "$TMP_BLOCKED" commit -q -m "initial"

cd "$TMP_BLOCKED"
BLOCKED_OUTPUT=$(bash "$REPO_ROOT/skills/harness-handoff/scripts/harness-handoff.sh" 2>/dev/null || true)

echo "$BLOCKED_OUTPUT" | grep -q "HANDOFF BLOCKED\|FAILED" \
  && pass "handoff blocks on failing build/tests" \
  || fail "handoff did not block on failing project"

rm -rf "$TMP_PROJECT" "$TMP_BLOCKED"

echo ""
echo "harness-handoff: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
