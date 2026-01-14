#!/usr/bin/env bash
# Lazy loading utilities for both zsh and bash
# This file provides shell-agnostic lazy loading functionality

# Detect shell type
if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
else
    SHELL_TYPE="unknown"
fi

# Lazy load function that works in both zsh and bash
# Usage: lazy_load <command> [--] <load_command>
# Example: lazy_load nvm -- 'source "$HOME/.nvm/nvm.sh"'
lazy_load() {
    local cmd="$1"
    shift
    
    # Handle '--' separator if present
    if [ "$1" = "--" ]; then
        shift
    fi
    
    local load_cmd="$*"
    
    if [ "$SHELL_TYPE" = "zsh" ]; then
        # Zsh implementation using function wrapper
        # Use both 'function' and '()' syntax for compatibility
        eval "$cmd() {
            unfunction $cmd 2>/dev/null || unset -f $cmd
            $load_cmd
            $cmd \"\$@\"
        }"
    elif [ "$SHELL_TYPE" = "bash" ]; then
        # Bash implementation using function wrapper
        eval "$cmd() {
            unset -f $cmd
            $load_cmd
            $cmd \"\$@\"
        }"
    fi
}

# Lazy load with multiple commands
# Usage: lazy_load_multi <command> [--] <load_command> [command1] [command2] ...
# Example: lazy_load_multi nvm -- 'source "$HOME/.nvm/nvm.sh"' node npm
lazy_load_multi() {
    local cmd="$1"
    shift
    
    # Handle '--' separator if present
    if [ "$1" = "--" ]; then
        shift
    fi
    
    local load_cmd="$1"
    shift
    local commands=("$cmd" "$@")
    
    for c in "${commands[@]}"; do
        lazy_load "$c" -- "$load_cmd"
    done
}

# Check if lazy loading is available
if [ "$SHELL_TYPE" = "zsh" ]; then
    # Check for zsh-defer plugin (if using oh-my-zsh or similar)
    if command -v zsh-defer >/dev/null 2>&1; then
        HAS_ZSH_DEFER=true
    else
        HAS_ZSH_DEFER=false
    fi
fi
