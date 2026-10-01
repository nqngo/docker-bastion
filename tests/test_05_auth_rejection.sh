#!/usr/bin/env bash
# Test 5: Password Authentication Rejection
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [ -z "${TEST_PORT:-}" ]; then
    exec "$SCRIPT_DIR/test_bastion.sh" "${1:-bastion:test}" "$(basename "$0")"
fi

echo "==> [TEST] Verifying Password Authentication is rejected..."
PW_OUTPUT=$(ssh $SSH_OPTS -o PreferredAuthentications=password -o PubkeyAuthentication=no -p "$TEST_PORT" bastion@127.0.0.1 2>&1 || true)
if echo "$PW_OUTPUT" | grep -q "Permission denied (publickey)"; then
    echo "  [PASS] Password authentication correctly refused."
else
    echo "  [FAIL] Password authentication was not rejected as expected: $PW_OUTPUT"
    exit 1
fi
