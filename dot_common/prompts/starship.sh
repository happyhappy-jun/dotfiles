#!/usr/bin/env bash
# Starship prompt setup for both zsh and bash
# This file initializes Starship prompt (https://starship.rs/)
# Uses Pure preset theme for a clean, minimal look

# Function to install Starship if not present
_install_starship() {
    # Check if Starship is already installed
    if command -v starship >/dev/null 2>&1; then
        return 0
    fi
    
    echo "Starship not found. Installing Starship..."
    
    # Try to find and run the installation script
    # Note: chezmoi manages run_once_before_ scripts automatically
    # This is a fallback if the script hasn't been run yet
    local install_script=""
    for script_path in \
        "$(chezmoi source-path 2>/dev/null)/run_once_before_install_starship.sh" \
        "$HOME/.local/share/chezmoi/run_once_before_install_starship.sh"; do
        if [ -f "$script_path" ]; then
            install_script="$script_path"
            break
        fi
    done
    
    # If installation script found, run it
    if [ -n "$install_script" ] && [ -f "$install_script" ]; then
        bash "$install_script" 2>/dev/null || {
            # If script fails, try direct installation
            if command -v curl >/dev/null 2>&1; then
                curl -sS https://starship.rs/install.sh | sh 2>/dev/null || return 1
            elif command -v wget >/dev/null 2>&1; then
                wget -qO- https://starship.rs/install.sh | sh 2>/dev/null || return 1
            else
                return 1
            fi
        }
    else
        # No installation script found, use direct installation
        if command -v curl >/dev/null 2>&1; then
            curl -sS https://starship.rs/install.sh | sh 2>/dev/null || return 1
        elif command -v wget >/dev/null 2>&1; then
            wget -qO- https://starship.rs/install.sh | sh 2>/dev/null || return 1
        else
            return 1
        fi
    fi
    
    # Ensure ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    # Verify installation
    if command -v starship >/dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# Function to initialize Starship
_init_starship() {
    # Check if Starship is installed, install if not
    if ! command -v starship >/dev/null 2>&1; then
        # Try to install Starship
        if ! _install_starship; then
            return 1
        fi
    fi
    
    # Initialize Starship based on shell
    if [ -n "$ZSH_VERSION" ]; then
        # Zsh initialization
        # First, ensure Pure prompt is not loaded
        # Unset Pure prompt variables if they exist
        unset PURE_PROMPT_SYMBOL 2>/dev/null || true
        unset PURE_GIT_DOWN_ARROW 2>/dev/null || true
        unset PURE_GIT_UP_ARROW 2>/dev/null || true
        
        # Reset prompt to default before initializing Starship
        # This prevents conflicts with Pure prompt
        # Use safe error handling to prevent shell exit
        {
            autoload -Uz promptinit 2>/dev/null && promptinit 2>/dev/null && prompt off 2>/dev/null
        } || true
        
        # Ensure Starship config exists with Pure preset
        # Create config directory if it doesn't exist
        mkdir -p "$HOME/.config" 2>/dev/null || true
        
        # Check if config exists and has Pure preset
        # If not, create/update it with Pure preset
        if [ ! -f "$HOME/.config/starship.toml" ]; then
            # Config doesn't exist, create with Pure preset
            if command -v starship >/dev/null 2>&1; then
                starship preset pure-preset -o "$HOME/.config/starship.toml" 2>/dev/null || {
                    # If preset fails, create empty config (Starship will use defaults)
                    touch "$HOME/.config/starship.toml" 2>/dev/null || true
                }
            else
                # Starship not installed yet, create empty config
                touch "$HOME/.config/starship.toml" 2>/dev/null || true
            fi
        else
            # Config exists - check if it's using Pure preset
            # If config doesn't contain "pure" indicators, update it
            # Use safe grep with proper error handling
            if command -v starship >/dev/null 2>&1 && [ -f "$HOME/.config/starship.toml" ]; then
                if ! grep -qE '(format|character|git_branch|git_status|directory).*pure' "$HOME/.config/starship.toml" 2>/dev/null && \
                   ! grep -qE '\[character\]' "$HOME/.config/starship.toml" 2>/dev/null; then
                    # Config exists but doesn't look like Pure preset, update it
                    # Backup existing config first
                    cp "$HOME/.config/starship.toml" "$HOME/.config/starship.toml.bak" 2>/dev/null || true
                    # Apply Pure preset
                    starship preset pure-preset -o "$HOME/.config/starship.toml" 2>/dev/null || true
                fi
            fi
        fi
        
        # Initialize Starship
        if command -v starship >/dev/null 2>&1; then
            eval "$(starship init zsh)" 2>/dev/null || return 1
        else
            return 1
        fi
        return 0
    elif [ -n "$BASH_VERSION" ]; then
        # Bash initialization
        # Reset PROMPT_COMMAND to remove any Pure prompt hooks
        # (Keep env_manager hook if it exists)
        if [[ "$PROMPT_COMMAND" == *"_pure_bash_prompt"* ]]; then
            PROMPT_COMMAND="${PROMPT_COMMAND//_pure_bash_prompt/}"
            PROMPT_COMMAND="${PROMPT_COMMAND//;;/;}"
            PROMPT_COMMAND="${PROMPT_COMMAND#;}"
        fi
        
        # Ensure Starship config exists with Pure preset
        # Create config directory if it doesn't exist
        mkdir -p "$HOME/.config" 2>/dev/null || true
        
        # Check if config exists and has Pure preset
        # If not, create/update it with Pure preset
        if [ ! -f "$HOME/.config/starship.toml" ]; then
            # Config doesn't exist, create with Pure preset
            if starship preset pure-preset -o "$HOME/.config/starship.toml" 2>/dev/null; then
                : # Config created successfully
            else
                # If preset fails, create empty config (Starship will use defaults)
                touch "$HOME/.config/starship.toml" 2>/dev/null || true
            fi
        else
            # Config exists - check if it's using Pure preset
            # If config doesn't contain "pure" indicators, update it
            # Use safe grep with proper error handling
            if command -v starship >/dev/null 2>&1 && [ -f "$HOME/.config/starship.toml" ]; then
                if ! grep -qE '(format|character|git_branch|git_status|directory).*pure' "$HOME/.config/starship.toml" 2>/dev/null && \
                   ! grep -qE '\[character\]' "$HOME/.config/starship.toml" 2>/dev/null; then
                    # Config exists but doesn't look like Pure preset, update it
                    # Backup existing config first
                    cp "$HOME/.config/starship.toml" "$HOME/.config/starship.toml.bak" 2>/dev/null || true
                    # Apply Pure preset
                    starship preset pure-preset -o "$HOME/.config/starship.toml" 2>/dev/null || true
                fi
            fi
        fi
        
        # Initialize Starship
        if command -v starship >/dev/null 2>&1; then
            eval "$(starship init bash)" 2>/dev/null || return 1
        else
            return 1
        fi
        return 0
    fi
    
    return 1
}

# Initialize Starship prompt
if ! _init_starship; then
    # Fallback prompts if Starship is not available
    if [ -n "$ZSH_VERSION" ]; then
        # Check if Starship is installed but failed to initialize
        if command -v starship >/dev/null 2>&1; then
            # Starship is installed but initialization failed
            # Try direct initialization as fallback
            eval "$(starship init zsh)" 2>/dev/null || {
                PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '
            }
        else
            # Starship not installed, use simple prompt
            PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '
        fi
    elif [ -n "$BASH_VERSION" ]; then
        # Check if Starship is installed but failed to initialize
        if command -v starship >/dev/null 2>&1; then
            # Starship is installed but initialization failed
            # Try direct initialization as fallback
            eval "$(starship init bash)" 2>/dev/null || {
                export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
            }
        else
            # Starship not installed, use simple prompt
            export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
        fi
    fi
fi
