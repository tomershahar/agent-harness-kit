#!/usr/bin/env bash
# test-harness-init.sh — Verify harness-init script and templates
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

pass() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

echo "--- harness-init tests ---"

# Syntax check
bash -n "$REPO_ROOT/skills/harness-init/scripts/harness-init.sh" \
  && pass "harness-init.sh syntax valid" \
  || fail "harness-init.sh syntax invalid"

# All 5 templates exist
for tpl in AGENTS.md.tpl ARCHITECTURE.md.tpl feature_list.json.tpl init.sh.tpl PROGRESS.md.tpl; do
  if [ -f "$REPO_ROOT/skills/harness-init/templates/$tpl" ]; then
    pass "template exists: $tpl"
  else
    fail "template missing: $tpl"
  fi
done

# Templates contain expected tokens
grep -q "{{PROJECT_NAME}}" "$REPO_ROOT/skills/harness-init/templates/AGENTS.md.tpl" \
  && pass "AGENTS.md.tpl contains {{PROJECT_NAME}}" \
  || fail "AGENTS.md.tpl missing {{PROJECT_NAME}}"

grep -q "{{INSTALL_COMMAND}}" "$REPO_ROOT/skills/harness-init/templates/init.sh.tpl" \
  && pass "init.sh.tpl contains {{INSTALL_COMMAND}}" \
  || fail "init.sh.tpl missing {{INSTALL_COMMAND}}"

grep -q "set -euo pipefail" "$REPO_ROOT/skills/harness-init/templates/init.sh.tpl" \
  && pass "init.sh.tpl uses set -euo pipefail" \
  || fail "init.sh.tpl missing set -euo pipefail"

grep -q '"status_values"' "$REPO_ROOT/skills/harness-init/templates/feature_list.json.tpl" \
  && pass "feature_list.json.tpl has schema block" \
  || fail "feature_list.json.tpl missing schema block"

# SKILL.md has required frontmatter
for field in name description when_to_use license; do
  grep -q "^$field:" "$REPO_ROOT/skills/harness-init/SKILL.md" \
    && pass "SKILL.md has frontmatter: $field" \
    || fail "SKILL.md missing frontmatter: $field"
done

# SKILL.md has attribution footer
grep -q "Learn Harness Engineering" "$REPO_ROOT/skills/harness-init/SKILL.md" \
  && pass "SKILL.md has course attribution" \
  || fail "SKILL.md missing course attribution"

# Run harness-init on a temp project and verify output files
TMP_PROJECT=$(mktemp -d)
echo '{"name":"test-project","version":"1.0.0","scripts":{"start":"node index.js"}}' > "$TMP_PROJECT/package.json"
mkdir -p "$TMP_PROJECT/src"
echo 'console.log("hi")' > "$TMP_PROJECT/src/index.js"
git -C "$TMP_PROJECT" init -q
git -C "$TMP_PROJECT" config user.email "test@test.com"
git -C "$TMP_PROJECT" config user.name "Test"
git -C "$TMP_PROJECT" add .
git -C "$TMP_PROJECT" commit -q -m "initial"

cd "$TMP_PROJECT"
printf "\n1\nclaude-code\n" | bash "$REPO_ROOT/skills/harness-init/scripts/harness-init.sh" > /dev/null 2>&1

for f in AGENTS.md ARCHITECTURE.md feature_list.json init.sh PROGRESS.md; do
  if [ -f "$TMP_PROJECT/$f" ]; then
    pass "harness-init generated: $f"
  else
    fail "harness-init failed to generate: $f"
  fi
done

# Verify generated files have no unfilled tokens
for f in AGENTS.md ARCHITECTURE.md PROGRESS.md; do
  if grep -q "{{" "$TMP_PROJECT/$f" 2>/dev/null; then
    fail "$f has unfilled tokens"
  else
    pass "$f has no unfilled tokens"
  fi
done

rm -rf "$TMP_PROJECT"

# Readiness check — clean project (has tests + manifest + entry point) should have no HARNESS-GAP
TMP_READY=$(mktemp -d)
git -C "$TMP_READY" init -q
git -C "$TMP_READY" config user.email "test@test.com"
git -C "$TMP_READY" config user.name "Test"
echo '{"name":"ready-proj","scripts":{"test":"jest","build":"tsc"}}' > "$TMP_READY/package.json"
mkdir -p "$TMP_READY/src"
echo "test('ok', () => {})" > "$TMP_READY/src/app.test.js"
git -C "$TMP_READY" add . && git -C "$TMP_READY" commit -q -m "init"
cd "$TMP_READY"
printf "\n1\nclaude-code\n" | bash "$REPO_ROOT/skills/harness-init/scripts/harness-init.sh" > /dev/null 2>&1
grep -q "HARNESS-GAP" "$TMP_READY/AGENTS.md" \
  && fail "clean project should not have HARNESS-GAP in AGENTS.md" \
  || pass "clean project has no HARNESS-GAP warnings"

# Readiness check — messy project (no tests, no manifest, no entry point) should get HARNESS-GAP
TMP_MESSY=$(mktemp -d)
git -C "$TMP_MESSY" init -q
git -C "$TMP_MESSY" config user.email "test@test.com"
git -C "$TMP_MESSY" config user.name "Test"
echo "just a readme" > "$TMP_MESSY/README.md"
git -C "$TMP_MESSY" add . && git -C "$TMP_MESSY" commit -q -m "init"
cd "$TMP_MESSY"
printf "\n1\nclaude-code\n" | bash "$REPO_ROOT/skills/harness-init/scripts/harness-init.sh" > /dev/null 2>&1
grep -q "HARNESS-GAP" "$TMP_MESSY/AGENTS.md" \
  && pass "messy project has HARNESS-GAP warning in AGENTS.md" \
  || fail "messy project missing HARNESS-GAP warning"

rm -rf "$TMP_READY" "$TMP_MESSY"

grep -q "Copilot" "$REPO_ROOT/skills/harness-init/references/tool-compatibility.md" \
  && pass "tool-compatibility.md mentions GitHub Copilot" \
  || fail "tool-compatibility.md missing GitHub Copilot"

echo ""
echo "harness-init: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
