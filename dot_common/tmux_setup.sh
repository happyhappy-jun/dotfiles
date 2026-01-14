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

# Setup .tmux.conf.local (customization file)
# Chezmoi manages this file directly, so we ensure it exists
# Oh my tmux! will source this file automatically
if [ ! -f "$HOME/.tmux.conf.local" ]; then
    # Create empty file if it doesn't exist (chezmoi will populate it)
    touch "$HOME/.tmux.conf.local" 2>/dev/null || true
fi

# Export TMUX_DIR and set TMUX_CONF for Oh my tmux! compatibility
export TMUX_DIR
export TMUX_CONF="$HOME/.tmux.conf"
export TMUX_CONF_LOCAL="$HOME/.tmux.conf.local"

# If tmux is running, reload the configuration
if [ -n "$TMUX" ] && command -v tmux >/dev/null 2>&1; then
    # Set environment variables in tmux so Oh my tmux! can find the config
    tmux set-environment -g TMUX_CONF "$HOME/.tmux.conf" 2>/dev/null || true
    tmux set-environment -g TMUX_CONF_LOCAL "$HOME/.tmux.conf.local" 2>/dev/null || true
fi
