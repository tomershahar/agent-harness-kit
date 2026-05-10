#!/usr/bin/env bash
# init.sh — Verify the project builds cleanly before starting work.
# Run this after cloning or when resuming a session.
set -euo pipefail

echo "=== agent-harness-kit Init ==="
echo ""

echo "[1/2] Verifying bash scripts have valid syntax..."
bash -n skills/harness-init/scripts/harness-init.sh
bash -n skills/harness-audit/scripts/harness-audit.sh
bash -n skills/harness-handoff/scripts/harness-handoff.sh
echo ""

echo "[2/2] Verifying SKILL.md files exist..."
test -f skills/harness-init/SKILL.md
test -f skills/harness-audit/SKILL.md
test -f skills/harness-handoff/SKILL.md
echo ""

echo "=== Init complete. All checks passed. ==="
echo "Use: bash skills/harness-init/scripts/harness-init.sh (from any project root)"
