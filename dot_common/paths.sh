#!/usr/bin/env bash
# PATH management with OS-aware additions
# This file handles PATH modifications for both macOS and Linux

# Ensure PATH is initialized (safety check)
# Preserve existing PATH or initialize with system defaults
if [ -z "$PATH" ]; then
    # Initialize with system defaults based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin"
    else
        export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    fi
else
    # PATH exists, ensure critical system paths are present (add if missing)
    # Don't use 'local' in sourced scripts - use regular variables
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS: ensure system paths are in PATH
        for sys_path in /usr/local/bin /usr/bin /bin /usr/sbin /sbin /opt/homebrew/bin; do
            if [[ ":$PATH:" != *":$sys_path:"* ]] && [ -d "$sys_path" ]; then
                export PATH="$sys_path:$PATH"
            fi
        done
    else
        # Linux: ensure system paths are in PATH
        for sys_path in /usr/local/bin /usr/bin /bin /usr/sbin /sbin; do
            if [[ ":$PATH:" != *":$sys_path:"* ]] && [ -d "$sys_path" ]; then
                export PATH="$sys_path:$PATH"
            fi
        done
    fi
fi

# Function to add path if it exists and is not already in PATH
add_to_path() {
    local new_path="$1"
    if [ -d "$new_path" ] && [[ ":$PATH:" != *":$new_path:"* ]]; then
        export PATH="$new_path:$PATH"
    fi
}

# Function to add path to end if it exists and is not already in PATH
add_to_path_end() {
    local new_path="$1"
    if [ -d "$new_path" ] && [[ ":$PATH:" != *":$new_path:"* ]]; then
        export PATH="$PATH:$new_path"
    fi
}

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS specific paths
    
    # Homebrew paths
    if [ -d "/opt/homebrew/bin" ]; then
        # Apple Silicon Mac
        add_to_path "/opt/homebrew/bin"
        add_to_path "/opt/homebrew/sbin"
    elif [ -d "/usr/local/bin" ]; then
        # Intel Mac
        add_to_path "/usr/local/bin"
        add_to_path "/usr/local/sbin"
    fi
    
    # Homebrew opt paths
    if [ -d "/opt/homebrew/opt" ]; then
        add_to_path "/opt/homebrew/opt"
    elif [ -d "/usr/local/opt" ]; then
        add_to_path "/usr/local/opt"
    fi
    
    # User local bin
    add_to_path "$HOME/.local/bin"
    
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux (Ubuntu) specific paths
    
    # User local bin (standard Linux location)
    add_to_path "$HOME/.local/bin"
    
    # Snap paths (if snap is installed)
    if [ -d "/snap/bin" ]; then
        add_to_path "/snap/bin"
    fi
    
    # System paths (usually already in PATH, but ensure they're there)
    add_to_path "/usr/local/bin"
    add_to_path "/usr/local/sbin"
    add_to_path "/usr/bin"
    add_to_path "/usr/sbin"
    add_to_path "/bin"
    add_to_path "/sbin"
fi

# Common paths for both OS
add_to_path "$HOME/bin"
add_to_path "$HOME/.cargo/bin"  # Rust
add_to_path "$HOME/.go/bin"     # Go
add_to_path "$HOME/.yarn/bin"   # Yarn
add_to_path "$HOME/.config/yarn/global/node_modules/.bin"  # Yarn global

# Node version managers (lazy loaded, but paths can be set here)
if [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
fi

if [ -d "$HOME/.fnm" ]; then
    export PATH="$HOME/.fnm:$PATH"
fi

# Python paths
if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    add_to_path "$PYENV_ROOT/bin"
fi

# Ruby paths
if [ -d "$HOME/.rbenv" ]; then
    export RBENV_ROOT="$HOME/.rbenv"
    add_to_path "$RBENV_ROOT/bin"
fi
