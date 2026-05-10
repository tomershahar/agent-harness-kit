#!/usr/bin/env bash
# init.sh — Verify the project builds cleanly before starting work.
# Run this after cloning or when resuming a session.
set -euo pipefail

echo "=== agent-harness-kit Init ==="
echo ""

echo "[1/3] Installing dependencies..."
npm install
echo ""

echo "[2/3] Running type checks..."
npx tsc --noEmit
echo ""

echo "[3/3] Building project..."
npm run build
echo ""

echo "=== Init complete. All checks passed. ==="
echo "Run 'npm run dev' to start the application."
