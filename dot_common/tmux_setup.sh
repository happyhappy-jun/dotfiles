#!/usr/bin/env bash
# Tmux setup script for Oh my tmux! configuration
# This script ensures symlinks are correctly set up for tmux configuration

# Only run if tmux is installed
if ! command -v tmux >/dev/null 2>&1; then
    return 0
fi

# Determine Oh my tmux! installation location
TMUX_DIR=""
if [ -n "$XDG_CONFIG_HOME" ] && [ -d "$XDG_CONFIG_HOME/tmux" ] && [ -f "$XDG_CONFIG_HOME/tmux/.tmux.conf" ]; then
    TMUX_DIR="$XDG_CONFIG_HOME/tmux"
elif [ -d "$HOME/.config/tmux" ] && [ -f "$HOME/.config/tmux/.tmux.conf" ]; then
    TMUX_DIR="$HOME/.config/tmux"
elif [ -d "$HOME/.tmux" ] && [ -f "$HOME/.tmux/.tmux.conf" ]; then
    TMUX_DIR="$HOME/.tmux"
fi

# If Oh my tmux! is not installed, skip setup
if [ -z "$TMUX_DIR" ]; then
    return 0
fi

# Setup .tmux.conf symlink (main configuration)
if [ ! -f "$HOME/.tmux.conf" ] || [ -L "$HOME/.tmux.conf" ]; then
    # Remove existing symlink if it's broken or points to wrong location
    if [ -L "$HOME/.tmux.conf" ]; then
        CURRENT_TARGET=$(readlink "$HOME/.tmux.conf")
        if [ "$CURRENT_TARGET" != "$TMUX_DIR/.tmux.conf" ]; then
            rm -f "$HOME/.tmux.conf"
        fi
    fi
    
    # Create symlink if it doesn't exist
    if [ ! -f "$HOME/.tmux.conf" ]; then
        ln -sf "$TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"
    fi
fi

# Setup .tmux.conf.local symlink (customization file)
# This should point to the chezmoi-managed file
CHEZMOI_TMUX_LOCAL=""
if [ -f "$HOME/.tmux.conf.local" ] && [ ! -L "$HOME/.tmux.conf.local" ]; then
    # If a regular file exists (not symlink), it might be user's custom file
    # We'll leave it alone to avoid overwriting user's customizations
    :
elif [ ! -f "$HOME/.tmux.conf.local" ]; then
    # Create symlink to chezmoi-managed file if it exists
    # The file will be created by chezmoi when dot_tmux.conf.local is applied
    # For now, we'll create an empty file that chezmoi will manage
    if [ ! -L "$HOME/.tmux.conf.local" ]; then
        # Create empty file if chezmoi hasn't created it yet
        touch "$HOME/.tmux.conf.local" 2>/dev/null || true
    fi
fi

# Export TMUX_DIR for potential use in other scripts
export TMUX_DIR
