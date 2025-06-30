#!/usr/bin/env bash

# ==============================================================================
# generate-all-formats.sh
# 
# Generates PDFs in both scientific and academic formats for all markdown files 
# in the content directory, or for specific files passed as arguments.
#
# Usage:
#   ./scripts/generate-all-formats.sh                      # Process all markdown files in content/
#   ./scripts/generate-all-formats.sh file1.md file2.md    # Process specific files
#   ./scripts/generate-all-formats.sh --help               # Show help message
#
# Options:
#   --output-dir=DIR    Set custom output directory (default: pdfs/)
#   --content-dir=DIR   Set custom content directory (default: content/)
#   --quiet             Suppress non-error output
#   --verbose           Show detailed processing information
#   --help              Show this help message
#
# Author: AI Assistant
# Date: $(date +%Y-%m-%d)
# ==============================================================================

set -eo pipefail

# ANSI color codes for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default configuration
CONTENT_DIR="content"
OUTPUT_DIR="pdfs"
QUIET=false
VERBOSE=false
SPECIFIC_FILES=()
FORMATS=("scientific" "academic" "technical-report" "preprint" "thesis")

# Templates for each format
SCIENTIFIC_TEMPLATE="templates/scientific-paper.tex"
ACADEMIC_TEMPLATE="templates/academic-paper.tex"
TECHNICAL_REPORT_TEMPLATE="templates/technical-report.tex"
PREPRINT_TEMPLATE="templates/preprint.tex"
THESIS_TEMPLATE="templates/thesis.tex"

# ===== Helper Functions =====

function log_info {
    if [[ "$QUIET" == false ]]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
}

function log_success {
    if [[ "$QUIET" == false ]]; then
        echo -e "${GREEN}[SUCCESS]${NC} $1"
    fi
}

function log_warning {
    if [[ "$QUIET" == false ]]; then
        echo -e "${YELLOW}[WARNING]${NC} $1"
    fi
}

function log_error {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

function log_verbose {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

function show_help {
    cat << EOF
generate-all-formats.sh - Generate PDFs in multiple formats

Description:
    This script processes markdown files and generates PDFs in both scientific
    and academic formats using Pandoc and LaTeX templates.

Usage:
    ./scripts/generate-all-formats.sh                      # Process all markdown files in content/
    ./scripts/generate-all-formats.sh file1.md file2.md    # Process specific files
    ./scripts/generate-all-formats.sh --help               # Show this help message

Options:
    --output-dir=DIR    Set custom output directory (default: pdfs/)
    --content-dir=DIR   Set custom content directory (default: content/)
    --quiet             Suppress non-error output
    --verbose           Show detailed processing information
    --format=FORMAT     Generate only specific format (scientific or academic)
                        Can be specified multiple times for multiple formats
    --help              Show this help message

Examples:
    # Generate PDFs for all markdown files in the content directory
    ./scripts/generate-all-formats.sh
    
    # Generate PDFs for specific files
    ./scripts/generate-all-formats.sh content/paper1.md content/paper2.md
    
    # Use a different output directory
    ./scripts/generate-all-formats.sh --output-dir=output
    
    # Generate only academic format
    ./scripts/generate-all-formats.sh --format=academic
    
    # Generate only scientific format with verbose output
    ./scripts/generate-all-formats.sh --format=scientific --verbose

Requirements:
    - Pandoc (for markdown to LaTeX conversion)
    - LaTeX/XeLaTeX (for PDF generation)
    - Appropriate LaTeX template files

Exit Codes:
    0    Success
    1    General error
    2    Missing dependency
    3    Invalid argument
    4    No markdown files found
    5    Error during PDF generation
EOF
    exit 0
}

# ===== Check Dependencies =====

function check_dependencies {
    log_verbose "Checking for required dependencies..."
    
    # Check for pandoc
    if ! command -v pandoc &> /dev/null; then
        log_error "Pandoc is not installed. Please install Pandoc first."
        log_info "Installation instructions: https://pandoc.org/installing.html"
        exit 2
    fi
    
    # Check for pdflatex or xelatex
    if ! command -v pdflatex &> /dev/null && ! command -v xelatex &> /dev/null; then
        log_error "Neither pdflatex nor xelatex found. Please install LaTeX first."
        log_info "Installation instructions: https://www.latex-project.org/get/"
        exit 2
    fi
    
    # Check template files
    if [[ ! -f "$SCIENTIFIC_TEMPLATE" ]]; then
        log_error "Scientific template file not found: $SCIENTIFIC_TEMPLATE"
        exit 1
    fi
    
    if [[ ! -f "$ACADEMIC_TEMPLATE" ]]; then
        log_error "Academic template file not found: $ACADEMIC_TEMPLATE"
        exit 1
    fi
    
    log_verbose "All dependencies are satisfied."
}

# ===== Parse Arguments =====

function parse_arguments {
    local custom_formats=()
    
    # Parse arguments
    for arg in "$@"; do
        case "$arg" in
            --help)
                show_help
                ;;
            --output-dir=*)
                OUTPUT_DIR="${arg#*=}"
                ;;
            --content-dir=*)
                CONTENT_DIR="${arg#*=}"
                ;;
            --quiet)
                QUIET=true
                ;;
            --verbose)
                VERBOSE=true
                ;;
            --format=*)
                format="${arg#*=}"
                if [[ "$format" != "scientific" && "$format" != "academic" ]]; then
                    log_error "Invalid format: $format (must be 'scientific' or 'academic')"
                    exit 3
                fi
                custom_formats+=("$format")
                ;;
            --*)
                log_error "Unknown option: $arg"
                show_help
                exit 3
                ;;
            *)
                # Check if the file exists
                if [[ -f "$arg" ]]; then
                    SPECIFIC_FILES+=("$arg")
                elif [[ -f "$CONTENT_DIR/$arg" ]]; then
                    SPECIFIC_FILES+=("$CONTENT_DIR/$arg")
                else
                    log_warning "File not found: $arg - skipping"
                fi
                ;;
        esac
    done
    
    # If custom formats were specified, use only those
    if [[ ${#custom_formats[@]} -gt 0 ]]; then
        FORMATS=("${custom_formats[@]}")
    fi
    
    # Create output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"
    for format in "${FORMATS[@]}"; do
        mkdir -p "$OUTPUT_DIR/$format"
    done
    
    # Verbose output
    log_verbose "Configuration:"
    log_verbose "  Content directory: $CONTENT_DIR"
    log_verbose "  Output directory: $OUTPUT_DIR"
    log_verbose "  Formats: ${FORMATS[*]}"
    log_verbose "  Quiet mode: $QUIET"
    log_verbose "  Verbose mode: $VERBOSE"
    if [[ ${#SPECIFIC_FILES[@]} -gt 0 ]]; then
        log_verbose "  Specific files: ${SPECIFIC_FILES[*]}"
    fi
}

# ===== Find Markdown Files =====

function find_markdown_files {
    local md_files=()
    
    # If specific files were provided, use those
    if [[ ${#SPECIFIC_FILES[@]} -gt 0 ]]; then
        md_files=("${SPECIFIC_FILES[@]}")
    else
        # Otherwise find all markdown files in the content directory
        log_info "Finding markdown files in $CONTENT_DIR..."
        
        # Check if the content directory exists
        if [[ ! -d "$CONTENT_DIR" ]]; then
            log_error "Content directory not found: $CONTENT_DIR"
            exit 1
        fi
        
        # Find all markdown files
        while IFS= read -r -d '' file; do
            md_files+=("$file")
        done < <(find "$CONTENT_DIR" -type f -name "*.md" -print0)
        
        if [[ ${#md_files[@]} -eq 0 ]]; then
            log_error "No markdown files found in $CONTENT_DIR"
            exit 4
        fi
        
        log_info "Found ${#md_files[@]} markdown files"
    fi
    
    echo "${md_files[@]}"
}

# ===== Generate PDFs =====

function generate_pdf {
    local input_file="$1"
    local format="$2"
    local output_dir="$3"
    local template=""
    
    # Get the filename without directory and extension
    local filename=$(basename "$input_file" .md)
    local output_pdf="$output_dir/$format/$filename.pdf"
    
    # Choose the template based on the format
    case "$format" in
        "scientific")
            template="$SCIENTIFIC_TEMPLATE"
            ;;
        "academic")
            template="$ACADEMIC_TEMPLATE"
            ;;
        "technical-report")
            template="$TECHNICAL_REPORT_TEMPLATE"
            ;;
        "preprint")
            template="$PREPRINT_TEMPLATE"
            ;;
        "thesis")
            template="$THESIS_TEMPLATE"
            ;;
        *)
            log_error "Unknown format: $format"
            return 1
            ;;
    esac
    
    log_info "Generating $format PDF for $input_file..."
    
    # Extract metadata from markdown file
    local title=$(grep -m 1 "^title:" "$input_file" | sed 's/^title: *//' | sed 's/"//g')
    local author=$(grep -m 1 "^author:" "$input_file" | sed 's/^author: *//' | sed 's/"//g')
    local date=$(grep -m 1 "^date:" "$input_file" | sed 's/^date: *//' | sed 's/"//g')
    
    # Use defaults if metadata is not found
    title=${title:-"Untitled Document"}
    author=${author:-"Anonymous"}
    date=${date:-"$(date +"%B %d, %Y")"}
    
    log_verbose "  Title: $title"
    log_verbose "  Author: $author"
    log_verbose "  Date: $date"
    log_verbose "  Template: $template"
    log_verbose "  Output: $output_pdf"
    
    # Create the PDF
    if pandoc -s "$input_file" \
        --pdf-engine=xelatex \
        --template="$template" \
        -V title="$title" \
        -V author="$author" \
        -V date="$date" \
        -o "$output_pdf" 2>/tmp/pandoc_error.log; then
        
        log_success "Successfully generated $output_pdf"
        return 0
    else
        log_error "Failed to generate PDF for $input_file with $format format"
        log_error "Pandoc error: $(cat /tmp/pandoc_error.log)"
        return 5
    fi
}

# ===== Main Function =====

function main {
    log_info "Starting PDF generation in multiple formats..."
    
    # Check for dependencies
    check_dependencies
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Find markdown files
    IFS=' ' read -r -a md_files <<< "$(find_markdown_files)"
    
    # Count for summary
    local total_files=${#md_files[@]}
    local success_count=0
    local failure_count=0
    
    # Process each file
    for md_file in "${md_files[@]}"; do
        log_info "Processing file: $md_file"
        
        # Generate each format
        for format in "${FORMATS[@]}"; do
            if generate_pdf "$md_file" "$format" "$OUTPUT_DIR"; then
                ((success_count++))
            else
                ((failure_count++))
            fi
        done
    done
    
    # Display summary
    echo ""
    log_info "===== Generation Summary ====="
    log_info "Files processed: $total_files"
    log_info "Formats generated: ${FORMATS[*]}"
    log_info "Total PDFs attempted: $((total_files * ${#FORMATS[@]}))"
    log_success "Successfully generated: $success_count PDFs"
    
    if [[ $failure_count -gt 0 ]]; then
        log_error "Failed to generate: $failure_count PDFs"
        exit 5
    fi
    
    log_info "Output directory: $OUTPUT_DIR"
    log_success "All done! PDF generation complete."
}

# Run the main function with all arguments
main "$@"

