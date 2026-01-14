#!/usr/bin/env bash
# One-time setup script for installing dependencies
# This script can be run manually or via chezmoi run_once_before

set -e

echo "Installing dotfiles dependencies..."

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    IS_MACOS=true
    IS_LINUX=false
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    IS_MACOS=false
    IS_LINUX=true
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

# Install useful utilities
if [ "$IS_MACOS" = true ]; then
    echo "Detected macOS"
    
    # Check for Homebrew
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew not found. Install it from https://brew.sh"
    else
        echo "Installing macOS utilities..."
        brew install neofetch htop || true
    fi
    
elif [ "$IS_LINUX" = true ]; then
    echo "Detected Linux"
    
    # Install utilities based on package manager
    if command -v apt >/dev/null 2>&1; then
        echo "Installing Linux utilities (apt)..."
        sudo apt update
        sudo apt install -y neofetch htop xclip || true
    elif command -v yum >/dev/null 2>&1; then
        echo "Installing Linux utilities (yum)..."
        sudo yum install -y neofetch htop xclip || true
    elif command -v dnf >/dev/null 2>&1; then
        echo "Installing Linux utilities (dnf)..."
        sudo dnf install -y neofetch htop xclip || true
    fi
fi

# Install starship prompt (optional but recommended)
if ! command -v starship >/dev/null 2>&1; then
    echo "Starship prompt not found. Install it from https://starship.rs"
    echo "Or run: curl -sS https://starship.rs/install.sh | sh"
fi

echo "Dependency installation complete!"
echo "Note: Some packages may require manual installation."
