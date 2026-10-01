#!/usr/bin/env bash
# Test 2: SFTP Subsystem End-to-End Upload, Download & Integrity
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [ -z "${TEST_PORT:-}" ]; then
    exec "$SCRIPT_DIR/test_bastion.sh" "${1:-bastion:test}" "$(basename "$0")"
fi

echo "==> [TEST] Testing SFTP upload and download integrity..."
PAYLOAD_IN="$TMP_DIR/sftp_payload.bin"
PAYLOAD_OUT="$TMP_DIR/sftp_downloaded.bin"

dd if=/dev/urandom of="$PAYLOAD_IN" bs=1024 count=64 status=none
ORIGINAL_HASH=$(sha256sum "$PAYLOAD_IN" | awk '{print $1}')

sftp $SSH_OPTS -P "$TEST_PORT" -i "$CLIENT_KEY" -b - bastion@127.0.0.1 << EOF >/dev/null
put $PAYLOAD_IN remote_test.bin
get remote_test.bin $PAYLOAD_OUT
rm remote_test.bin
quit
EOF

DOWNLOADED_HASH=$(sha256sum "$PAYLOAD_OUT" | awk '{print $1}')
if [ "$ORIGINAL_HASH" = "$DOWNLOADED_HASH" ]; then
    echo "  [PASS] SFTP upload and download matched SHA256 ($ORIGINAL_HASH)."
else
    echo "  [FAIL] SFTP checksum mismatch: $ORIGINAL_HASH != $DOWNLOADED_HASH"
    exit 1
fi
