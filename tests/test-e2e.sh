#!/usr/bin/env bash
# test-e2e.sh — Full workflow: init → onboard → audit → handoff on one project
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

pass() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

echo "--- e2e: full 4-skill workflow ---"

# ── Setup: a messy real-world repo (no tests, has manifest and src) ───────────

TMP=$(mktemp -d)
git -C "$TMP" init -q
git -C "$TMP" config user.email "test@test.com"
git -C "$TMP" config user.name "Test"

# Realistic messy state: has package.json but no test script, has src, no harness
cat > "$TMP/package.json" << 'EOF'
{"name":"acme-api","version":"1.0.0","scripts":{"start":"node src/index.js","build":"echo ok","test":"echo ok"}}
EOF
mkdir -p "$TMP/src"
cat > "$TMP/src/index.js" << 'EOF'
const express = require('express')
const app = express()
app.get('/', (req, res) => res.json({ ok: true }))
module.exports = app
EOF
echo "# Acme API" > "$TMP/README.md"
git -C "$TMP" add . && git -C "$TMP" commit -q -m "initial"

# ── Stage 1: harness-init ─────────────────────────────────────────────────────

echo ""
echo "[Stage 1] harness-init"

cd "$TMP"
printf "\n1\nclaude-code\n" | bash "$REPO_ROOT/skills/harness-init/scripts/harness-init.sh" > /dev/null 2>&1

[ -f "$TMP/AGENTS.md" ]          && pass "init: AGENTS.md created"          || fail "init: AGENTS.md missing"
[ -f "$TMP/ARCHITECTURE.md" ]    && pass "init: ARCHITECTURE.md created"    || fail "init: ARCHITECTURE.md missing"
[ -f "$TMP/feature_list.json" ]  && pass "init: feature_list.json created"  || fail "init: feature_list.json missing"
[ -f "$TMP/init.sh" ]            && pass "init: init.sh created"            || fail "init: init.sh missing"
[ -f "$TMP/PROGRESS.md" ]        && pass "init: PROGRESS.md created"        || fail "init: PROGRESS.md missing"

# acme-api name should appear in AGENTS.md
grep -q "acme-api\|acme" "$TMP/AGENTS.md" \
  && pass "init: project name in AGENTS.md" \
  || fail "init: project name missing from AGENTS.md"

# No unfilled tokens in generated files
for f in AGENTS.md ARCHITECTURE.md PROGRESS.md; do
  grep -qv "{{" "$TMP/$f" \
    && pass "init: $f has no unfilled tokens" \
    || fail "init: $f has unfilled tokens"
done

# ── Stage 2: harness-onboard ─────────────────────────────────────────────────

echo ""
echo "[Stage 2] harness-onboard"

cd "$TMP"
ONBOARD=$(bash "$REPO_ROOT/skills/harness-onboard/scripts/harness-onboard.sh" 2>/dev/null)

echo "$ONBOARD" | grep -q "acme-api\|acme" \
  && pass "onboard: shows project name" \
  || fail "onboard: missing project name"

echo "$ONBOARD" | grep -q "Run Commands\|init.sh" \
  && pass "onboard: shows how to start" \
  || fail "onboard: missing startup instructions"

echo "$ONBOARD" | grep -q "Hard constraints\|constraints\|HARNESS-GAP\|type checking\|broken" \
  && pass "onboard: shows constraints section" \
  || fail "onboard: missing constraints section"

# ── Stage 3: harness-audit ───────────────────────────────────────────────────

echo ""
echo "[Stage 3] harness-audit"

cd "$TMP"
AUDIT=$(bash "$REPO_ROOT/skills/harness-audit/scripts/harness-audit.sh" 2>/dev/null)

echo "$AUDIT" | grep -q "Harness Audit Report" \
  && pass "audit: report generated" \
  || fail "audit: report missing"

echo "$AUDIT" | grep -q "Instructions" \
  && pass "audit: scores Instructions" \
  || fail "audit: missing Instructions score"

# Has AGENTS.md so Instructions should score > 1
echo "$AUDIT" | grep -qE "Instructions.*[2-5]/5" \
  && pass "audit: Instructions scores above 1 (AGENTS.md found)" \
  || fail "audit: Instructions scored 1 despite AGENTS.md existing"

echo "$AUDIT" | grep -q "scoring-rubric\|rubric" \
  && pass "audit: rubric reference in output" \
  || fail "audit: missing rubric reference"

# ── Stage 4: harness-handoff ─────────────────────────────────────────────────

echo ""
echo "[Stage 4] harness-handoff"

# Add a decision commit and a blocker so handoff can extract them
git -C "$TMP" commit -q --allow-empty -m "decided: use express over fastify for ecosystem maturity"
echo "# TODO BLOCKED: waiting for DB credentials from infra team" >> "$TMP/AGENTS.md"
git -C "$TMP" add AGENTS.md && git -C "$TMP" commit -q -m "wip: note blocker"

cd "$TMP"
HANDOFF=$(bash "$REPO_ROOT/skills/harness-handoff/scripts/harness-handoff.sh" 2>/dev/null)

echo "$HANDOFF" | grep -q "Handoff complete" \
  && pass "handoff: completes successfully" \
  || fail "handoff: did not complete"

[ -f "$TMP/session-handoff.md" ] \
  && pass "handoff: session-handoff.md written" \
  || fail "handoff: session-handoff.md missing"

grep -qi "express\|decided\|fastify" "$TMP/session-handoff.md" \
  && pass "handoff: decision extracted from git commit" \
  || fail "handoff: decision not extracted"

grep -qi "BLOCKED\|waiting for DB\|infra" "$TMP/session-handoff.md" \
  && pass "handoff: BLOCKED marker extracted" \
  || fail "handoff: BLOCKED marker not extracted"

# ── Cleanup ───────────────────────────────────────────────────────────────────

rm -rf "$TMP"

echo ""
echo "e2e: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
