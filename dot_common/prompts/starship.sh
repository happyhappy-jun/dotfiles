#!/usr/bin/env bash
# Starship prompt setup for both zsh and bash
# Installation is handled by run_once_before_install_starship.sh
# This script only initializes Starship and sets up the Pure preset

# Only initialize if starship is available and not already initialized
if command -v starship >/dev/null 2>&1; then
    # Set up Pure preset configuration (only if config doesn't exist)
    mkdir -p ~/.config 2>/dev/null || true
    if [ ! -f ~/.config/starship.toml ]; then
        starship preset pure-preset -o ~/.config/starship.toml 2>/dev/null || true
    fi
    
    # Initialize Starship based on shell
    if [ -n "$ZSH_VERSION" ]; then
        # Zsh initialization
        eval "$(starship init zsh)"
    elif [ -n "$BASH_VERSION" ]; then
        # Bash initialization
        eval "$(starship init bash)"
    fi
fi
