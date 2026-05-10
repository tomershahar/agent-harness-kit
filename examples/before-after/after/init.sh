#!/usr/bin/env bash
# init.sh — Verify the project runs cleanly before starting work.
set -euo pipefail

echo "=== example-app Init ==="
echo ""

echo "[1/2] Installing dependencies..."
npm install
echo ""

echo "[2/2] Verifying output..."
node src/index.js | grep 'Hello world'
echo ""

echo "=== Init complete. All checks passed. ==="
echo "Run 'node src/index.js' to start the application."
