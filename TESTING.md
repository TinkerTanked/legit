# Testing Guide for Legit

This document outlines the testing infrastructure for the Legit markdown-to-PDF conversion system.

## Overview

The test suite validates key components of the Legit system:

- Conversion of markdown to PDF
- SVG image handling with Inkscape and fallback methods
- Multi-format template processing
- Command-line arguments and options
- Error handling and edge cases

## Running Tests Locally

To run the test suite locally:

```bash
# Run all tests
./tests/run-tests.sh

# Run a specific test
./tests/convert_markdown_test.sh
```

The test runner will report success or failure for each test and provide a summary at the end.

## Test Structure

The test suite consists of:

1. **Unit Tests**: Test individual functions and components
    - `convert_markdown_test.sh`: Tests the markdown-to-PDF conversion script
    - `generate_all_formats_test.sh`: Tests multi-format PDF generation

2. **Temporary Test Environment**: Creates isolated test files to ensure tests don't interfere with actual content

3. **Validation Tests**: Verify that:
    - SVG files convert correctly to PDF
    - Error handling works as expected
    - PDF output is valid and complete

## Continuous Integration

Tests run automatically as part of the GitHub Actions workflow:

1. On every push to the `main` branch
2. On every pull request to the `main` branch
3. When manually triggered from the GitHub Actions tab

The CI pipeline:
- Sets up a consistent environment with all dependencies
- Runs the full test suite
- Fails the build if any tests fail
- Creates artifacts of test outputs for debugging

## Adding New Tests

To add a new test:

1. Create a new test file in the `tests/` directory with a name ending in `_test.sh`
2. Make the test file executable: `chmod +x tests/your_new_test.sh`
3. Follow the pattern in existing tests:
   - Set up necessary test files and environment
   - Define individual test functions
   - Run the tests and return appropriate exit codes

Example structure for a new test file:

```bash
#!/bin/bash
set -eo pipefail

# Initialize test environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEST_TEMP_DIR="${PROJECT_ROOT}/tests/tmp"

# Create test files
setup_test_files() {
  # Create necessary test files here
}

# Test specific functionality
test_some_feature() {
  echo "Testing some feature..."
  # Your test code here
  return 0  # Return 0 for success, non-zero for failure
}

# Run all tests
run_tests() {
  setup_test_files
  test_some_feature
  return $?
}

# Execute tests
run_tests
```

## Troubleshooting Tests

If tests fail, check:

1. **Dependencies**: Ensure all required tools are installed (Pandoc, LaTeX, Inkscape)
2. **Script Permissions**: All test scripts should be executable
3. **Test Output**: Examine the temporary files in `tests/tmp/` (not cleaned up on failure)
4. **CI Artifacts**: In CI, download the test artifacts to examine outputs

