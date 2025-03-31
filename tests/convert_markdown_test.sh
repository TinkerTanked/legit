#!/bin/bash
set -eo pipefail

# Initialize test environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEST_TEMP_DIR="${PROJECT_ROOT}/tests/tmp"
CONVERT_SCRIPT="${PROJECT_ROOT}/scripts/convert-markdown.sh"

# Source the script to test its functions (if possible)
# Note: This might not work if the script doesn't support being sourced
# In that case, we'll test the script as a whole
if [ -f "${CONVERT_SCRIPT}" ]; then
  # Try to source with a subshell to avoid affecting the current environment
  # This approach helps prevent the script from executing actions when sourced
  if (bash -c "source \"${CONVERT_SCRIPT}\" 2>/dev/null"); then
    # Only source if the previous test succeeded (some scripts cannot be sourced)
    source "${CONVERT_SCRIPT}" 2>/dev/null || true
  fi
fi

# Create temporary test files
setup_test_files() {
  # Create a simple markdown file for testing
  cat > "${TEST_TEMP_DIR}/test.md" << EOF
---
title: "Test Document"
author: "Test Author"
date: "2025-04-01"
abstract: "This is a test abstract."
---

# Introduction

This is a test document for testing the markdown to PDF conversion.

## Subsection

Here is a subsection with a math equation:

$$E = mc^2$$

And here's a simple table:

| Column 1 | Column 2 |
|----------|----------|
| Value 1  | Value 2  |
| Value 3  | Value 4  |
EOF

  # Create an SVG file for testing image conversion
  cat > "${TEST_TEMP_DIR}/test.svg" << EOF
<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="40" stroke="black" stroke-width="2" fill="red" />
</svg>
EOF

  # Create a minimal template for testing
  cat > "${TEST_TEMP_DIR}/test-template.tex" << EOF
\\documentclass{article}
\\usepackage{graphicx}
\\title{$title$}
\\author{$author$}
\\date{$date$}
\\begin{document}
\\maketitle
$body$
\\end{document}
EOF

  mkdir -p "${TEST_TEMP_DIR}/figures"
  cp "${TEST_TEMP_DIR}/test.svg" "${TEST_TEMP_DIR}/figures/"
}

# Test validation functions
test_validate_file_exists() {
  echo "Testing file validation..."
  
  # Test with existing file
  local existing_file="${TEST_TEMP_DIR}/test.md"
  if [ -f "${CONVERT_SCRIPT}" ]; then
    # Test the script directly if we can't source its functions
    "${CONVERT_SCRIPT}" --check-file="${existing_file}" 2>/dev/null && echo "Valid file check passed" || echo "Valid file check failed"
  else
    echo "Convert script not found!"
    return 1
  fi
  
  # Test with non-existing file
  local nonexistent_file="${TEST_TEMP_DIR}/does-not-exist.md"
  if [ -f "${CONVERT_SCRIPT}" ]; then
    # This should fail, so we invert the test
    ! "${CONVERT_SCRIPT}" --check-file="${nonexistent_file}" 2>/dev/null && echo "Invalid file check passed" || echo "Invalid file check failed"
  else
    echo "Convert script not found!"
    return 1
  fi
  
  return 0
}

# Test SVG to PDF conversion
test_svg_conversion() {
  echo "Testing SVG to PDF conversion..."
  
  # Create SVG file
  local svg_file="${TEST_TEMP_DIR}/test.svg"
  local pdf_output="${TEST_TEMP_DIR}/test.pdf"
  
  if command -v inkscape >/dev/null 2>&1; then
    echo "Testing conversion with Inkscape..."
    inkscape --export-filename="${pdf_output}" "${svg_file}" >/dev/null 2>&1
    
    if [ -f "${pdf_output}" ]; then
      echo "SVG to PDF conversion with Inkscape succeeded"
      rm -f "${pdf_output}"
    else
      echo "SVG to PDF conversion with Inkscape failed"
      return 1
    fi
  elif command -v rsvg-convert >/dev/null 2>&1; then
    echo "Testing conversion with rsvg-convert..."
    rsvg-convert -f pdf -o "${pdf_output}" "${svg_file}" >/dev/null 2>&1
    
    if [ -f "${pdf_output}" ]; then
      echo "SVG to PDF conversion with rsvg-convert succeeded"
      rm -f "${pdf_output}"
    else
      echo "SVG to PDF conversion with rsvg-convert failed"
      return 1
    fi
  else
    echo "Neither Inkscape nor rsvg-convert is available for testing SVG conversion"
    return 0  # Skip this test if tools are not available
  fi
  
  return 0
}

# Test basic PDF generation
test_pdf_generation() {
  echo "Testing basic PDF generation..."
  
  if command -v pandoc >/dev/null 2>&1; then
    local md_file="${TEST_TEMP_DIR}/test.md"
    local pdf_output="${TEST_TEMP_DIR}/test.pdf"
    local template="${TEST_TEMP_DIR}/test-template.tex"
    
    # Run the conversion script
    bash "${CONVERT_SCRIPT}" --input="${md_file}" --output="${pdf_output}" --template="${template}" --engine=xelatex >/dev/null 2>&1 || true
    
    # Check if PDF was created
    if [ -f "${pdf_output}" ]; then
      echo "PDF generation succeeded"
      # Check PDF size to ensure it's a valid PDF
      local pdf_size=$(stat -f%z "${pdf_output}" 2>/dev/null || stat -c%s "${pdf_output}" 2>/dev/null)
      if [ "${pdf_size}" -gt 1000 ]; then
        echo "PDF has a reasonable size (${pdf_size} bytes)"
      else
        echo "PDF is suspiciously small (${pdf_size} bytes)"
        return 1
      fi
    else
      echo "PDF generation failed"
      return 1
    fi
  else
    echo "Pandoc is not available for testing PDF generation"
    return 0  # Skip this test if tools are not available
  fi
  
  return 0
}

# Run all tests
run_tests() {
  setup_test_files
  
  # Run individual tests
  test_validate_file_exists && \
  test_svg_conversion && \
  test_pdf_generation
  
  local result=$?
  
  # Clean up
  #rm -rf "${TEST_TEMP_DIR}"
  
  return $result
}

# Execute tests
run_tests

