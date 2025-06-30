<div align="center">
  <h1>
    <span style="display:block;margin:0.5em">
      <span style="font-size:2em;color:#4A86E8">L</span><span style="font-size:1.7em">EGIT</span>
    </span>
  </h1>
  
  <h3><em><strong>L</strong>ightweight <strong>E</strong>ngine <strong>G</strong>enerating <strong>I</strong>nstant <strong>T</strong>ypesets</em></h3>
  
  <p><em>Transform markdown into beautiful PDFs with multiple templates</em></p>
  
  <pre style="line-height:1.2;font-size:0.9em;max-width:480px;margin:1em auto;font-family:monospace,monospace">
██╗     ███████╗ ██████╗ ██╗████████╗
██║     ██╔════╝██╔════╝ ██║╚══██╔══╝
██║     █████╗  ██║  ███╗██║   ██║   
██║     ██╔══╝  ██║   ██║██║   ██║   
███████╗███████╗╚██████╔╝██║   ██║   
╚══════╝╚══════╝ ╚═════╝ ╚═╝   ╚═╝   
  </pre>
  
  <div>
    <img src="https://img.shields.io/badge/Markdown-to-brightgreen.svg" alt="Markdown">
    <img src="https://img.shields.io/badge/PDF-Conversion-blue.svg" alt="PDF">
    <img src="https://img.shields.io/badge/Multiple-Templates-orange.svg" alt="Templates">
  </div>
</div>

---

This repository contains a powerful document conversion system that automatically transforms markdown files into professionally formatted PDF documents using multiple customizable templates. The system integrates with GitHub Actions to provide continuous delivery of beautifully formatted scientific papers, academic documents, and technical reports — all from a single markdown source.

## Overview

Legit makes it easy to write content once in markdown format and automatically generate multiple professionally formatted PDFs using different templates. With a single markdown source, you can produce documents that follow traditional scientific paper styling, academic formatting, or custom templates of your own design. The system:

1. Watches for changes to markdown files in your repository
2. Converts them to PDF using Pandoc and LaTeX with scientific and academic formatting
3. Uploads the generated PDFs to your S3 bucket
4. Maintains both versioned copies and "latest" references
5. Supports both portrait and landscape images with proper formatting

## Multi-Format Capability

**🎯 The core power of Legit**: Transform a single markdown file into multiple professional PDF formats, each optimized for different academic contexts.

### Format Showcase

See our [format showcase document](content/format-showcase.md) that demonstrates the dramatic differences between templates. From one markdown source, Legit generates:

1. **Scientific Format** (2-column, 73KB): Traditional journal-style layout with tight spacing, perfect for conference papers and research articles
2. **Academic Format** (single-column, 150KB): Clean, readable layout ideal for dissertations, theses, and detailed technical reports

### Key Differences

| Feature | Scientific Format | Academic Format |
| --- | --- | --- |
| **Layout** | **Two-column layout** for space efficiency | **Single-column layout** for readability |
| **Margins** | Tight 2cm margins with 1cm column separation | Generous 1.2-inch margins |
| **Font** | Latin Modern (optimized for equations) | Times New Roman (traditional academic) |
| **Line Spacing** | Compact 1.1x spacing | Comfortable 1.5x spacing |
| **Code Highlighting** | Syntax-highlighted code blocks | Syntax-highlighted code blocks |
| **Math Support** | Full LaTeX math with physics package | Full LaTeX math with physics package |
| **Best For** | Journal submissions, conference papers | Dissertations, technical reports |
| **Page Efficiency** | ~50% more content per page | Optimized for longer documents |

### Real-World Example

Our showcase paper demonstrates:
- **Complex mathematical equations** with proper LaTeX rendering
- **Syntax-highlighted Python code** showing neural network architectures
- **Professional scientific content** with abstracts, citations, and references
- **Identical markdown source** producing distinctly different PDF outputs

Both formats support the same advanced features:
- Mathematical equations and scientific notation
- Code blocks with syntax highlighting
- Tables, figures, and cross-references
- Citation management and bibliographies
- Custom styling and formatting options
## Repository Structure

The repository is organized into a modular structure for better maintainability:

```
legit/
├── .github/workflows/    # GitHub Actions workflow files
├── configs/              # Configuration files for the workflow
│   └── workflow-config.yml    # Main configuration settings
├── content/              # Markdown papers to be converted
│   ├── example-paper.md  # Example scientific paper template
│   ├── demo-paper.md     # Climate science ML demo paper
│   └── format-showcase.md # Comprehensive format showcase document
├── figures/              # Image files for papers
│   ├── portrait images   # Images in portrait orientation
│   └── landscape images  # Images in landscape orientation
├── scripts/              # Utility scripts for the workflow
│   ├── convert-markdown.sh    # Markdown to PDF conversion script
│   └── generate-all-formats.sh # Generate PDFs in all available formats
├── templates/            # LaTeX templates for styling
│   ├── scientific-paper.tex   # Scientific paper LaTeX template
│   └── academic-paper.tex     # Academic paper LaTeX template
└── README.md             # This documentation file
```

## Local Development

To develop and test the PDF generation locally, you'll need to install several dependencies. This section provides installation instructions for different operating systems.

### Required Dependencies

- **Pandoc**: Document conversion system that transforms markdown to LaTeX/PDF
- **LaTeX**: Typesetting system required for PDF generation
- **Additional LaTeX packages**: For scientific formatting, math equations, and images
- **Inkscape** (or alternative): For converting SVG images to PDF format for LaTeX inclusion
- **Git**: Version control for repository management
### Installation by Operating System

#### macOS

1. **Pandoc**:
   ```bash
   brew install pandoc
   ```

2. **LaTeX**:
   ```bash
   # Full installation (>4GB)
   brew install --cask mactex
   
   # OR Minimal installation (~100MB)
   brew install --cask basictex
   
   # If using BasicTeX, you'll need to install additional packages:
   sudo tlmgr update --self
   sudo tlmgr install collection-latex collection-fontsrecommended collection-pictures collection-bibtexextra
   sudo tlmgr install latexmk fncychap titlesec tabulary varwidth framed wrapfig capt-of needspace xcolor
   ```

3. **Inkscape and Additional Tools**:
   ```bash
   brew install inkscape librsvg python imagemagick
   ```

#### Ubuntu/Debian Linux

1. **Pandoc**:
   ```bash
   sudo apt update
   sudo apt install pandoc
   ```

2. **LaTeX**:
   ```bash
   # Full installation (>4GB)
   sudo apt install texlive-full
   
   # OR Minimal installation (~500MB)
   sudo apt install texlive texlive-latex-extra texlive-fonts-recommended texlive-science
   ```

3. **Inkscape and Additional Tools**:
   ```bash
   sudo apt install inkscape librsvg2-bin python3 imagemagick
   ```

#### Windows

1. **Pandoc**:
   - Download the installer from [pandoc.org/installing.html](https://pandoc.org/installing.html)
   - Run the installer and follow the prompts

2. **LaTeX** (MiKTeX):
   - Download from [miktex.org/download](https://miktex.org/download)
   - Run the installer
   - During setup, choose to automatically install required packages

3. **Additional Tools**:
   - Install [Git for Windows](https://git-scm.com/download/win)
   - Install [Python](https://www.python.org/downloads/windows/)
   - Install [Inkscape](https://inkscape.org/release/) for SVG to PDF conversion
   - Optionally install [ImageMagick](https://imagemagick.org/script/download.php#windows)

### Testing Locally

Once dependencies are installed, you can test the conversion process:

1. Clone the repository:
   ```bash
   git clone git@github.com:TinkerTanked/legit.git
   cd legit
   ```

2. Make the conversion script executable (Unix-based systems):
   ```bash
   chmod +x scripts/convert-markdown.sh
   ```

3. Run a test conversion on the showcase paper:
   ```bash
   # Generate both formats at once (recommended)
   ./scripts/generate-all-formats.sh content/format-showcase.md
   
   # Or generate individual formats
   ./scripts/convert-markdown.sh --format=scientific --input=content/format-showcase.md
   ./scripts/convert-markdown.sh --format=academic --input=content/format-showcase.md
   ```

   On Windows (using Git Bash or WSL):
   ```bash
   # Generate both formats at once (recommended)
   bash scripts/generate-all-formats.sh content/format-showcase.md
   
   # Or generate individual formats
   bash scripts/convert-markdown.sh --format=scientific --input=content/format-showcase.md
   bash scripts/convert-markdown.sh --format=academic --input=content/format-showcase.md
   ```

4. Verify the PDF was generated in the `pdfs` directory

### Troubleshooting Local Development

#### Common Issues

1. **Missing LaTeX packages**:
   - Error messages will indicate missing packages
   - On macOS/Linux: `sudo tlmgr install <package-name>`
   - On Windows with MiKTeX: The package manager should install them automatically

2. **Pandoc conversion errors**:
   - Ensure your markdown syntax is compatible with Pandoc
   - Check LaTeX template for compatibility issues
   - Run pandoc with the `--verbose` flag for detailed error messages

3. **Image conversion issues**:
   - Ensure images are in supported formats (PNG, JPEG, SVG)
   - For SVG support, ensure that librsvg is installed
   - Verify file paths are correct relative to the markdown file

3. **SVG conversion issues**:
   - For proper SVG handling, Inkscape is the preferred tool
   - If Inkscape is not available, the system will fall back to librsvg2-bin (rsvg-convert)
   - SVG files with complex elements (gradients, filters, etc.) may require Inkscape for proper conversion
   - If you see LaTeX errors with `\endcsname` related to images, check that your SVG files are being properly converted to PDF
   - You can manually pre-convert SVG files to PDF with: `inkscape --export-filename=output.pdf input.svg`

4. **Line ending issues**:
   - Scripts may fail with "bad interpreter" errors on Unix systems if they have Windows line endings
   - Fix with: `tr -d '\r' < scripts/convert-markdown.sh > scripts/fixed.sh && mv scripts/fixed.sh scripts/convert-markdown.sh && chmod +x scripts/convert-markdown.sh`

## How It Works

The GitHub workflow (`markdown-to-pdf.yml`) performs the following steps:

1. **Trigger**: Activates when markdown files are pushed to the main branch or when manually triggered
2. **Configuration Loading**: Reads settings from `configs/workflow-config.yml`
4. **Environment Setup**: Uses a Docker container with pre-installed Pandoc, LaTeX, and other required dependencies to speed up execution time
5. **Template Application**: Applies the appropriate LaTeX template (scientific or academic) from the templates directory
6. **PDF Generation**: Converts the markdown to properly formatted PDFs in all configured formats using Pandoc
7. **S3 Upload**: Securely uploads the PDFs to your configured S3 bucket
8. **Versioning**: Creates both timestamped versions and a "latest" version for easy reference

### Scientific Paper Features

The generated PDFs include proper formatting for:

- Title, authors, and affiliations
- Abstract
- Section headings and numbering
- Mathematical equations
- Tables and figures with captions
- Citations and references
- Page numbers and headers
- Both portrait and landscape images with proper orientation
- Custom styling through configurable templates

## Configuration Requirements

### GitHub Repository Secrets

You need to configure the following secrets in your GitHub repository:

- `AWS_ACCESS_KEY_ID`: Your AWS access key with S3 permissions
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
- `AWS_REGION`: The AWS region where your S3 bucket is located (e.g., `us-east-1`)
- `S3_BUCKET`: The name of your S3 bucket where PDFs will be stored

### S3 Bucket Configuration

Your S3 bucket should be configured with:

1. Appropriate permissions for the AWS credentials used
2. Public read access if you want the PDFs to be publicly accessible
3. CORS configuration if needed for web access

Example bucket policy for public read access (optional):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
    }
  ]
}
```

## How to Use

### Creating Markdown Files

1. Place your markdown files in the `content/` directory
2. Create your scientific paper with YAML frontmatter, for example:

```markdown
---
title: "Your Paper Title"
author: "Author Name"
date: "2023-09-22"
abstract: "This is the abstract of your paper."
keywords: ["keyword1", "keyword2"]
bibliography: references.bib
---

## Introduction

Your content here...
```

See the `content/example-paper.md` file in this repository for a complete example with advanced features like equations, tables, and citations.

You can also specify which format you prefer in the YAML frontmatter:

```markdown
---
title: "Your Paper Title"
author: "Author Name"
date: "2023-09-22"
abstract: "This is the abstract of your paper."
format: "academic"  # or "scientific"
---
```

### Adding Images

1. Place your images in the `figures/` directory
2. Reference images in your markdown with proper paths:

```markdown
![Caption for portrait image](../figures/ion_trap_setup.svg){width=80%}

![Caption for landscape image](../figures/entanglement_results.svg){width=100% orientation=landscape}
```

#### Portrait vs. Landscape Images

- **Portrait images**: Standard image inclusion, no special attributes needed
- **Landscape images**: Add the `orientation=landscape` attribute to properly rotate the image

Example:
```markdown
![Landscape Chart](../figures/landscape_chart.svg){width=100% orientation=landscape}
```

### Configuration

You can customize the workflow by editing the `configs/workflow-config.yml` file:

```yaml
# Main configuration controls which files to process
input:
  content_dir: "content"        # Directory containing markdown files
  default_files: ["example-paper.md"]  # Default files to process if none specified

# Output settings
output:
  pdf_dir: "pdfs"               # Directory for generated PDFs
  s3:
    prefix: "papers"            # S3 prefix/folder for uploaded PDFs
    make_public: true           # Whether to make PDFs publicly accessible

# Template settings
templates:
  dir: "templates"              # Directory containing LaTeX templates
  scientific: "scientific-paper.tex"  # Scientific paper template file
  academic: "academic-paper.tex"      # Academic paper template file

# Format settings - enable/disable specific formats
formats:
  scientific: true              # Enable scientific format generation
  academic: true                # Enable academic format generation
```

### Triggering the Workflow

The workflow runs automatically when:

1. You push changes to the `main` branch that include modifications to:
   - Markdown (`.md`) files in the `content/` directory or its subdirectories
   - Any files in the `templates/` directory (LaTeX templates)
   - Any files in the `configs/` directory (workflow configuration files)

2. You manually trigger the workflow from the GitHub Actions tab

Note that changes to other files (such as scripts, images, or documentation) will NOT automatically trigger the workflow. This is controlled by the `paths` configuration in the GitHub workflow file.

To manually trigger the workflow:
1. Go to the "Actions" tab in your GitHub repository
2. Select the "Markdown to PDF" workflow
3. Click "Run workflow"
4. Optionally specify a particular markdown file to process
5. Click the "Run workflow" button

When manually triggering the workflow, you can also choose to regenerate all markdown files in the content directory by selecting the "Regenerate all markdown files" option.

### Accessing Generated PDFs

Once the workflow completes successfully, your PDFs will be available at:

**Scientific Format:**
- Latest version: `https://YOUR-BUCKET-NAME.s3.amazonaws.com/papers/scientific/FILENAME-latest.pdf`
- Versioned: `https://YOUR-BUCKET-NAME.s3.amazonaws.com/papers/scientific/FILENAME-TIMESTAMP.pdf`

**Academic Format:**
- Latest version: `https://YOUR-BUCKET-NAME.s3.amazonaws.com/papers/academic/FILENAME-latest.pdf`
- Versioned: `https://YOUR-BUCKET-NAME.s3.amazonaws.com/papers/academic/FILENAME-TIMESTAMP.pdf`

An index of all available PDFs is also generated and available at:
`https://YOUR-BUCKET-NAME.s3.amazonaws.com/papers/index.html`

## Customization

### Template Customization

To customize the PDF formatting:

1. Modify the LaTeX templates:
   - For scientific format: `templates/scientific-paper.tex`
   - For academic format: `templates/academic-paper.tex`
2. Adjust Pandoc options in `scripts/convert-markdown.sh` or `configs/workflow-config.yml`
3. For advanced users, create custom templates with different styling options

The LaTeX template supports customization of:
- Font styles and sizes
- Margin settings
- Header and footer styles
- Citation styles
- Figure and table formatting

### Image Handling

You can control image appearance with markdown attributes:

```markdown
![Caption](../figures/image.png){width=70% height=auto}
![Landscape Image](../figures/data.svg){width=100% orientation=landscape}
![Small Right-aligned Image](../figures/icon.png){width=30% .right}
```

Supported attributes:
- `width` and `height`: Control image dimensions (percentage or absolute)
- `orientation`: Set to `landscape` for landscape images
- `.left`, `.right`, `.center`: Control image alignment
### SVG Image Handling

SVG images require special handling when included in LaTeX documents. The workflow supports several methods:

1. **Automatic conversion**: SVG files are automatically converted to PDF during the workflow
2. **Manual conversion**: You can pre-convert SVG files to PDF using Inkscape
3. **Fallback conversion**: If Inkscape is not available, the system uses librsvg2-bin (rsvg-convert)

Common parameters for SVG conversion:
```bash
# Using Inkscape (best quality)
inkscape --export-filename=output.pdf input.svg

# Using rsvg-convert (fallback)
rsvg-convert -f pdf -o output.pdf input.svg
```

When referencing SVG images in markdown, use the SVG filename - the conversion will happen automatically:

```markdown
![Caption](../figures/image.svg){width=80%}
```

## Workflow Details

### Environment Setup

The workflow:

1. Uses cached LaTeX and Pandoc installations when possible
2. Installs only required LaTeX packages for faster setup
3. Provides detailed logs for debugging
4. Uses a modular script architecture for maintainability

### Performance Optimizations

To ensure fast and efficient workflow execution:

1. **Docker Container**: The workflow uses a pre-built Docker container with Pandoc, LaTeX, and all required dependencies already installed, eliminating installation time
2. **Dependency Caching**: When not using containers, the workflow caches dependencies to speed up subsequent runs
3. **Optimized LaTeX Installation**: Only installs the specific packages needed rather than the full distribution
4. **Parallel Processing**: Where possible, operations are parallelized for faster execution

### Conversion Process

The conversion process:

1. Parses the YAML frontmatter from markdown files
2. Applies the appropriate LaTeX template
3. Processes figures with proper orientation handling
4. Compiles citations if a bibliography is provided
5. Generates a clean, professionally formatted PDF

## Troubleshooting

If the workflow fails:

1. Check the GitHub Actions logs for specific error messages
2. Ensure your AWS credentials are correct and have appropriate permissions
3. Verify your markdown syntax is compatible with Pandoc
4. Check that your LaTeX equations are properly formatted
5. Validate image paths and ensure images exist in the figures directory
6. Check the configuration file for correct settings

## Testing

Legit includes a comprehensive test suite to ensure the system works correctly. The test suite validates:

- Markdown to PDF conversion
- SVG image handling
- Multi-format template processing
- Command-line functionality

### Running Tests

To run the test suite locally:

```bash
# Run all tests
./tests/run-tests.sh
```

Tests run automatically on every pull request and push to the main branch via GitHub Actions.

For detailed information about the testing system, see [TESTING.md](TESTING.md).

## Docker Support

Legit provides a Docker container for consistent development and testing environments, especially useful for ARM64 architectures.

### Using the Docker Container

A helper script is provided to build and run the Docker container:

```bash
# Build and run the container
./build-and-run.sh --run

# Just build the container
./build-and-run.sh

# Show all options
./build-and-run.sh --help
```

### Pushing to AWS ECR

You can push the built image to Amazon ECR for use in CI/CD pipelines:

```bash
./build-and-run.sh --push --aws-region=us-east-1 --aws-account=123456789012 --ecr-repo=legit
```

### GitHub Actions Integration

The repository includes a GitHub workflow that automatically builds and pushes the ARM64 container to ECR on:
- Pushes to the main branch that modify the Dockerfile
- Manual triggers using the "Actions" tab in GitHub
- Weekly builds every Sunday

To use this workflow, configure the following GitHub secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AWS_ACCOUNT_ID`

## Advanced Usage
### Using Different Format Templates

You can specify which format to use for your document in several ways:

1. **In the YAML frontmatter**:
   ```markdown
   ---
   title: "Document Title"
   format: "academic"  # or "scientific"
   template: "custom-template.tex"  # optional, overrides default for the format
   ---
   ```

2. **Command line when running scripts**:
   ```bash
   ./scripts/convert-markdown.sh --input=content/paper.md --format=academic
   ```

3. **Create additional custom templates**:
   - Add new template files to the `templates/` directory
   - Reference them directly:

```markdown
---
title: "Document Title"
template: "alternative-template.tex"
---
---
```

### Working with References

For proper citations:

1. Create a BibTeX file (e.g., `references.bib`) with your citations
2. Reference it in your markdown frontmatter
3. Cite in the paper using `[@citation-key]` format

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions to improve Legit are welcome! Please feel free to submit pull requests with:
- Template improvements
- Additional features
- Documentation enhancements
- Bug fixes

