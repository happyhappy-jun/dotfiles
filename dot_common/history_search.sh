#!/usr/bin/env bash
# History substring search for both zsh and bash
# Allows searching through command history by typing part of a command
# Use Up/Down arrow keys to navigate through matching history entries

if [ -n "$ZSH_VERSION" ]; then
    # ============================================================================
    # Zsh History Substring Search
    # Uses the official zsh-history-substring-search plugin
    # https://github.com/zsh-users/zsh-history-substring-search
    # ============================================================================
    
    # Try multiple possible locations for the plugin
    HISTORY_SEARCH_PLUGIN=""
    for dir in \
        "$HOME/.zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" \
        "$HOME/.oh-my-zsh/custom/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" \
        "$HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh" \
        "/usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh" \
        "/opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh"; do
        if [ -f "$dir" ]; then
            HISTORY_SEARCH_PLUGIN="$dir"
            break
        fi
    done
    
    # Load the plugin if found
    if [ -n "$HISTORY_SEARCH_PLUGIN" ]; then
        source "$HISTORY_SEARCH_PLUGIN"
        
        # Bind keys for history substring search
        # Try multiple key codes for different terminal types
        bindkey '^[[A' history-substring-search-up      # Up arrow (most terminals)
        bindkey '^[[B' history-substring-search-down    # Down arrow (most terminals)
        bindkey '^[OA' history-substring-search-up     # Up arrow (some terminals)
        bindkey '^[OB' history-substring-search-down    # Down arrow (some terminals)
        
        # Also bind Ctrl-P/N for emacs mode
        bindkey -M emacs '^P' history-substring-search-up
        bindkey -M emacs '^N' history-substring-search-down
        
        # Configuration options
        # Highlight found matches
        HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=magenta,fg=white,bold'
        # Highlight when no matches found
        HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'
        # Case-insensitive search
        HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS='i'
        # Ensure unique results
        HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
    else
        # Fallback: Use built-in zsh history search if plugin not found
        autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search
        
        bindkey '^[[A' up-line-or-beginning-search
        bindkey '^[[B' down-line-or-beginning-search
        bindkey '^[OA' up-line-or-beginning-search
        bindkey '^[OB' down-line-or-beginning-search
    fi
    
elif [ -n "$BASH_VERSION" ]; then
    # ============================================================================
    # Bash History Search
    # ============================================================================
    
    # Enable history search for bash
    # Type a few characters and press Up/Down arrow to search through history
    # matching commands that start with those characters
    
    # Bind Up/Down arrow keys to history-search-backward/forward
    # This searches history for commands starting with the current line prefix
    if [[ ${SHELLOPTS} =~ (vi|emacs) ]]; then
        # Standard terminal escape codes
        bind '"\e[A": history-search-backward'
        bind '"\e[B": history-search-forward'
        # Alternative escape codes (some terminals)
        bind '"\eOA": history-search-backward'
        bind '"\eOB": history-search-forward'
    fi
fi
