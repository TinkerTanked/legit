#!/bin/bash
# Simple conversion script to convert markdown to PDF
# Focuses on robustness and minimal functionality for testing purposes

# Exit on error
set -e

# Print commands before executing
set -x

# ===================================
# VARIABLES AND DEFAULTS
# ===================================
# Default input file (example paper)
INPUT_FILE="content/example-paper.md"
# Default output directory
OUTPUT_DIR="pdfs"
# Default LaTeX template file
TEMPLATE_FILE="templates/scientific-paper.tex"
# Default PDF engine
PDF_ENGINE="xelatex"

# ===================================
# COMMAND LINE ARGUMENTS
# ===================================
# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --input=*) INPUT_FILE="${1#*=}" ;;
        --output-dir=*) OUTPUT_DIR="${1#*=}" ;;
        --template=*) TEMPLATE_FILE="${1#*=}" ;;
        --engine=*) PDF_ENGINE="${1#*=}" ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# ===================================
# VALIDATION
# ===================================
# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file $INPUT_FILE does not exist."
    exit 1
fi

# Check if template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Error: Template file $TEMPLATE_FILE does not exist."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# ===================================
# EXTRACT METADATA
# ===================================
# Extract title from YAML frontmatter (if exists), otherwise use filename
TITLE=$(grep -m 1 "^title:" "$INPUT_FILE" | sed 's/^title: \+//' | tr -d '"' || echo "Untitled")

# Extract author from YAML frontmatter (if exists)
AUTHOR=$(grep -m 1 "^author:" "$INPUT_FILE" | sed 's/^author: \+//' | tr -d '"' || echo "Anonymous")

# ===================================
# DETERMINE OUTPUT FILENAME
# ===================================
# Get the filename without path and extension
FILENAME=$(basename "$INPUT_FILE" .md)
OUTPUT_FILE="$OUTPUT_DIR/$FILENAME.pdf"

echo "Converting $INPUT_FILE to $OUTPUT_FILE"

# ===================================
# PERFORM CONVERSION
# ===================================
# Run pandoc to convert markdown to PDF using the specified template
pandoc -s "$INPUT_FILE" \
    --pdf-engine="$PDF_ENGINE" \
    --template="$TEMPLATE_FILE" \
    -V title="$TITLE" \
    -V author="$AUTHOR" \
    -V date="$(date +"%B %d, %Y")" \
    --standalone \
    --wrap=none \
    -o "$OUTPUT_FILE"

# ===================================
# VERIFY RESULT
# ===================================
# Check if the PDF was created successfully
if [ -f "$OUTPUT_FILE" ]; then
    echo "Success: PDF generated at $OUTPUT_FILE"
    # Output file size
    ls -lh "$OUTPUT_FILE"
    exit 0
else
    echo "Error: Failed to generate PDF"
    exit 1
fi

