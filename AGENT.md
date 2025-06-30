# AGENT.md - Legit Codebase Guide

## Build/Test Commands
- Run all tests: `./tests/run-tests.sh`
- Run specific test: `./tests/convert_markdown_test.sh` or `./tests/generate_all_formats_test.sh`
- Convert single file: `./scripts/convert-markdown.sh --format=scientific --input=content/example-paper.md`
- Generate all formats: `./scripts/generate-all-formats.sh content/example-paper.md`
- Build Docker container: `./build-and-run.sh`
- Run Docker container: `./build-and-run.sh --run`

## Architecture
- **Document Conversion System**: Markdown → PDF using Pandoc + LaTeX
- **5-Format Templates**: Scientific (2-column), Academic (single-column), Technical Report (corporate), Preprint (online), Thesis (formal)
- **Core Scripts**: `convert-markdown.sh` (single conversion), `generate-all-formats.sh` (multi-format)
- **Configuration**: YAML-based config in `configs/workflow-config.yml`
- **Templates**: LaTeX templates in `templates/` directory (5 professional formats)
- **SVG Processing**: Auto-converts SVG to PDF using Inkscape/rsvg-convert
- **CI/CD**: GitHub Actions for automated PDF generation and S3 upload

## Code Style & Conventions
- **Shell Scripts**: Use `#!/usr/bin/env bash` or `#!/usr/bin/env zsh`, strict error handling with `set -eo pipefail`
- **Logging**: Consistent logging with timestamps via `log_info()`, `log_warning()`, `log_error()` functions
- **Error Handling**: Always check command success, provide detailed error messages
- **Configuration**: Use YAML for configs, support both `yq` and fallback parsing
- **File Organization**: Modular structure with separate directories for scripts, templates, content
- **Dependencies**: Check for required tools (pandoc, xelatex, inkscape) before execution
- **Testing**: Shell-based tests with temporary directories and cleanup

## Template Development
- **Scientific Template**: Must use `twocolumn` document class for proper 2-column layout
- **Code Highlighting**: Include `fancyvrb`, `framed`, and define `Shaded`/`Highlighting` environments
- **Syntax Highlighting**: Define all Pandoc syntax highlighting commands (`\KeywordTok`, `\StringTok`, etc.)
- **Package Compatibility**: `longtable` incompatible with `twocolumn`, use `supertabular` instead
- **Color Definitions**: Define `shadecolor` after loading `xcolor` package
- **Math Support**: Include `amsmath`, `amssymb`, `mathtools`, `physics` packages for equations
- **Cross-Platform**: Handle SVG conversion with both Inkscape and rsvg-convert fallbacks

## Example Documents
- **format-showcase.md**: Comprehensive demo showing dramatic template differences (73KB vs 150KB PDFs)
- **demo-paper.md**: Climate science ML paper with tables, equations, professional structure
- **simple-test.md**: Basic test document for quick validation
