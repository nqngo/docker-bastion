#!/usr/bin/env bash
# Bastion Test Suite Runner
# Usage:
#   ./tests/test_bastion.sh [image_name] [optional_test_filter...]
#
# Examples:
#   ./tests/test_bastion.sh                      # Runs all tests on bastion:test
#   ./tests/test_bastion.sh bastion:latest       # Runs all tests on bastion:latest
#   ./tests/test_bastion.sh bastion:test sftp    # Runs only sftp test

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/helpers.sh"

IMAGE_NAME="${1:-bastion:test}"
shift || true

# Determine which test scripts to run
TEST_FILES=()
if [ "$#" -gt 0 ]; then
    for filter in "$@"; do
        for file in "$SCRIPT_DIR"/test_*.sh; do
            if [ "$(basename "$file")" != "test_bastion.sh" ] && [[ "$(basename "$file")" == *"$filter"* ]]; then
                TEST_FILES+=("$file")
            fi
        done
    done
else
    for file in "$SCRIPT_DIR"/test_*.sh; do
        if [ "$(basename "$file")" != "test_bastion.sh" ]; then
            TEST_FILES+=("$file")
        fi
    done
fi

if [ "${#TEST_FILES[@]}" -eq 0 ]; then
    echo "ERROR: No test files matched criteria."
    exit 1
fi

trap cleanup_test_environment EXIT

echo "=========================================="
echo " Starting Bastion Automated Test Suite"
echo " Image: $IMAGE_NAME"
echo " Total test cases: ${#TEST_FILES[@]}"
echo "=========================================="

setup_test_environment "$IMAGE_NAME"

PASSED=0
FAILED=0
FAILED_TESTS=()

for test_script in "${TEST_FILES[@]}"; do
    test_name=$(basename "$test_script")
    echo "------------------------------------------"
    echo "Running: $test_name"
    if bash "$test_script"; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
        FAILED_TESTS+=("$test_name")
        echo "  [FAIL] $test_name encountered errors."
    fi
done

echo "=========================================="
echo " Test Suite Summary"
echo " Passed: $PASSED / ${#TEST_FILES[@]}"
echo " Failed: $FAILED / ${#TEST_FILES[@]}"
if [ "$FAILED" -gt 0 ]; then
    echo " Failed tests: ${FAILED_TESTS[*]}"
    echo "=========================================="
    exit 1
fi
echo " ALL TESTS PASSED SUCCESSFULLY! "
echo "=========================================="
