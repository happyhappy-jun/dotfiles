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
    # Bash History Substring Search
    # ============================================================================
    
    # Enable history substring search for bash
    # This allows searching history by typing part of a command and using arrow keys
    
    # Store the current search string and position
    _HISTORY_SEARCH_STRING=""
    _HISTORY_SEARCH_INDEX=-1
    
    # Function to search backward through history
    _history_search_backward() {
        local current_line="${READLINE_LINE:0:$READLINE_POINT}"
        
        if [ -z "$current_line" ]; then
            # If line is empty, use normal history search
            bind '"\e[A": history-search-backward'
            return
        fi
        
        # If search string changed, reset index
        if [ "$_HISTORY_SEARCH_STRING" != "$current_line" ]; then
            _HISTORY_SEARCH_STRING="$current_line"
            _HISTORY_SEARCH_INDEX=-1
        fi
        
        # Get history entries using fc command (more reliable)
        # fc -ln lists history without line numbers, reverse order for backward search
        local hist_entries
        if command -v tac >/dev/null 2>&1; then
            hist_entries=$(fc -ln 1 2>/dev/null | tac)
        else
            # Fallback: use tail -r on macOS or sed to reverse
            if command -v tail >/dev/null 2>&1 && tail -r /dev/null 2>/dev/null; then
                hist_entries=$(fc -ln 1 2>/dev/null | tail -r)
            else
                # Use sed to reverse lines (less efficient but works everywhere)
                hist_entries=$(fc -ln 1 2>/dev/null | sed '1!G;h;$!d')
            fi
        fi
        
        if [ -z "$hist_entries" ]; then
            echo -ne '\007'
            return
        fi
        
        local found=0
        local skip_first=$((_HISTORY_SEARCH_INDEX >= 0 ? 1 : 0))
        local count=0
        
        # Search through history entries
        while IFS= read -r hist_entry; do
            if [ $skip_first -eq 1 ] && [ $count -le $_HISTORY_SEARCH_INDEX ]; then
                count=$((count + 1))
                continue
            fi
            
            count=$((count + 1))
            
            # Case-insensitive substring match
            if [[ "${hist_entry,,}" == *"${current_line,,}"* ]]; then
                READLINE_LINE="$hist_entry"
                READLINE_POINT=${#READLINE_LINE}
                _HISTORY_SEARCH_INDEX=$count
                found=1
                break
            fi
        done <<< "$hist_entries"
        
        if [ $found -eq 0 ]; then
            # If no match found, beep
            echo -ne '\007'
        fi
    }
    
    # Function to search forward through history
    _history_search_forward() {
        local current_line="${READLINE_LINE:0:$READLINE_POINT}"
        
        if [ -z "$current_line" ]; then
            # If line is empty, use normal history search
            bind '"\e[B": history-search-forward'
            return
        fi
        
        # If search string changed, reset index
        if [ "$_HISTORY_SEARCH_STRING" != "$current_line" ]; then
            _HISTORY_SEARCH_STRING="$current_line"
            _HISTORY_SEARCH_INDEX=-1
        fi
        
        # Get history entries (forward search, oldest first)
        local hist_entries
        hist_entries=$(fc -ln 1 2>/dev/null)
        
        if [ -z "$hist_entries" ]; then
            echo -ne '\007'
            return
        fi
        
        local found=0
        local count=0
        
        # Search forward through history entries
        while IFS= read -r hist_entry; do
            if [ $_HISTORY_SEARCH_INDEX -ge 0 ] && [ $count -le $_HISTORY_SEARCH_INDEX ]; then
                count=$((count + 1))
                continue
            fi
            
            count=$((count + 1))
            
            # Case-insensitive substring match
            if [[ "${hist_entry,,}" == *"${current_line,,}"* ]]; then
                READLINE_LINE="$hist_entry"
                READLINE_POINT=${#READLINE_LINE}
                _HISTORY_SEARCH_INDEX=$count
                found=1
                break
            fi
        done <<< "$hist_entries"
        
        if [ $found -eq 0 ]; then
            # If no match found, beep
            echo -ne '\007'
        fi
    }
    
    # Bind to Up and Down arrow keys using readline
    # Use bind -x to execute shell functions
    bind -x '"\e[A": _history_search_backward'
    bind -x '"\e[B": _history_search_forward'
    
    # Also try alternative key codes for different terminals
    bind -x '"\eOA": _history_search_backward' 2>/dev/null || true
    bind -x '"\eOB": _history_search_forward' 2>/dev/null || true
    
    # Enable history expansion for better history access
    set -o history
fi
