#!/usr/bin/env bash
# Starship prompt initialization - keep it simple
# Config setup is handled by run_once_before_setup_starship_config.sh

if command -v starship >/dev/null 2>&1; then
    # Create config with Pure preset if it doesn't exist
    if [ ! -f ~/.config/starship.toml ]; then
        mkdir -p ~/.config 2>/dev/null
        starship preset pure-preset -o ~/.config/starship.toml 2>/dev/null
    fi
    
    # Initialize Starship based on shell
    if [ -n "$ZSH_VERSION" ]; then
        eval "$(starship init zsh)"
    elif [ -n "$BASH_VERSION" ]; then
        eval "$(starship init bash)"
    fi
fi
