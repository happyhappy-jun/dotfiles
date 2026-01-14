#!/usr/bin/env bash
# Starship prompt setup for both zsh and bash
# Installation is handled by run_once_before_install_starship.sh
# This script only initializes Starship and sets up the Pure preset

# Initialize Starship based on shell
if [ -n "$ZSH_VERSION" ]; then
    # Zsh initialization
    if command -v starship >/dev/null 2>&1; then
        eval "$(starship init zsh)"
        # Set up Pure preset configuration
        mkdir -p ~/.config 2>/dev/null || true
        starship preset pure-preset -o ~/.config/starship.toml 2>/dev/null || true
    fi
elif [ -n "$BASH_VERSION" ]; then
    # Bash initialization
    if command -v starship >/dev/null 2>&1; then
        eval "$(starship init bash)"
        # Set up Pure preset configuration
        mkdir -p ~/.config 2>/dev/null || true
        starship preset pure-preset -o ~/.config/starship.toml 2>/dev/null || true
    fi
fi
