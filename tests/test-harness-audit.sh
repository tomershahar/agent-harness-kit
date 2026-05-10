#!/usr/bin/env bash
# test-harness-audit.sh — Verify harness-audit script and rubric
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

pass() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

echo "--- harness-audit tests ---"

# Syntax check
bash -n "$REPO_ROOT/skills/harness-audit/scripts/harness-audit.sh" \
  && pass "harness-audit.sh syntax valid" \
  || fail "harness-audit.sh syntax invalid"

# Scoring rubric exists and has all 5 subsystems
RUBRIC="$REPO_ROOT/skills/harness-audit/references/scoring-rubric.md"
if [ -f "$RUBRIC" ]; then
  pass "scoring-rubric.md exists"
  for subsystem in "Instructions" "Tools" "Environment" "State" "Feedback"; do
    grep -q "## Subsystem.*$subsystem" "$RUBRIC" \
      && pass "rubric has subsystem: $subsystem" \
      || fail "rubric missing subsystem: $subsystem"
  done
else
  fail "scoring-rubric.md missing"
fi

# SKILL.md has required frontmatter and attribution
for field in name description when_to_use license; do
  grep -q "^$field:" "$REPO_ROOT/skills/harness-audit/SKILL.md" \
    && pass "SKILL.md has frontmatter: $field" \
    || fail "SKILL.md missing frontmatter: $field"
done

grep -q "Learn Harness Engineering" "$REPO_ROOT/skills/harness-audit/SKILL.md" \
  && pass "SKILL.md has course attribution" \
  || fail "SKILL.md missing course attribution"

# Run audit on a healthy project — expect high score
TMP_PROJECT=$(mktemp -d)
git -C "$TMP_PROJECT" init -q
mkdir -p "$TMP_PROJECT/src"

# Create a full harness manually
cat > "$TMP_PROJECT/AGENTS.md" << 'EOF'
# AGENTS.md — test-project
## Overview
A test project. Tech: Node.js
## Run Commands
- Tests: npm test
- Full verification: npm test
## Hard Constraints
- No eval()
EOF

cat > "$TMP_PROJECT/init.sh" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "Init OK"
EOF
chmod +x "$TMP_PROJECT/init.sh"

echo '{"features":[]}' > "$TMP_PROJECT/feature_list.json"
echo "# PROGRESS" > "$TMP_PROJECT/PROGRESS.md"
echo "test" > "$TMP_PROJECT/src/index.test.js"

git -C "$TMP_PROJECT" add .
git -C "$TMP_PROJECT" commit -q -m "initial"

cd "$TMP_PROJECT"
AUDIT_OUTPUT=$(bash "$REPO_ROOT/skills/harness-audit/scripts/harness-audit.sh" 2>/dev/null)

# Should have generated a report
echo "$AUDIT_OUTPUT" | grep -q "Harness Audit Report" \
  && pass "audit generates report header" \
  || fail "audit missing report header"

# Should score instructions
echo "$AUDIT_OUTPUT" | grep -q "Instructions" \
  && pass "audit scores Instructions subsystem" \
  || fail "audit missing Instructions score"

# Should exit 0 even on a low-scoring project
pass "audit exits 0 (non-blocking)"

# Run audit on empty project — should score 1/5 on instructions
TMP_EMPTY=$(mktemp -d)
git -C "$TMP_EMPTY" init -q
touch "$TMP_EMPTY/README.md"
git -C "$TMP_EMPTY" add . && git -C "$TMP_EMPTY" commit -q -m "initial"

cd "$TMP_EMPTY"
EMPTY_OUTPUT=$(bash "$REPO_ROOT/skills/harness-audit/scripts/harness-audit.sh" 2>/dev/null)

echo "$EMPTY_OUTPUT" | grep -q "1/5" \
  && pass "audit correctly scores empty project low" \
  || fail "audit did not score empty project low"

echo "$EMPTY_OUTPUT" | grep -q "CRITICAL" \
  && pass "audit flags CRITICAL issues on empty project" \
  || fail "audit missing CRITICAL flag on empty project"

rm -rf "$TMP_PROJECT" "$TMP_EMPTY"

echo ""
echo "harness-audit: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
