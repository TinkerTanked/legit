# Legit - Markdown to Scientific Paper PDF Generator

This repository contains a GitHub Actions workflow that automatically converts markdown files into professionally formatted scientific paper PDFs and uploads them to an Amazon S3 bucket for storage and distribution.

## Overview

Legit makes it easy to write scientific papers in markdown format and automatically get beautifully formatted PDFs that follow traditional scientific paper styling. The system:

1. Watches for changes to markdown files in your repository
2. Converts them to PDF using Pandoc and LaTeX with scientific formatting
3. Uploads the generated PDFs to your S3 bucket
4. Maintains both versioned copies and "latest" references
5. Supports both portrait and landscape images with proper formatting

## Multi-Format Capability

Legit supports generating papers in multiple formatting styles from the same markdown source:

1. **Scientific Format**: A traditional scientific paper layout with two-column formatting, ideal for conference submissions and journal articles
2. **Academic Format**: A clean, single-column layout suited for theses, dissertations, and academic reports

This multi-format capability allows you to:

* Maintain a single markdown source for your content
* Generate different formats for different submission requirements
* Quickly switch between styles without reformatting
* Customize each format independently through separate templates

You can generate both formats simultaneously using the provided `generate-all-formats.sh` script, or specify a particular format during manual conversion.

### Format Comparison

The following table compares the key differences between the scientific and academic formats:

| Feature | Scientific Format | Academic Format |
| --- | --- | --- |
| **Layout** | Two-column layout | Single-column layout |
| **Margins** | Narrower margins (1 inch) | Wider margins (1.5 inches) |
| **Font** | Computer Modern | Times New Roman |
| **Line Spacing** | Single-spaced | 1.5-spaced |
| **Section Numbering** | Numbered sections (1, 1.1, etc.) | Optionally numbered |
| **References** | IEEE-style | APA or Chicago style |
| **Header/Footer** | Compact with page numbers | More detailed with paper title |
| **Math Formatting** | Optimized for complex equations | Standard LaTeX math |
| **Figures** | Typically smaller, integrated in columns | Larger, centered on page |
| **Best For** | Conference papers, journal articles, research briefs | Dissertations, theses, detailed technical reports |
| **Page Limit** | Optimized for concise presentation | Better for longer documents |
| **Title Page** | Simple, integrated title | Separate, detailed title page |

The scientific format prioritizes space efficiency and concise presentation, making it ideal for publications with strict page limits. The academic format emphasizes readability and comprehensive presentation, better suited for longer documents where detailed explanation is valued over brevity.

Both formats support the same markdown features (equations, tables, citations, etc.), but render them differently to match the conventions of their respective document types.
## Repository Structure

The repository is organized into a modular structure for better maintainability:

```
legit/
├── .github/workflows/    # GitHub Actions workflow files
├── configs/              # Configuration files for the workflow
│   └── workflow-config.yml    # Main configuration settings
├── content/              # Markdown papers to be converted
│   └── example-paper.md  # Example scientific paper template
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

3. **Additional Tools**:
   ```bash
   brew install librsvg python imagemagick
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

3. **Additional Tools**:
   ```bash
   sudo apt install librsvg2-bin python3 imagemagick
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

3. Run a test conversion on the example paper:
   ```bash
   # For scientific format
   ./scripts/convert-markdown.sh --input=content/example-paper.md --output-dir=pdfs --template=templates/scientific-paper.tex --engine=xelatex
   
   # For academic format
   ./scripts/convert-markdown.sh --input=content/example-paper.md --output-dir=pdfs --template=templates/academic-paper.tex --engine=xelatex
   
   # Or generate both formats at once
   ./scripts/generate-all-formats.sh --input=content/example-paper.md
   ```

   On Windows (using Git Bash or WSL):
   ```bash
   # For scientific format
   bash scripts/convert-markdown.sh --input=content/example-paper.md --output-dir=pdfs --template=templates/scientific-paper.tex --engine=xelatex
   
   # For academic format
   bash scripts/convert-markdown.sh --input=content/example-paper.md --output-dir=pdfs --template=templates/academic-paper.tex --engine=xelatex
   
   # Or generate both formats at once
   bash scripts/generate-all-formats.sh --input=content/example-paper.md
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

1. You push changes to any markdown (`.md`) files to the main branch
2. You manually trigger the workflow from the GitHub Actions tab

To manually trigger the workflow:
1. Go to the "Actions" tab in your GitHub repository
2. Select the "Markdown to PDF" workflow
3. Click "Run workflow"
4. Optionally specify a particular markdown file to process
5. Click the "Run workflow" button

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

