# Dockerfile for Legit - ARM64 Version
FROM arm64v8/ubuntu:22.04

# Avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Add a label for identification
LABEL org.opencontainers.image.title="Legit"
LABEL org.opencontainers.image.description="Lightweight Engine Generating Instant Typesets"
LABEL org.opencontainers.image.architecture="arm64"

# Install basic system utilities and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    git \
    ca-certificates \
    fontconfig \
    ghostscript \
    imagemagick \
    librsvg2-bin \
    fonts-liberation \
    fonts-liberation2 \
    fonts-cmu \
    unzip \
    zip \
    make \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install TeX Live with necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    texlive-base \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-latex-recommended \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-xetex \
    texlive-science \
    texlive-plain-generic \
    texlive-bibtex-extra \
    lmodern \
    && rm -rf /var/lib/apt/lists/*

# Install Pandoc
RUN curl -L https://github.com/jgm/pandoc/releases/download/3.1.9/pandoc-3.1.9-1-arm64.deb -o pandoc.deb \
    && dpkg -i pandoc.deb \
    && rm pandoc.deb

# Install Inkscape for SVG conversion
RUN apt-get update \
    && apt-get install -y --no-install-recommends inkscape \
    && rm -rf /var/lib/apt/lists/*

# Install additional LaTeX packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    texlive-latex-extra \
    texlive-science \
    texlive-publishers \
    && rm -rf /var/lib/apt/lists/*

# Verify LaTeX packages are available
RUN echo "Verifying LaTeX packages..." \
    && kpsewhich mathtools.sty \
    && kpsewhich physics.sty \
    && kpsewhich algorithm2e.sty \
    && kpsewhich adjustbox.sty \
    && kpsewhich collectbox.sty \
    && kpsewhich xkeyval.sty \
    && kpsewhich pdflscape.sty \
    && kpsewhich threeparttable.sty \
    || echo "Some packages might be missing, but continuing anyway"

# Create workspace directory
WORKDIR /workspace

# Copy scripts from the repository
COPY scripts/ /workspace/scripts/
COPY templates/ /workspace/templates/
COPY tests/ /workspace/tests/

# Make scripts executable
RUN chmod +x /workspace/scripts/*.sh /workspace/tests/*.sh

# Set PATH to include our scripts
ENV PATH="/workspace/scripts:${PATH}"

# Default command
CMD ["/bin/bash"]

