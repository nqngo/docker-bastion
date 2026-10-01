#!/usr/bin/env bash
# Test 1: Host Key Algorithm (Ed25519-only)
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [ -z "${TEST_PORT:-}" ]; then
    exec "$SCRIPT_DIR/test_bastion.sh" "${1:-bastion:test}" "$(basename "$0")"
fi

echo "==> [TEST] Verifying Host Key algorithms..."
KEYS_OUTPUT=$(ssh-keyscan -p "$TEST_PORT" 127.0.0.1 2>/dev/null)
if echo "$KEYS_OUTPUT" | grep -q "ssh-ed25519" && ! echo "$KEYS_OUTPUT" | grep -qE "(ssh-rsa|ecdsa-sha2)"; then
    echo "  [PASS] Only ssh-ed25519 host key is presented."
else
    echo "  [FAIL] Unexpected host key algorithms detected: $KEYS_OUTPUT"
    exit 1
fi
