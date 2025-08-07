#!/bin/bash
set -eo pipefail

# Initialize test environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEST_TEMP_DIR="${PROJECT_ROOT}/tests/tmp"

# Color constants for test output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Clean up test directory
cleanup() {
  if [ -d "${TEST_TEMP_DIR}" ]; then
    rm -rf "${TEST_TEMP_DIR}"
  fi
}

# Create fresh test temp directory
setup() {
  cleanup
  mkdir -p "${TEST_TEMP_DIR}"
}

# Run on exit
trap cleanup EXIT

# Initialize counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Run a test and track its success/failure
run_test() {
  local test_file="$1"
  local test_name="$(basename "${test_file}")"
  
  echo -e "${YELLOW}Running test: ${test_name}${NC}"
  
  if bash "${test_file}"; then
    echo -e "${GREEN}✓ Passed: ${test_name}${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "${RED}✗ Failed: ${test_name}${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
  
  TESTS_RUN=$((TESTS_RUN + 1))
  echo "--------------------------------"
}

# Main function
main() {
  echo "Legit Test Suite"
  echo "================================"
  
  setup
  
  # Explicit allowlist of test files for security
  local allowed_tests=(
    "convert_markdown_test.sh"
    "generate_all_formats_test.sh"
  )
  
  # Run only explicitly allowed test files
  for test_name in "${allowed_tests[@]}"; do
    test_file="${SCRIPT_DIR}/${test_name}"
    if [ -f "${test_file}" ]; then
      run_test "${test_file}"
    else
      echo -e "${YELLOW}Warning: Test file not found: ${test_name}${NC}"
    fi
  done
  
  # Print summary
  echo "================================"
  echo -e "${YELLOW}Tests Summary:${NC}"
  echo -e "Total: ${TESTS_RUN}"
  echo -e "${GREEN}Passed: ${TESTS_PASSED}${NC}"
  if [ ${TESTS_FAILED} -gt 0 ]; then
    echo -e "${RED}Failed: ${TESTS_FAILED}${NC}"
    exit 1
  else
    echo -e "Failed: ${TESTS_FAILED}"
    echo -e "${GREEN}All tests passed!${NC}"
  fi
}

main "$@"

