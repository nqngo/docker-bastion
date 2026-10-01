#!/usr/bin/env bash
# Test 4: GPG Socket Forwarding & StreamLocalBindUnlink
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [ -z "${TEST_PORT:-}" ]; then
    exec "$SCRIPT_DIR/test_bastion.sh" "${1:-bastion:test}" "$(basename "$0")"
fi

echo "==> [TEST] Testing GPG Socket Forwarding & StreamLocalBindUnlink..."
MOCK_SOCK="$TMP_DIR/mock_gpg.sock"
python3 -c "import socket; s = socket.socket(socket.AF_UNIX); s.bind('$MOCK_SOCK')"

# Session 1: establish remote UNIX socket forward
$SSH_CMD -R "/home/bastion/.gnupg/S.gpg-agent:$MOCK_SOCK" \
    'test -S /home/bastion/.gnupg/S.gpg-agent' >/dev/null

# Session 2: reconnect immediately with identical -R (tests StreamLocalBindUnlink yes)
RECONNECT_OUTPUT=$($SSH_CMD -R "/home/bastion/.gnupg/S.gpg-agent:$MOCK_SOCK" \
    'test -S /home/bastion/.gnupg/S.gpg-agent && echo "REBOUND_SUCCESS"' 2>&1)

if echo "$RECONNECT_OUTPUT" | grep -q "REBOUND_SUCCESS" && ! echo "$RECONNECT_OUTPUT" | grep -q "remote port forwarding failed"; then
    echo "  [PASS] Stale socket cleanly unlinked and rebound without error."
else
    echo "  [FAIL] StreamLocalBindUnlink failure on reconnect: $RECONNECT_OUTPUT"
    exit 1
fi
