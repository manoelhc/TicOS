# Contributing to TicOS

Thank you for your interest in contributing to TicOS! This document provides guidelines for contributing to the project.

## How to Contribute

### Reporting Issues

Before creating an issue:
1. Check existing issues to avoid duplicates
2. Gather relevant information (logs, system details)
3. Provide clear steps to reproduce the problem

When creating an issue, include:
- TicOS version or commit hash
- Raspberry Pi model
- Description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Relevant log files

### Suggesting Enhancements

Enhancement suggestions are welcome! Please:
1. Check if the feature has been requested already
2. Clearly describe the use case
3. Explain how it benefits TicOS users
4. Consider implementation complexity

### Pull Requests

We welcome pull requests! Here's how:

1. **Fork the repository**
   ```bash
   git clone https://github.com/manoelhc/TicOS.git
   cd TicOS
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow existing code style
   - Test your changes thoroughly
   - Update documentation if needed
   - Add comments for complex logic

4. **Test the build**
   ```bash
   packer validate packer.pkr.hcl
   packer fmt packer.pkr.hcl
   shellcheck scripts/*.sh setup.sh
   ```

5. **Commit your changes**
   ```bash
   git commit -m "Add feature: description"
   ```
   
   Use clear, descriptive commit messages:
   - Use present tense ("Add feature" not "Added feature")
   - Be specific about what changed
   - Reference issues if applicable (#123)

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Open a Pull Request**
   - Describe what the PR does
   - Link related issues
   - Explain testing performed
   - Include before/after screenshots if applicable

## Development Guidelines

### Code Style

#### Shell Scripts
- Use `#!/bin/bash` shebang
- Use 4 spaces for indentation
- Use meaningful variable names in UPPER_SNAKE_CASE for constants
- Add comments for complex logic
- Use `set -e` for scripts that should fail fast
- Always quote variables: `"$variable"`

#### Packer Configuration
- Follow HCL formatting guidelines
- Use `packer fmt` before committing
- Add comments for non-obvious configurations
- Group related provisioners together

#### Documentation
- Use clear, concise language
- Include code examples where helpful
- Keep line length reasonable (80-120 characters)
- Update README.md if adding new features

### Testing

Before submitting a PR:
1. **Validate syntax**:
   ```bash
   packer validate packer.pkr.hcl
   bash -n scripts/*.sh
   ```

2. **Check formatting**:
   ```bash
   packer fmt -check packer.pkr.hcl
   shellcheck scripts/*.sh setup.sh
   ```

3. **Test the build** (if possible):
   ```bash
   packer build packer.pkr.hcl
   ```

4. **Test on actual hardware** (if possible):
   - Flash to SD card
   - Boot on Raspberry Pi 5
   - Test network detection
   - Test Remmina functionality

### Documentation

Update documentation when:
- Adding new features
- Changing behavior
- Adding configuration options
- Fixing bugs that affect usage

Files to consider:
- `README.md` - Main documentation
- `QUICKSTART.md` - Quick start guide
- `TROUBLESHOOTING.md` - Troubleshooting info
- `SECURITY.md` - Security considerations
- `examples/README.md` - Example files

## Project Structure

```
TicOS/
├── packer.pkr.hcl          # Main Packer configuration
├── setup.sh                # Build environment setup
├── Makefile                # Build automation
├── scripts/                # Runtime scripts
│   ├── ticos-startup.sh    # Main startup logic
│   ├── network-check.sh    # Network detection
│   ├── xinitrc             # X11 configuration
│   ├── ticos.service       # Systemd service
│   └── remmina.pref        # Remmina preferences
├── examples/               # Example connection files
│   ├── example-rdp.remmina
│   ├── example-vnc.remmina
│   └── README.md
└── docs/                   # Documentation
    ├── README.md
    ├── QUICKSTART.md
    ├── TROUBLESHOOTING.md
    ├── SECURITY.md
    └── CONTRIBUTING.md
```

## Areas for Contribution

### High Priority
- Testing on different Raspberry Pi models
- Additional remote desktop protocol support
- Performance optimizations
- Boot time improvements
- Better error handling

### Documentation
- Translations to other languages
- Video tutorials
- More troubleshooting scenarios
- Deployment examples

### Features
- WiFi support with fallback
- Web-based configuration interface
- Multiple connection profiles
- Connection health monitoring
- Automatic reconnection

### Infrastructure
- CI/CD pipeline setup
- Automated testing
- Release automation
- Image hosting

## Code Review Process

All submissions require review:
1. Maintainers will review your PR
2. Address any feedback or questions
3. Once approved, it will be merged
4. Your contribution will be credited

## Community Guidelines

- Be respectful and constructive
- Help others learn and grow
- Welcome newcomers
- Focus on what's best for the project
- Follow the code of conduct

## Questions?

- Open an issue for questions
- Tag it with "question" label
- Check existing issues first
- Be specific about what you need help with

## License

By contributing to TicOS, you agree that your contributions will be licensed under the same license as the project.

## Recognition

Contributors will be:
- Listed in release notes
- Credited in commit messages
- Recognized in the project README
- Appreciated by the community!

Thank you for contributing to TicOS! 🎉
