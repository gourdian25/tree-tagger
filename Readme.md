# tt - Enhanced Smart Tree Tagger

## Introduction

**tt** (Tree Tagger) is a powerful command-line tool that enhances your project documentation by:

1. Generating a comprehensive directory tree structure
2. Automatically adding standardized file headers to all source code files
3. Creating backups before making any changes
4. Supporting a wide range of programming languages and file types

Perfect for developers who want to:

- Maintain consistent file headers across projects
- Quickly document project structure
- Automate project onboarding documentation
- Keep track of file modifications with built-in backup system

---

## Features

- **Smart Directory Tree Generation**:
  - Git-aware tree generation (automatically ignores gitignored files)
  - Customizable output file name
  - Excludes common directories (node_modules, dist, build, etc.)
  - Colorized output for better readability

- **Automatic File Header Management**:
  - Language-specific header formatting:
    - `// File: path` for C-style languages (Go, Rust, JavaScript, etc.)
    - `# File: path` for scripting languages (Python, Ruby, Bash, etc.)
    - `<!-- File: path -->` for HTML
    - `/* File: path */` for CSS
  - Preserves existing shebangs (#!/bin/bash)
  - Updates existing headers if they don't match current file path
  - Skips binary and large files automatically

- **Safety Features**:
  - Dry-run mode to preview changes
  - Automatic backups with timestamp
  - Configurable backup directory
  - File size limit to prevent processing large files
  - Skip list for binary and minified files

- **Cross-Platform Support**:
  - Works on Linux, macOS, and other Unix-like systems
  - Bash-compatible (version 4.0+)
  - No external dependencies beyond standard Unix tools

---

## Dependencies

tt requires the following standard tools which are typically pre-installed on Unix-like systems:

1. **tree**: For directory structure visualization
   - Install on Ubuntu/Debian:

     ```bash
     sudo apt install tree
     ```

   - Install on CentOS/RHEL:

     ```bash
     sudo yum install tree
     ```

   - Install on macOS:

     ```bash
     brew install tree
     ```

2. **git**: For gitignore awareness
   - Usually pre-installed on development systems

---

## Installation

### Quick Install (Bash/Zsh)

Run this one-line installer:

```bash
curl -fsSL https://raw.githubusercontent.com/gourdian25/tree-tagger/master/install.sh | sudo bash
```

### Manual Installation

1. Download the script:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/gourdian25/tree-tagger/master/tt.sh -o tt
   ```

2. Make it executable:

   ```bash
   chmod +x tt
   ```

3. Move to your PATH:

   ```bash
   sudo mv tt /usr/local/bin/
   ```

### Verification

Check that tt is installed correctly:

```bash
tt --help
```

---

## Usage

### Basic Usage

```bash
tt [OPTIONS] [OUTPUT_FILE]
```

### Options

| Option | Description |
|--------|-------------|
| `-d`, `--dry-run` | Preview changes without modifying files |
| `-v`, `--verbose` | Show detailed processing information |
| `-f`, `--force`   | Process files without backup confirmation |
| `-o`, `--output`  | Specify output tree file (default: tree.txt) |
| `-b`, `--backup-dir` | Set backup directory (default: ./.tt_backups) |
| `-h`, `--help`    | Show help message |

### Examples

1. Basic usage with defaults:

   ```bash
   tt
   ```

2. Dry run with verbose output:

   ```bash
   tt -d -v
   ```

3. Custom output filename:

   ```bash
   tt -o project_tree.txt
   ```

4. Specify custom backup directory:

   ```bash
   tt -b ./backups
   ```

---

## How It Works

1. **Tree Generation**:
   - Scans current directory recursively
   - Ignores files/directories matching .gitignore
   - Excludes common build/dist directories
   - Outputs to `tree.txt` (or specified file)

2. **File Processing**:
   - For each supported file:
     - Checks if header needs updating
     - Creates backup if modifying
     - Adds/updates standardized header
   - Skips:
     - Binary files
     - Files over 1MB
     - Minified/bundled files (*.min.*, *.bundle.*)
     - Configuration files (JSON, YAML)

3. **Backup System**:
   - Creates timestamped backups in `.tt_backups/`
   - Each backup contains original file content
   - Backup naming: `path_to_file.20230515_142022.bak`

---

## Supported File Types

tt supports headers for these file extensions:

- **Go/Rust/JavaScript/TypeScript**: `.go`, `.rs`, `.js`, `.ts`, `.jsx`, `.tsx`
- **Python/Ruby**: `.py`, `.rb`
- **Java/Kotlin**: `.java`, `.kt`
- **C/C++**: `.cpp`, `.h`
- **Shell scripts**: `.sh`, `.bash`, `.zsh`
- **Web**: `.html`, `.css`
- **PHP**: `.php`
- **Text/Markdown**: `.txt`, `.md`

---

## Configuration

### Environment Variables

You can customize behavior with these variables:

```bash
export TT_OUTPUT="custom_tree.txt"  # Default output file
export TT_BACKUP_DIR="./backups"    # Backup directory
export TT_MAX_FILE_SIZE=2097152     # 2MB file size limit
```

### Excluding Files/Directories

tt automatically excludes these patterns:

- `*.min.*`, `*.bundle.*`
- `dist/`, `build/`, `node_modules/`, `vendor/`
- All gitignored files

---

## Best Practices

1. **First Run**:
   - Always run with `-d` first to preview changes
   - Verify the output tree.txt looks correct

2. **Version Control**:
   - Consider adding `.tt_backups/` to your .gitignore
   - The generated tree.txt can be committed to document project structure

3. **Automation**:
   - Add tt to your project setup script
   - Run as a pre-commit hook to keep headers updated

4. **Backups**:
   - Regularly clean up old backups
   - Use `--backup-dir` to centralize backups outside project

---

## FAQ

**Q: Will tt modify my binary files?**
A: No, tt automatically detects and skips binary files.

**Q: How do I process only certain file types?**
A: Currently you'd need to modify the `CODING_EXTS` array in the script.

**Q: Can I customize the header format?**
A: Yes, edit the `process_file` function in the script.

**Q: Why is my file being skipped?**
A: Run with `-v` to see why files are being skipped (size, binary, excluded pattern, etc.)

---

## Troubleshooting

### Common Issues

1. **Permission denied**:
   - Solution: Run with sudo or adjust target directory permissions

2. **tree command not found**:
   - Solution: Install tree package (see Dependencies section)

3. **Backup directory not writable**:
   - Solution: Specify different directory with `-b` or adjust permissions

4. **File headers not updating**:
   - Solution: Use `-f` to force processing (skips backup confirmation)

---

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Submit a Pull Request

---

## License

MIT License - See [LICENSE](https://github.com/gourdian25/tree-tagger/blob/master/LICENSE)

---

## Support

Open an issue on [GitHub](https://github.com/gourdian25/tree-tagger/issues) for help.

---

## Authors

- [gourdian25](https://github.com/gourdian25)
- [lordofthemind](https://github.com/lordofthemind)

---

Happy coding! 🌳
