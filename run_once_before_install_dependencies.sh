#!/usr/bin/env bash
# One-time setup script for installing dependencies
# This script can be run manually or via chezmoi run_once_before

# Don't exit on error - we want to continue even if some installations fail
set +e

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
    
    # Check if current user is in sudoers group
    HAS_SUDO=false
    if command -v sudo >/dev/null 2>&1; then
        # Check if user is in sudo or wheel group
        if groups | grep -qE '\b(sudo|wheel)\b' 2>/dev/null; then
            HAS_SUDO=true
        # Also check if sudo -n works (passwordless sudo)
        elif sudo -n true 2>/dev/null; then
            HAS_SUDO=true
        fi
    fi
    
    # Install utilities based on package manager
    if command -v apt >/dev/null 2>&1; then
        if [ "$HAS_SUDO" = true ]; then
            echo "Installing Linux utilities (apt)..."
            sudo apt update && sudo apt install -y neofetch htop xclip tmux || true
        else
            echo "Skipping apt package installation (sudo not available or requires password)"
            echo "You can install manually: apt install neofetch htop xclip tmux"
        fi
    elif command -v yum >/dev/null 2>&1; then
        if [ "$HAS_SUDO" = true ]; then
            echo "Installing Linux utilities (yum)..."
            sudo yum install -y neofetch htop xclip tmux || true
        else
            echo "Skipping yum package installation (sudo not available or requires password)"
            echo "You can install manually: yum install neofetch htop xclip tmux"
        fi
    elif command -v dnf >/dev/null 2>&1; then
        if [ "$HAS_SUDO" = true ]; then
            echo "Installing Linux utilities (dnf)..."
            sudo dnf install -y neofetch htop xclip tmux || true
        else
            echo "Skipping dnf package installation (sudo not available or requires password)"
            echo "You can install manually: dnf install neofetch htop xclip tmux"
        fi
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
    if [ -f "$(chezmoi source-path 2>/dev/null)/run_once_before_setup_starship_config.sh" ]; then
        bash "$(chezmoi source-path)/run_once_before_setup_starship_config.sh"
    elif [ -f "$HOME/.local/share/chezmoi/run_once_before_setup_starship_config.sh" ]; then
        bash "$HOME/.local/share/chezmoi/run_once_before_setup_starship_config.sh"
    fi
fi

# Install git-subrepo (Git Submodule Alternative)
# https://github.com/ingydotnet/git-subrepo
# Installed to ~/.local/share/dotfiles/git-subrepo
if [ ! -d "$HOME/.local/share/dotfiles/git-subrepo" ]; then
    echo "Installing git-subrepo..."
    if [ -f "$(chezmoi source-path 2>/dev/null)/run_once_before_install_git_subrepo.sh" ]; then
        bash "$(chezmoi source-path)/run_once_before_install_git_subrepo.sh"
    elif [ -f "$HOME/.local/share/chezmoi/run_once_before_install_git_subrepo.sh" ]; then
        bash "$HOME/.local/share/chezmoi/run_once_before_install_git_subrepo.sh"
    else
        echo "git-subrepo installation script not found."
        echo "Install manually: git clone https://github.com/ingydotnet/git-subrepo ~/.local/share/dotfiles/git-subrepo"
    fi
else
    echo "git-subrepo already installed."
fi

# Install Poetry (Python dependency management)
# https://python-poetry.org/docs/#installation
if ! command -v poetry >/dev/null 2>&1; then
    echo "Installing Poetry..."
    curl -sSL https://install.python-poetry.org | python3 - || true
else
    echo "Poetry already installed."
fi

echo "Dependency installation complete!"
echo "Note: Some packages may require manual installation."
echo ""
echo "Pure prompt will be automatically cloned to ~/.zsh/pure on first use (zsh only)."
echo "Bash users will get a Pure-inspired prompt automatically."
echo ""
echo "Oh my tmux! will be automatically installed via install_tmux_config.sh"
echo "Run 'chezmoi apply' to set up tmux configuration."
