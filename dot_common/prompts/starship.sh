#!/usr/bin/env bash
# Starship prompt setup for both zsh and bash
# Installation is handled by run_once_before_install_starship.sh
# This script only initializes Starship and sets up the Pure preset

# Only initialize if starship is available and not already initialized
if command -v starship >/dev/null 2>&1; then
    # Set up Pure preset configuration
    mkdir -p ~/.config 2>/dev/null || true
    
    # Clean up any Pure prompt variables/commands before initializing Starship
    if [ -n "$ZSH_VERSION" ]; then
        # Zsh: Unset Pure prompt variables and disable prompt
        unset PURE_PROMPT_SYMBOL PURE_PROMPT_SYMBOL_SUCCESS PURE_PROMPT_SYMBOL_ERROR 2>/dev/null || true
        prompt off 2>/dev/null || true
    elif [ -n "$BASH_VERSION" ]; then
        # Bash: Clean PROMPT_COMMAND from any Pure prompt references
        if [[ "$PROMPT_COMMAND" == *"_pure_bash_prompt"* ]]; then
            PROMPT_COMMAND=$(echo "$PROMPT_COMMAND" | sed 's/.*_pure_bash_prompt[^;]*;//g')
        fi
    fi
    
    # Ensure Starship config exists with Pure preset and scan_timeout
    if [ ! -f ~/.config/starship.toml ]; then
        # Config doesn't exist, create with Pure preset
        starship preset pure-preset -o ~/.config/starship.toml 2>/dev/null || {
            touch ~/.config/starship.toml 2>/dev/null || true
        }
        # Add scan_timeout to prevent hanging
        if [ -f ~/.config/starship.toml ]; then
            # Check if scan_timeout already exists
            if ! grep -qE '^scan_timeout\s*=' ~/.config/starship.toml 2>/dev/null; then
                echo "" >> ~/.config/starship.toml 2>/dev/null || true
                echo "scan_timeout = 2000" >> ~/.config/starship.toml 2>/dev/null || true
            fi
        fi
    else
        # Config exists - check if it's using Pure preset
        if ! grep -qE '(format|character|git_branch|git_status|directory).*pure' ~/.config/starship.toml 2>/dev/null && \
           ! grep -qE '\[character\]' ~/.config/starship.toml 2>/dev/null; then
            # Config exists but doesn't look like Pure preset, update it
            cp ~/.config/starship.toml ~/.config/starship.toml.bak 2>/dev/null || true
            starship preset pure-preset -o ~/.config/starship.toml 2>/dev/null || true
        fi
        # Ensure scan_timeout is set correctly (as a number at root level, not in any section)
        # Remove ALL occurrences of scan_timeout (from any section) and [scan_timeout] table
        # Then add it only at root level
        if [ -f ~/.config/starship.toml ]; then
            # Remove all scan_timeout-related lines (both root and section-level)
            # Also remove [scan_timeout] table section
            grep -vE '^\s*scan_timeout\s*=' ~/.config/starship.toml 2>/dev/null | \
            grep -vE '^\s*timeout\s*=' 2>/dev/null | \
            grep -vE '\[scan_timeout\]' 2>/dev/null > ~/.config/starship.toml.tmp 2>/dev/null || true
            
            if [ -f ~/.config/starship.toml.tmp ]; then
                mv ~/.config/starship.toml.tmp ~/.config/starship.toml 2>/dev/null || true
            fi
            
            # Add scan_timeout at root level (at the beginning of the file) if it doesn't exist
            if ! grep -qE '^scan_timeout\s*=' ~/.config/starship.toml 2>/dev/null; then
                # Always add at the beginning of the file (root level)
                echo "scan_timeout = 2000" > ~/.config/starship.toml.tmp 2>/dev/null || true
                echo "" >> ~/.config/starship.toml.tmp 2>/dev/null || true
                cat ~/.config/starship.toml >> ~/.config/starship.toml.tmp 2>/dev/null || true
                mv ~/.config/starship.toml.tmp ~/.config/starship.toml 2>/dev/null || true
            fi
        fi
    fi
    
    # Initialize Starship based on shell
    if [ -n "$ZSH_VERSION" ]; then
        # Zsh initialization
        eval "$(starship init zsh)" 2>/dev/null || true
    elif [ -n "$BASH_VERSION" ]; then
        # Bash initialization
        eval "$(starship init bash)" 2>/dev/null || true
    fi
fi
