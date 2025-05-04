#!/bin/bash
# tt - Enhanced Smart Tree Tagger v0.0.1
# Robust file header management with backup and safety features

# --- Configuration ---
VERSION="0.0.1"
DEFAULT_OUTPUT="tree.txt"
DEFAULT_BACKUP_DIR="./.tt_backups"
MAX_FILE_SIZE=1048576  # 1MB
CODING_EXTS=("go" "rs" "js" "ts" "jsx" "tsx" "css" "html" "py" "rb" "java" "kt" "cpp" "h" "sh" "bash" "zsh" "php" "txt")
EXCLUDE_PATTERNS=("*.min.*" "*.bundle.*" "dist/*" "build/*" "node_modules/*" "vendor/*")

# --- Initialize Options ---
OUTPUT="$DEFAULT_OUTPUT"
BACKUP_DIR="$DEFAULT_BACKUP_DIR"
DRY_RUN=false
VERBOSE=false
FORCE=false

# --- Helper Functions ---
color() {
    local color_code="$1"
    shift
    if [ -t 1 ]; then
        echo -e "\e[${color_code}m$*\e[0m"
    else
        echo "$@"
    fi
}

show_help() {
    echo -e "$(color 1 'tt - Enhanced Smart Tree Tagger v'"$VERSION")"
    echo "Usage: tt [OPTIONS] [OUTPUT_FILE]"
    echo
    echo "Options:"
    echo "  -d, --dry-run      Preview changes without modifying files"
    echo "  -v, --verbose      Show detailed processing information"
    echo "  -f, --force        Process files without backup confirmation"
    echo "  -o, --output FILE  Specify output tree file (default: $DEFAULT_OUTPUT)"
    echo "  -b, --backup DIR   Set backup directory (default: $DEFAULT_BACKUP_DIR)"
    echo "  -h, --help         Show this help message"
    echo
    echo "Examples:"
    echo "  tt                  # Basic usage with defaults"
    echo "  tt -d -v            # Dry run with verbose output"
    echo "  tt -o project_tree  # Custom output filename"
}

is_binary() {
    local file="$1"
    if grep -qI '^' "$file"; then
        return 1  # Text file
    else
        return 0  # Binary file
    fi
}

create_backup() {
    local file="$1"
    mkdir -p "$BACKUP_DIR" || return 1
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_path="$BACKUP_DIR/${file//\//_}.$timestamp.bak"
    if cp "$file" "$backup_path"; then
        echo "$backup_path"
        return 0
    else
        color 31 "Failed to create backup for: $file"
        return 1
    fi
}

# --- File Processing ---
process_file() {
    local file="$1"
    local rel_path="${file#./}"
    local header="" generic_pattern="" specific_pattern="" shebang=""
    
    # Check for shebang
    local first_line=$(head -n 1 "$file" 2>/dev/null)
    [[ "$first_line" == "#!"* ]] && shebang="$first_line"

    # Determine header patterns by file type
    case "$file" in
        *.go|*.rs|*.js|*.ts|*.jsx|*.tsx|*.py|*.rb|*.java|*.kt|*.cpp|*.h|*.sh|*.bash|*.zsh|*.php)
            header="// File: $rel_path"
            generic_pattern="^[[:space:]]*//[[:space:]]*File:[[:space:]]*.*$"
            specific_pattern="^[[:space:]]*//[[:space:]]*File:[[:space:]]*${rel_path//./\\.}[[:space:]]*$"
            ;;
        *.css)
            header="/* File: $rel_path */"
            generic_pattern="^[[:space:]]*/\*[[:space:]]*File:[[:space:]]*.*\*/[[:space:]]*$"
            specific_pattern="^[[:space:]]*/\*[[:space:]]*File:[[:space:]]*${rel_path//./\\.}[[:space:]]*\*/[[:space:]]*$"
            ;;
        *.html)
            header="<!-- File: $rel_path -->"
            generic_pattern="^[[:space:]]*<!--[[:space:]]*File:[[:space:]]*.*-->[[:space:]]*$"
            specific_pattern="^[[:space:]]*<!--[[:space:]]*File:[[:space:]]*${rel_path//./\\.}[[:space:]]*-->[[:space:]]*$"
            ;;
        *.md|*.txt)
            header="# File: $rel_path"
            generic_pattern="^[[:space:]]*#[[:space:]]*File:[[:space:]]*.*$"
            specific_pattern="^[[:space:]]*#[[:space:]]*File:[[:space:]]*${rel_path//./\\.}[[:space:]]*$"
            ;;
        *.json|*.yaml|*.yml)
            [ "$VERBOSE" = true ] && color 33 "Skipping config file: $rel_path"
            return
            ;;
        *)
            [ "$VERBOSE" = true ] && color 33 "Skipping unsupported file: $rel_path"
            return
            ;;
    esac

    # Check if exact header already exists
    if head -n 1 "$file" 2>/dev/null | grep -qE "$specific_pattern"; then
        [ "$VERBOSE" = true ] && color 32 "✓ Header correct: $rel_path"
        return
    fi

    # Prepare new content
    local tmp=$(mktemp) || return
    [ -n "$shebang" ] && echo -e "$shebang\n" >> "$tmp"
    echo -e "$header\n" >> "$tmp"

    # Remove existing header if present
    if head -n 1 "$file" 2>/dev/null | grep -qE "$generic_pattern"; then
        if [ -n "$shebang" ]; then
            # Preserve shebang, remove header
            tail -n +2 "$file" | sed -E "/$generic_pattern/d" >> "$tmp"
        else
            # Just remove header
            tail -n +2 "$file" >> "$tmp"
        fi
        local action="Updated"
        local action_color=34  # Blue
    else
        # Keep all content
        cat "$file" >> "$tmp"
        local action="Added"
        local action_color=35  # Purple
    fi

    # Handle dry-run or actual execution
    if [ "$DRY_RUN" = true ]; then
        color 36 "[DRY RUN] Would ${action,,} header: $rel_path"
        rm "$tmp"
    else
        if [ "$FORCE" = false ] && [ -f "$file" ]; then
            local backup_path=$(create_backup "$file") || return
        fi
        
        if ! diff -q "$file" "$tmp" &>/dev/null; then
            if mv "$tmp" "$file"; then
                color "$action_color" "$action header: $rel_path"
                [ -n "$backup_path" ] && color 90 "Backup: $backup_path"
            else
                color 31 "Failed to update: $rel_path"
                rm "$tmp"
            fi
        else
            [ "$VERBOSE" = true ] && color 32 "✓ No changes needed: $rel_path"
            rm "$tmp"
        fi
    fi
}

# --- Main Execution ---
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--dry-run) DRY_RUN=true; shift ;;
            -v|--verbose) VERBOSE=true; shift ;;
            -f|--force) FORCE=true; shift ;;
            -o|--output) OUTPUT="$2"; shift 2 ;;
            -b|--backup-dir) BACKUP_DIR="$2"; shift 2 ;;
            -h|--help) show_help; exit 0 ;;
            *) OUTPUT="$1"; shift ;;
        esac
    done

    # Validate backup directory
    if [ "$DRY_RUN" = false ] && [ "$FORCE" = false ]; then
        if [ -d "$BACKUP_DIR" ] && [ -n "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
            color 33 "Backup directory exists and is not empty: $BACKUP_DIR"
            read -p "Continue? [y/N] " -n 1 -r
            echo
            [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
        fi
    fi

    # Generate directory tree
    [ "$VERBOSE" = true ] && color 36 "🌳 Generating directory tree..."
    if ! tree --gitignore -I "$(basename "$BACKUP_DIR")" > "$OUTPUT"; then
        color 31 "Failed to generate directory tree"
        exit 1
    fi

    # Process files
    [ "$VERBOSE" = true ] && color 36 "🔍 Processing files..."
    local processed=0 skipped=0

    while IFS= read -r -d '' file; do
        # Skip excluded patterns
        for pattern in "${EXCLUDE_PATTERNS[@]}"; do
            [[ "$file" == $pattern ]] && { ((skipped++)); continue 2; }
        done

        # Skip gitignored files
        if git check-ignore -q "$file"; then
            [ "$VERBOSE" = true ] && color 33 "⊖ Skipping gitignored: ${file#./}"
            ((skipped++))
            continue
        fi

        # Skip binary files
        if is_binary "$file"; then
            [ "$VERBOSE" = true ] && color 33 "⊖ Skipping binary: ${file#./}"
            ((skipped++))
            continue
        fi

        # Skip large files
        local file_size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
        if [[ "$file_size" -gt "$MAX_FILE_SIZE" ]]; then
            [ "$VERBOSE" = true ] && color 33 "⊖ Skipping large ($((file_size/1024))KB): ${file#./}"
            ((skipped++))
            continue
        fi

        # Check extension
        local ext="${file##*.}"
        local filename="${file%.*}"
        if [[ "$ext" != "$filename" ]] && printf '%s\n' "${CODING_EXTS[@]}" | grep -qx "$ext"; then
            process_file "$file" && ((processed++)) || ((skipped++))
        else
            [ "$VERBOSE" = true ] && color 33 "⊖ Skipping unsupported: ${file#./}"
            ((skipped++))
        fi
    done < <(find . -type f ! -path "./.git/*" ! -path "./$OUTPUT" ! -path "./$BACKUP_DIR/*" -print0)

    # Summary
    echo -e "\n$(color 32 '✅ Done!')"
    echo "Tree output: $(color 34 "$OUTPUT")"
    [ "$DRY_RUN" = false ] && echo "Backups: $(color 34 "$BACKUP_DIR")"
    echo "Files processed: $(color 32 "$processed")"
    echo "Files skipped: $skipped"
}

# Run main function
main "$@"