#!/usr/bin/env bash
# Install Oh my tmux! configuration
# This script clones the Oh my tmux! repository if it doesn't exist
# Supports multiple installation locations as per Oh my tmux! standards

set -e

echo "Checking for Oh my tmux! installation..."

# Determine installation location (in order of preference)
TMUX_DIR=""
if [ -n "$XDG_CONFIG_HOME" ] && [ -d "$XDG_CONFIG_HOME" ]; then
    TMUX_DIR="$XDG_CONFIG_HOME/tmux"
elif [ -d "$HOME/.config" ]; then
    TMUX_DIR="$HOME/.config/tmux"
else
    TMUX_DIR="$HOME/.tmux"
fi

# Check if Oh my tmux! is already installed
if [ -d "$TMUX_DIR" ] && [ -f "$TMUX_DIR/.tmux.conf" ]; then
    echo "Oh my tmux! is already installed at $TMUX_DIR"
    exit 0
fi

# Check if git is available
if ! command -v git >/dev/null 2>&1; then
    echo "Warning: git is not installed. Cannot install Oh my tmux!"
    echo "Please install git first, then run this script again."
    exit 1
fi

# Create parent directory if it doesn't exist
PARENT_DIR=$(dirname "$TMUX_DIR")
if [ ! -d "$PARENT_DIR" ]; then
    mkdir -p "$PARENT_DIR"
fi

# Clone Oh my tmux! repository
echo "Installing Oh my tmux! to $TMUX_DIR..."
if git clone --depth=1 https://github.com/gpakosz/.tmux.git "$TMUX_DIR" 2>/dev/null; then
    echo "Oh my tmux! installed successfully to $TMUX_DIR"
    
    # Create backup of existing .tmux.conf.local if it exists
    if [ -f "$HOME/.tmux.conf.local" ] && [ ! -L "$HOME/.tmux.conf.local" ]; then
        echo "Backing up existing .tmux.conf.local to .tmux.conf.local.backup"
        cp "$HOME/.tmux.conf.local" "$HOME/.tmux.conf.local.backup"
    fi
else
    echo "Error: Failed to clone Oh my tmux! repository"
    echo "Please check your internet connection and try again."
    exit 1
fi

echo "Oh my tmux! installation complete!"
echo "Note: Symlinks will be set up by tmux_setup.sh on next shell startup."
