#!/usr/bin/env bash
# Install zsh-history-substring-search plugin for zsh
# This script clones the plugin repository if it doesn't exist

set -e

# Only install for zsh
if [ -z "$ZSH_VERSION" ] && [ "$SHELL" != "/bin/zsh" ] && [ "$SHELL" != "/usr/bin/zsh" ]; then
    # Check if zsh is available
    if ! command -v zsh >/dev/null 2>&1; then
        echo "zsh not found. Skipping zsh-history-substring-search installation."
        exit 0
    fi
fi

# Determine installation directory
HISTORY_SEARCH_DIR="$HOME/.zsh/plugins/zsh-history-substring-search"

# Clone repository if it doesn't exist
if [ ! -d "$HISTORY_SEARCH_DIR" ]; then
    echo "Installing zsh-history-substring-search plugin..."
    
    # Ensure parent directory exists
    mkdir -p "$(dirname "$HISTORY_SEARCH_DIR")"
    
    # Clone the repository
    if command -v git >/dev/null 2>&1; then
        git clone https://github.com/zsh-users/zsh-history-substring-search.git "$HISTORY_SEARCH_DIR" || {
            echo "Failed to clone zsh-history-substring-search repository."
            echo "You can install it manually:"
            echo "  git clone https://github.com/zsh-users/zsh-history-substring-search.git $HISTORY_SEARCH_DIR"
            exit 1
        }
        echo "zsh-history-substring-search installed successfully!"
    else
        echo "git not found. Cannot install zsh-history-substring-search."
        echo "Please install git and run this script again."
        exit 1
    fi
else
    echo "zsh-history-substring-search already installed at $HISTORY_SEARCH_DIR"
    # Update if it's a git repository
    if [ -d "$HISTORY_SEARCH_DIR/.git" ]; then
        echo "Updating zsh-history-substring-search..."
        (cd "$HISTORY_SEARCH_DIR" && git pull || true)
    fi
fi
