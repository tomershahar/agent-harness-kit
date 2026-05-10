#!/usr/bin/env bash
# init.sh — Verify the project builds cleanly before starting work.
# Run this after cloning or when resuming a session.
set -euo pipefail

echo "=== {{PROJECT_NAME}} Init ==="
echo ""

echo "[1/3] Installing dependencies..."
{{INSTALL_COMMAND}}
echo ""

echo "[2/3] Running type checks..."
{{TYPECHECK_COMMAND}}
echo ""

echo "[3/3] Building project..."
{{BUILD_COMMAND}}
echo ""

echo "=== Init complete. All checks passed. ==="
echo "Run '{{DEV_COMMAND}}' to start the application."
