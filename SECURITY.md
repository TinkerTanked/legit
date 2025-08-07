# Security Policy

## Overview

The Legit project takes security seriously and has implemented multiple layers of security controls to protect against common vulnerabilities.

## Security Features Implemented

### Container Security
- **Non-root execution**: Containers run with restricted user permissions (UID 1001)
- **Minimal attack surface**: Base images are pinned to specific digests for reproducible builds
- **Dependency verification**: External downloads include checksum verification

### Input Validation & Sanitization
- **Command injection prevention**: All user inputs are sanitized before processing
- **Path traversal protection**: File paths are validated and restricted to safe directories
- **Input length limits**: User inputs are limited to prevent buffer overflow attacks
- **Character filtering**: Dangerous characters are stripped from user inputs

### Supply Chain Security
- **Checksum verification**: All external downloads (Pandoc, yq) verify checksums
- **Pinned dependencies**: Docker base images use specific digests, not floating tags
- **Minimal privileges**: File permissions are set granularly (755 for executables, 644 for data)

### Logging & Monitoring
- **Sensitive data filtering**: Logs automatically redact passwords, keys, and tokens
- **Structured logging**: All operations are logged with timestamps and severity levels
- **Error handling**: Failed operations are logged without exposing sensitive information

### File System Security
- **Restricted permissions**: Temporary directories use 700 permissions (owner-only access)
- **Explicit allow-lists**: Only predefined test files can be executed
- **Safe file operations**: File operations include validation and bounds checking

## Reporting Security Issues

If you discover a security vulnerability, please report it privately to:

**Email**: [security@tinkertank.rocks](mailto:security@tinkertank.rocks)

Please include:
1. Description of the vulnerability
2. Steps to reproduce the issue
3. Potential impact assessment
4. Any suggested fixes or mitigations

## Security Response Process

1. **Acknowledgment**: We'll acknowledge receipt within 24 hours
2. **Investigation**: We'll investigate and assess the severity within 72 hours  
3. **Fix Development**: We'll develop and test a fix
4. **Disclosure**: We'll coordinate disclosure with the reporter
5. **Release**: We'll release the fix and security advisory

## Secure Usage Guidelines

### For Users
- Always use the latest version of Legit
- Validate all markdown input files before processing
- Use restricted file permissions in your content directories
- Monitor logs for unusual activity

### For Contributors
- Run security tests before submitting PRs
- Follow secure coding practices
- Use input validation for all user-provided data
- Avoid hardcoding secrets or credentials

## Security Testing

The project includes automated security checks:
- **Static analysis**: Code is scanned for common vulnerabilities
- **Dependency scanning**: All dependencies are checked for known vulnerabilities  
- **Container scanning**: Docker images are scanned for security issues
- **Input validation testing**: Malicious inputs are tested against all entry points

## Supported Versions

Security updates are provided for:
- Latest stable release
- Previous stable release (for 90 days after new release)

## Security-First Design Principles

1. **Defense in depth**: Multiple security controls at different layers
2. **Principle of least privilege**: Minimal permissions required for operation
3. **Fail-safe defaults**: Secure configurations by default
4. **Input validation**: All inputs are validated and sanitized
5. **Logging and monitoring**: Comprehensive security event logging

---

Last updated: 2025-01-07
