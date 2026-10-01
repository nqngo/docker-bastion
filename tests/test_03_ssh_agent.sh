#!/usr/bin/env bash
# Test 3: SSH Agent Forwarding (-A)
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [ -z "${TEST_PORT:-}" ]; then
    exec "$SCRIPT_DIR/test_bastion.sh" "${1:-bastion:test}" "$(basename "$0")"
fi

echo "==> [TEST] Testing SSH Agent Forwarding (-A)..."
eval $(ssh-agent -s) >/dev/null
trap 'eval $(ssh-agent -k) >/dev/null 2>&1 || true' EXIT

TARGET_KEY="$TMP_DIR/target_key"
ssh-keygen -q -t ed25519 -N "" -f "$TARGET_KEY"
ssh-add "$TARGET_KEY" 2>/dev/null
TARGET_FINGERPRINT=$(ssh-keygen -lf "$TARGET_KEY" | awk '{print $2}')

AGENT_OUTPUT=$($SSH_CMD -A 'test -S "$SSH_AUTH_SOCK" && ssh-add -l' 2>/dev/null || true)
if echo "$AGENT_OUTPUT" | grep -q "$TARGET_FINGERPRINT"; then
    echo "  [PASS] SSH Agent socket forwarded and verified via ssh-add -l."
else
    echo "  [FAIL] Forwarded SSH agent could not list target key: $AGENT_OUTPUT"
    exit 1
fi
