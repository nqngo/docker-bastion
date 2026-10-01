#!/usr/bin/env bash
# Shared helpers and environment setup for bastion test suite

set -euo pipefail

export TEST_PORT="${TEST_PORT:-22222}"
export CONTAINER_NAME="${CONTAINER_NAME:-bastion-test-$(date +%s)-$RANDOM}"
export TMP_DIR="${TMP_DIR:-$(mktemp -d /tmp/bastion_test.XXXXXX)}"
export CLIENT_KEY="${CLIENT_KEY:-$TMP_DIR/client/id_ed25519}"
export SSH_OPTS="-F /dev/null -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
export SSH_CMD="ssh $SSH_OPTS -i $CLIENT_KEY -p $TEST_PORT bastion@127.0.0.1"

setup_test_environment() {
    local image_name="${1:-bastion:test}"

    # 1. Build test image if not present
    if ! docker image inspect "$image_name" >/dev/null 2>&1; then
        echo "==> Image '$image_name' not found locally. Building..."
        docker build -t "$image_name" .
    fi

    # 2. Generate client test key pair
    if [ ! -f "$CLIENT_KEY" ]; then
        mkdir -p "$(dirname "$CLIENT_KEY")"
        ssh-keygen -q -t ed25519 -N "" -f "$CLIENT_KEY"
    fi

    # 3. Launch container with test key injected via REMOTE_SSH_URL
    echo "==> Launching bastion container ($CONTAINER_NAME) on port $TEST_PORT..."
    docker run -d \
      --name "$CONTAINER_NAME" \
      -p "$TEST_PORT:22" \
      -v "${CLIENT_KEY}.pub:/tmp/test_authorized_keys:ro" \
      -e REMOTE_SSH_URL="file:///tmp/test_authorized_keys" \
      "$image_name" >/dev/null

    # 4. Wait for SSH port to be open
    echo "==> Waiting for SSH service to become ready..."
    local ready=0
    for i in {1..30}; do
        if ssh-keyscan -p "$TEST_PORT" 127.0.0.1 >/dev/null 2>&1; then
            ready=1
            break
        fi
        sleep 1
    done

    if [ "$ready" -ne 1 ]; then
        echo "ERROR: Bastion failed to start within 30 seconds."
        docker logs "$CONTAINER_NAME"
        exit 1
    fi
}

cleanup_test_environment() {
    echo "==> Cleaning up test container and temporary files..."
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
    rm -rf "$TMP_DIR"
    if [ -n "${SSH_AGENT_PID:-}" ]; then
        eval $(ssh-agent -k) >/dev/null 2>&1 || true
    fi
}
