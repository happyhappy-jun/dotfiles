#!/usr/bin/env bash
# Starship prompt setup for both zsh and bash
# This file initializes Starship prompt (https://starship.rs/)
# Uses Pure preset theme for a clean, minimal look

# Function to initialize Starship
_init_starship() {
    # Check if Starship is installed
    if ! command -v starship >/dev/null 2>&1; then
        return 1
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
        autoload -Uz promptinit
        promptinit
        prompt off 2>/dev/null || true
        
        # Initialize Starship
        eval "$(starship init zsh)"
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
        
        # Initialize Starship
        eval "$(starship init bash)"
        return 0
    fi
    
    return 1
}

# Initialize Starship prompt
if ! _init_starship; then
    # Fallback prompts if Starship is not available
    if [ -n "$ZSH_VERSION" ]; then
        PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '
    elif [ -n "$BASH_VERSION" ]; then
        export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    fi
fi
