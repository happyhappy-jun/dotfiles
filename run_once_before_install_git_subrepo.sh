#!/usr/bin/env bash
# Install git-subrepo
# https://github.com/ingydotnet/git-subrepo

set +e

# Use centralized dotfiles deps directory
DOTFILES_DEPS_DIR="$HOME/.local/share/dotfiles"
GIT_SUBREPO_DIR="$DOTFILES_DEPS_DIR/git-subrepo"

echo "Installing git-subrepo..."

# Check if git is available
if ! command -v git >/dev/null 2>&1; then
    echo "Git is not installed. Please install git first."
    exit 1
fi

# Create deps directory if it doesn't exist
mkdir -p "$DOTFILES_DEPS_DIR"

# Check if already installed
if [ -d "$GIT_SUBREPO_DIR" ]; then
    echo "git-subrepo already installed at $GIT_SUBREPO_DIR"
    echo "Updating..."
    cd "$GIT_SUBREPO_DIR" && git pull origin master
else
    echo "Cloning git-subrepo..."
    git clone https://github.com/ingydotnet/git-subrepo "$GIT_SUBREPO_DIR"
fi

if [ -d "$GIT_SUBREPO_DIR" ]; then
    echo "git-subrepo installed successfully!"
    echo "The .rc file will be sourced automatically by your shell configuration."
else
    echo "Failed to install git-subrepo"
    exit 1
fi
