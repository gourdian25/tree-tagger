#!/bin/bash
# tt (Enhanced Smart Tree Tagger) Install Script
# This script installs tt by downloading it from GitHub,
# making it executable, and placing it in /usr/local/bin.

set -e  # Exit on any error

# Define the GitHub repository and script name
REPO="https://github.com/gourdian25/tree-tagger"
SCRIPT_NAME="tt"
INSTALL_DIR="/usr/local/bin"

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check for required dependencies
echo -e "\033[1;36mChecking dependencies...\033[0m"
required_commands=("tree" "git")
missing_commands=()

for cmd in "${required_commands[@]}"; do
    if ! command_exists "$cmd"; then
        missing_commands+=("$cmd")
    fi
done

if [ ${#missing_commands[@]} -gt 0 ]; then
    echo -e "\033[1;33mMissing dependencies: ${missing_commands[*]}\033[0m"
    
    # Try to install missing dependencies
    if command_exists "apt-get"; then
        # For Debian/Ubuntu-based systems
        echo -e "\033[1;32mAttempting to install with apt-get...\033[0m"
        sudo apt-get update
        sudo apt-get install -y "${missing_commands[@]}"
    elif command_exists "yum"; then
        # For CentOS/RHEL-based systems
        echo -e "\033[1;32mAttempting to install with yum...\033[0m"
        sudo yum install -y "${missing_commands[@]}"
    elif command_exists "brew"; then
        # For macOS
        echo -e "\033[1;32mAttempting to install with brew...\033[0m"
        brew install "${missing_commands[@]}"
    else
        echo -e "\033[1;31mUnsupported package manager. Please install these manually:"
        echo -e "  ${missing_commands[*]}\033[0m"
        exit 1
    fi
    
    # Verify installation
    for cmd in "${missing_commands[@]}"; do
        if ! command_exists "$cmd"; then
            echo -e "\033[1;31mFailed to install $cmd. Please install it manually and try again.\033[0m"
            exit 1
        fi
    done
fi

# Download the script
echo -e "\033[1;32mDownloading tt (Enhanced Smart Tree Tagger)...\033[0m"
curl -fsSL "${REPO}/raw/master/tt.sh" -o "/tmp/${SCRIPT_NAME}"

# Make the script executable
echo -e "\033[1;32mMaking tt executable...\033[0m"
chmod +x "/tmp/${SCRIPT_NAME}"

# Move the script to /usr/local/bin
echo -e "\033[1;32mInstalling tt to ${INSTALL_DIR}...\033[0m"
sudo mv "/tmp/${SCRIPT_NAME}" "${INSTALL_DIR}/${SCRIPT_NAME}"

# Verify installation
if command -v "${SCRIPT_NAME}" &> /dev/null; then
    echo -e "\033[1;32mtt installed successfully!\033[0m"
    echo -e "Run 'tt --help' to see usage instructions."
    echo -e "Documentation: ${REPO}"
else
    echo -e "\033[1;31mInstallation failed. Please check your permissions and try again.\033[0m"
    exit 1
fi