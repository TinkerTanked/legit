#!/usr/bin/env bash

# ============================================================================
# convert-markdown.sh
# ----------------------------------------------------------------------------
# A script to convert markdown files to PDF using Pandoc with configurable
# settings read from YAML configuration file.
#
# Features:
# - Modular design with separate functions for different responsibilities
# - Reads settings from configs/workflow-config.yml
# - Error handling and logging
# - Support for both portrait and landscape images
# - Customizable PDF output
# ============================================================================

set -e  # Exit immediately if a command exits with a non-zero status

# ============================================================================
# CONSTANTS
# ============================================================================
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_ROOT/configs/workflow-config.yml"
DEFAULT_TEMPLATE="$PROJECT_ROOT/templates/scientific-paper.tex"
LOG_FILE="$PROJECT_ROOT/conversion.log"

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Function: log
# Description: Logs a message with timestamp to both stdout and log file
# Arguments:
#   $1: Message level (INFO, WARNING, ERROR)
#   $2: Message to log
log() {
  local level="$1"
  local message="$2"
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] [$level] $message"
  echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Function: log_info
# Description: Logs an info message
# Arguments:
#   $1: Message to log
log_info() {
  log "INFO" "$1"
}

# Function: log_warning
# Description: Logs a warning message
# Arguments:
#   $1: Message to log
log_warning() {
  log "WARNING" "$1"
}

# Function: log_error
# Description: Logs an error message
# Arguments:
#   $1: Message to log
log_error() {
  log "ERROR" "$1"
}

# Function: check_requirements
# Description: Ensures all required dependencies are installed
check_requirements() {
  log_info "Checking requirements..."
  
  # Check if Pandoc is installed
  if ! command -v pandoc &> /dev/null; then
    log_error "Pandoc is not installed. Please install Pandoc before running this script."
    exit 1
  fi
  
  # Check if yq is installed (for YAML parsing)
  if ! command -v yq &> /dev/null; then
    log_warning "yq is not installed. Will use grep and sed for YAML parsing."
  fi
  
  # Check if LaTeX is installed
  if ! command -v xelatex &> /dev/null; then
    log_error "XeLaTeX is not installed. Please install TeX Live or similar distribution."
    exit 1
  fi
  
  # Check if config file exists
  if [ ! -f "$CONFIG_FILE" ]; then
    log_error "Configuration file not found: $CONFIG_FILE"
    exit 1
  fi
  
  log_info "All requirements satisfied"
}

# Function: get_config_value
# Description: Gets a value from the YAML configuration file
# Arguments:
#   $1: Key to retrieve
#   $2: Default value if key not found
# Returns: The value associated with the key
get_config_value() {
  local key="$1"
  local default="$2"
  local value
  
  # Try using yq if available
  if command -v yq &> /dev/null; then
    value=$(yq eval ".$key" "$CONFIG_FILE" 2>/dev/null)
    if [ "$value" = "null" ]; then
      value="$default"
    fi
  else
    # Fallback to grep and sed
    value=$(grep -oP "^$key:\\s*\\K.*" "$CONFIG_FILE" 2>/dev/null)
    if [ -z "$value" ]; then
      value="$default"
    fi
  fi
  
  echo "$value"
}

# Function: load_config
# Description: Loads configuration values from the YAML file
load_config() {
  log_info "Loading configuration from $CONFIG_FILE"
  
  # Input/Output settings
  INPUT_DIR=$(get_config_value "input_directory" "content")
  OUTPUT_DIR=$(get_config_value "output_directory" "pdfs")
  
  # Template settings
  TEMPLATE_FILE=$(get_config_value "template_file" "$DEFAULT_TEMPLATE")
  
  # Image settings
  IMAGES_DIR=$(get_config_value "images_directory" "figures")
  
  # PDF engine settings
  PDF_ENGINE=$(get_config_value "pdf_engine" "xelatex")
  
  # Create output directory if it doesn't exist
  mkdir -p "$PROJECT_ROOT/$OUTPUT_DIR"
  
  log_info "Configuration loaded successfully"
}

# Function: process_metadata
# Description: Extracts metadata from markdown file
# Arguments:
#   $1: Markdown file path
# Outputs:
#   Sets global variables for title, author, date, etc.
process_metadata() {
  local md_file="$1"
  log_info "Processing metadata from $md_file"
  
  # Default values
  TITLE=$(basename "$md_file" .md)
  AUTHOR=""
  DATE=$(date +"%B %d, %Y")
  
  # Extract YAML frontmatter if present
  if grep -q "^---" "$md_file"; then
    # Using sed to extract values between YAML frontmatter delimiters
    YAML_BLOCK=$(sed -n '/^---$/,/^---$/p' "$md_file")
    
    # Extract specific fields
    LOCAL_TITLE=$(echo "$YAML_BLOCK" | grep -oP "^title:\s*\K.*" | tr -d '"' | tr -d "'")
    LOCAL_AUTHOR=$(echo "$YAML_BLOCK" | grep -oP "^author:\s*\K.*" | tr -d '"' | tr -d "'")
    LOCAL_DATE=$(echo "$YAML_BLOCK" | grep -oP "^date:\s*\K.*" | tr -d '"' | tr -d "'")
    
    # Use extracted values if they exist
    if [ -n "$LOCAL_TITLE" ]; then
      TITLE="$LOCAL_TITLE"
    fi
    
    if [ -n "$LOCAL_AUTHOR" ]; then
      AUTHOR="$LOCAL_AUTHOR"
    fi
    
    if [ -n "$LOCAL_DATE" ]; then
      DATE="$LOCAL_DATE"
    fi
  fi
  
  log_info "Metadata: Title='$TITLE', Author='$AUTHOR', Date='$DATE'"
}

# Function: convert_markdown_to_pdf
# Description: Converts a markdown file to PDF using Pandoc
# Arguments:
#   $1: Markdown file path
convert_markdown_to_pdf() {
  local md_file="$1"
  local md_filename=$(basename "$md_file")
  local output_file="$PROJECT_ROOT/$OUTPUT_DIR/${md_filename%.md}.pdf"
  
  log_info "Converting $md_file to $output_file"
  
  # Process metadata from the markdown file
  process_metadata "$md_file"
  
  # Prepare additional pandoc options from config
  local extra_options=$(get_config_value "pandoc_extra_options" "")
  
  # Get reference-doc value if specified
  local reference_doc=$(get_config_value "reference_doc" "")
  local reference_option=""
  if [ -n "$reference_doc" ] && [ -f "$PROJECT_ROOT/$reference_doc" ]; then
    reference_option="--reference-doc=$PROJECT_ROOT/$reference_doc"
  fi
  
  # Execute pandoc conversion
  log_info "Running pandoc conversion..."
  
  # Attempt conversion with error handling
  if ! pandoc -s "$md_file" \
       --pdf-engine="$PDF_ENGINE" \
       --template="$TEMPLATE_FILE" \
       -V title="$TITLE" \
       -V author="$AUTHOR" \
       -V date="$DATE" \
       $reference_option \
       $extra_options \
       -o "$output_file"; then
    log_error "Pandoc conversion failed for $md_file"
    return 1
  fi
  
  log_info "Successfully converted $md_file to $output_file"
  return 0
}

# Function: process_files
# Description: Processes all markdown files according to configuration
process_files() {
  log_info "Starting file processing"
  
  # Get file pattern from config or use default
  local file_pattern=$(get_config_value "file_pattern" "*.md")
  
  # Get list of files to process
  local input_path="$PROJECT_ROOT/$INPUT_DIR"
  local files_to_process=("$input_path"/$file_pattern)
  
  # Check if any files match the pattern
  if [ ${#files_to_process[@]} -eq 0 ] || [ ! -f "${files_to_process[0]}" ]; then
    log_warning "No matching files found in $input_path with pattern $file_pattern"
    return 0
  fi
  
  local success_count=0
  local failure_count=0
  
  # Process each file
  for file in "${files_to_process[@]}"; do
    if [ -f "$file" ]; then
      if convert_markdown_to_pdf "$file"; then
        ((success_count++))
      else
        ((failure_count++))
      fi
    fi
  done
  
  log_info "Completed processing: $success_count files converted successfully, $failure_count failures"
}

# ============================================================================
# MAIN FUNCTION
# ============================================================================
main() {
  log_info "Starting markdown to PDF conversion script"
  
  # Initialize log file
  > "$LOG_FILE"
  
  # Check for required dependencies
  check_requirements
  
  # Load configuration
  load_config
  
  # Process markdown files
  process_files
  
  log_info "Script execution completed"
}

# Execute main function
main "$@"

