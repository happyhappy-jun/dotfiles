#!/usr/bin/env zsh
# Pure prompt setup for zsh
# This file sets up the Pure prompt (https://github.com/sindresorhus/pure)

# Function to load Pure prompt
_load_pure_prompt() {
    # Check if Pure is already loaded
    if [[ -n "$PURE_PROMPT_SYMBOL" ]]; then
        return 0
    fi
    
    # Try to find Pure in common locations
    local pure_paths=(
        "$HOME/.zsh/pure"
        "$HOME/.local/share/zsh/pure"
        "/usr/local/share/zsh/pure"
        "/usr/share/zsh/pure"
    )
    
    local pure_dir=""
    for path in "${pure_paths[@]}"; do
        if [ -d "$path" ]; then
            pure_dir="$path"
            break
        fi
    done
    
    # If not found, try to clone it
    if [ -z "$pure_dir" ]; then
        pure_dir="$HOME/.zsh/pure"
        if [ ! -d "$pure_dir" ]; then
            mkdir -p "$(dirname "$pure_dir")"
            git clone --quiet https://github.com/sindresorhus/pure.git "$pure_dir" 2>/dev/null
        fi
    fi
    
    # Load Pure if found
    if [ -d "$pure_dir" ]; then
        # Load async first (required by Pure)
        if [ -f "$pure_dir/async.zsh" ]; then
            source "$pure_dir/async.zsh"
        fi
        
        # Load Pure prompt
        if [ -f "$pure_dir/pure.zsh" ]; then
            source "$pure_dir/pure.zsh"
            # Initialize Pure prompt
            promptinit
            prompt pure
            return 0
        fi
    fi
    
    return 1
}

# Lazy load Pure prompt
if ! _load_pure_prompt; then
    # Fallback to simple prompt if Pure fails to load
    PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '
fi
