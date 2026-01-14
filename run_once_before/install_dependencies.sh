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
        brew install neofetch htop tmux || true
    fi
    
elif [ "$IS_LINUX" = true ]; then
    echo "Detected Linux"
    
    # Install utilities based on package manager
    if command -v apt >/dev/null 2>&1; then
        echo "Installing Linux utilities (apt)..."
        sudo apt update
        sudo apt install -y neofetch htop xclip tmux || true
    elif command -v yum >/dev/null 2>&1; then
        echo "Installing Linux utilities (yum)..."
        sudo yum install -y neofetch htop xclip tmux || true
    elif command -v dnf >/dev/null 2>&1; then
        echo "Installing Linux utilities (dnf)..."
        sudo dnf install -y neofetch htop xclip tmux || true
    fi
fi

# Install Starship prompt (recommended)
# Starship is the primary prompt system used in this dotfiles setup
if ! command -v starship >/dev/null 2>&1; then
    echo "Installing Starship prompt..."
    if [ -f "$(chezmoi source-path 2>/dev/null)/run_once_before/install_starship.sh" ]; then
        bash "$(chezmoi source-path)/run_once_before/install_starship.sh"
    elif [ -f "$HOME/.local/share/chezmoi/run_once_before/install_starship.sh" ]; then
        bash "$HOME/.local/share/chezmoi/run_once_before/install_starship.sh"
    else
        echo "Starship installation script not found. Install manually from https://starship.rs"
        echo "Or run: curl -sS https://starship.rs/install.sh | sh"
    fi
fi

# Set up Starship configuration with Pure preset
if command -v starship >/dev/null 2>&1; then
    echo "Setting up Starship configuration..."
    if [ -f "$(chezmoi source-path 2>/dev/null)/run_once_before/setup_starship_config.sh" ]; then
        bash "$(chezmoi source-path)/run_once_before/setup_starship_config.sh"
    elif [ -f "$HOME/.local/share/chezmoi/run_once_before/setup_starship_config.sh" ]; then
        bash "$HOME/.local/share/chezmoi/run_once_before/setup_starship_config.sh"
    fi
fi

echo "Dependency installation complete!"
echo "Note: Some packages may require manual installation."
echo ""
echo "Pure prompt will be automatically cloned to ~/.zsh/pure on first use (zsh only)."
echo "Bash users will get a Pure-inspired prompt automatically."
echo ""
echo "Oh my tmux! will be automatically installed via install_tmux_config.sh"
echo "Run 'chezmoi apply' to set up tmux configuration."
