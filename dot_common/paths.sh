#!/usr/bin/env bash
# PATH management with OS-aware additions
# This file handles PATH modifications for both macOS and Linux

# CRITICAL: Always preserve existing PATH - never clear it
# Store original PATH before any modifications
_ORIGINAL_PATH="${PATH:-}"

# Ensure PATH is initialized (safety check)
# If PATH is empty, unset, or doesn't contain critical system paths, fix it
if [ -z "$PATH" ] || [ "$PATH" = "" ] || [[ "$PATH" != *"/usr/bin"* ]] || [[ "$PATH" != *"/bin"* ]]; then
    # PATH is broken or missing critical paths - reinitialize
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Start with system defaults for macOS
        PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin"
        # Preserve original PATH if it was set (append it)
        if [ -n "$_ORIGINAL_PATH" ] && [[ "$_ORIGINAL_PATH" != *"/usr/share/zsh/pure"* ]]; then
            PATH="$PATH:$_ORIGINAL_PATH"
        fi
    else
        # Start with system defaults for Linux
        PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        # Preserve original PATH if it was set (append it)
        if [ -n "$_ORIGINAL_PATH" ] && [[ "$_ORIGINAL_PATH" != *"/usr/share/zsh/pure"* ]]; then
            PATH="$PATH:$_ORIGINAL_PATH"
        fi
    fi
    export PATH
else
    # PATH exists and looks valid - ensure critical system paths are present (prepend if missing)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS: ensure system paths are in PATH
        for sys_path in /usr/local/bin /usr/bin /bin /usr/sbin /sbin /opt/homebrew/bin; do
            if [[ ":$PATH:" != *":$sys_path:"* ]] && [ -d "$sys_path" ]; then
                PATH="$sys_path:$PATH"
            fi
        done
    else
        # Linux: ensure system paths are in PATH
        for sys_path in /usr/local/bin /usr/bin /bin /usr/sbin /sbin; do
            if [[ ":$PATH:" != *":$sys_path:"* ]] && [ -d "$sys_path" ]; then
                PATH="$sys_path:$PATH"
            fi
        done
    fi
    export PATH
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

# Function to display all PATH entries (one per line)
path() {
    echo "$PATH" | tr ':' '\n' | nl
}

# Function to load custom paths from ~/.paths file
load_custom_paths() {
    local paths_file="${1:-$HOME/.paths}"
    
    if [ ! -f "$paths_file" ]; then
        return 0
    fi
    
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Trim whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        
        # Expand ~ to home directory
        line="${line/#\~/$HOME}"
        
        # Add to PATH if directory exists
        add_to_path "$line"
    done < "$paths_file"
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

# Conda paths (miniconda3/anaconda3)
# Note: Conda initialization is lazy-loaded, but we can add the base path here
# for commands that might be called directly
if [ -d "$HOME/miniconda3" ]; then
    export CONDA_HOME="$HOME/miniconda3"
    # Don't add to PATH here - conda init will handle it
    # But ensure conda binary is accessible for lazy loading
    if [ -f "$CONDA_HOME/bin/conda" ]; then
        # Add conda bin only if not already in PATH (for direct conda calls)
        if [[ ":$PATH:" != *":$CONDA_HOME/bin:"* ]]; then
            # We'll let conda init handle PATH, but this ensures conda command is found
            export CONDA_BIN="$CONDA_HOME/bin/conda"
        fi
    fi
elif [ -d "$HOME/miniconda" ]; then
    # Fallback for older miniconda installations
    export CONDA_HOME="$HOME/miniconda"
    if [ -f "$CONDA_HOME/bin/conda" ]; then
        if [[ ":$PATH:" != *":$CONDA_HOME/bin:"* ]]; then
            export CONDA_BIN="$CONDA_HOME/bin/conda"
        fi
    fi
elif [ -d "$HOME/anaconda3" ]; then
    export CONDA_HOME="$HOME/anaconda3"
    if [ -f "$CONDA_HOME/bin/conda" ]; then
        if [[ ":$PATH:" != *":$CONDA_HOME/bin:"* ]]; then
            export CONDA_BIN="$CONDA_HOME/bin/conda"
        fi
    fi
elif [ -d "$HOME/anaconda" ]; then
    # Fallback for older anaconda installations
    export CONDA_HOME="$HOME/anaconda"
    if [ -f "$CONDA_HOME/bin/conda" ]; then
        if [[ ":$PATH:" != *":$CONDA_HOME/bin:"* ]]; then
            export CONDA_BIN="$CONDA_HOME/bin/conda"
        fi
    fi
fi

# Load custom paths from ~/.paths (user-defined paths)
load_custom_paths
