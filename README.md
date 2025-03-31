# Legit - Markdown to Scientific Paper PDF Generator

This repository contains a GitHub Actions workflow that automatically converts markdown files into professionally formatted scientific paper PDFs and uploads them to an Amazon S3 bucket for storage and distribution.

## Overview

Legit makes it easy to write scientific papers in markdown format and automatically get beautifully formatted PDFs that follow traditional scientific paper styling. The system:

1. Watches for changes to markdown files in your repository
2. Converts them to PDF using Pandoc and LaTeX with scientific formatting
3. Uploads the generated PDFs to your S3 bucket
4. Maintains both versioned copies and "latest" references

## How It Works

The GitHub workflow (`markdown-to-pdf.yml`) performs the following steps:

1. **Trigger**: Activates when markdown files are pushed to the main branch or when manually triggered
2. **Environment Setup**: Installs Pandoc, LaTeX, and other required dependencies
3. **Template Application**: Applies a scientific paper LaTeX template to your markdown content
4. **PDF Generation**: Converts the markdown to a properly formatted PDF using Pandoc
5. **S3 Upload**: Securely uploads the PDF to your configured S3 bucket
6. **Versioning**: Creates both timestamped versions and a "latest" version for easy reference

### Scientific Paper Features

The generated PDFs include proper formatting for:

- Title, authors, and affiliations
- Abstract
- Section headings and numbering
- Mathematical equations
- Tables and figures with captions
- Citations and references
- Page numbers and headers

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

Create your scientific paper as a markdown file with YAML frontmatter, for example:

```markdown
---
title: "Your Paper Title"
author: "Author Name"
date: "2023-09-22"
abstract: "This is the abstract of your paper."
---

## Introduction

Your content here...
```

See the `example-paper.md` file in this repository for a complete example.

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

- Latest version: `https://YOUR-BUCKET-NAME.s3.amazonaws.com/papers/FILENAME-latest.pdf`
- Versioned: `https://YOUR-BUCKET-NAME.s3.amazonaws.com/papers/FILENAME-TIMESTAMP.pdf`

An index of all available PDFs is also generated and available at:
`https://YOUR-BUCKET-NAME.s3.amazonaws.com/papers/index.html`

## Customization

To customize the PDF formatting:
1. Modify the LaTeX template in the workflow YAML file
2. Adjust Pandoc options in the workflow file
3. Add custom CSS if using HTML as an intermediary step

## Troubleshooting

If the workflow fails:
1. Check the GitHub Actions logs for specific error messages
2. Ensure your AWS credentials are correct and have appropriate permissions
3. Verify your markdown syntax is compatible with Pandoc
4. Check that your LaTeX equations are properly formatted

## License

This project is licensed under the MIT License - see the LICENSE file for details.

