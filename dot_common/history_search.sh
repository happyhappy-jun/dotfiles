#!/usr/bin/env bash
# History substring search for both zsh and bash
# Allows searching through command history by typing part of a command
# Use Up/Down arrow keys to navigate through matching history entries

if [ -n "$ZSH_VERSION" ]; then
    # ============================================================================
    # Zsh History Substring Search
    # ============================================================================
    
    # Enable history substring search using zsh's built-in functionality
    # This allows searching history by typing part of a command and using arrow keys
    
    # Store the current search string and position
    _HISTORY_SUBSTRING_SEARCH_QUERY=""
    _HISTORY_SUBSTRING_SEARCH_INDEX=0
    
    # Function for history substring search (backward)
    _history_substring_search_backward() {
        # Get the current line content up to cursor
        local buffer_text="${BUFFER:0:$CURSOR}"
        
        if [ -z "$buffer_text" ]; then
            # If buffer is empty, use normal history search
            zle up-line-or-history
            return
        fi
        
        # If search string changed, reset search
        if [ "$_HISTORY_SUBSTRING_SEARCH_QUERY" != "$buffer_text" ]; then
            _HISTORY_SUBSTRING_SEARCH_QUERY="$buffer_text"
            _HISTORY_SUBSTRING_SEARCH_INDEX=0
        fi
        
        # Get history size
        local hist_size=$(fc -l | wc -l)
        local found=0
        local start_pos=${_HISTORY_SUBSTRING_SEARCH_INDEX:-$hist_size}
        
        # Search backward through history for entries containing the buffer text
        for ((i=start_pos-1; i>=1; i--)); do
            local hist_entry=$(fc -l -n $i $i 2>/dev/null | sed 's/^[[:space:]]*//')
            
            if [[ "$hist_entry" == *"$buffer_text"* ]]; then
                BUFFER="$hist_entry"
                CURSOR=${#BUFFER}
                _HISTORY_SUBSTRING_SEARCH_INDEX=$i
                found=1
                break
            fi
        done
        
        if [ $found -eq 0 ]; then
            # If no match found, beep
            zle beep
        fi
    }
    
    # Function for history substring search (forward)
    _history_substring_search_forward() {
        # Get the current line content up to cursor
        local buffer_text="${BUFFER:0:$CURSOR}"
        
        if [ -z "$buffer_text" ]; then
            # If buffer is empty, use normal history search
            zle down-line-or-history
            return
        fi
        
        # If search string changed, reset search
        if [ "$_HISTORY_SUBSTRING_SEARCH_QUERY" != "$buffer_text" ]; then
            _HISTORY_SUBSTRING_SEARCH_QUERY="$buffer_text"
            local hist_size=$(fc -l | wc -l)
            _HISTORY_SUBSTRING_SEARCH_INDEX=$hist_size
        fi
        
        # Get history size
        local hist_size=$(fc -l | wc -l)
        local found=0
        local start_pos=${_HISTORY_SUBSTRING_SEARCH_INDEX:-1}
        
        # Search forward through history for entries containing the buffer text
        for ((i=start_pos+1; i<=hist_size; i++)); do
            local hist_entry=$(fc -l -n $i $i 2>/dev/null | sed 's/^[[:space:]]*//')
            
            if [[ "$hist_entry" == *"$buffer_text"* ]]; then
                BUFFER="$hist_entry"
                CURSOR=${#BUFFER}
                _HISTORY_SUBSTRING_SEARCH_INDEX=$i
                found=1
                break
            fi
        done
        
        if [ $found -eq 0 ]; then
            # If no match found, beep
            zle beep
        fi
    }
    
    # Create zle widgets
    zle -N _history_substring_search_backward
    zle -N _history_substring_search_forward
    
    # Bind to Up and Down arrow keys
    # Try multiple key codes for different terminal types
    bindkey '^[[A' _history_substring_search_backward   # Up arrow (most terminals)
    bindkey '^[[B' _history_substring_search_forward   # Down arrow (most terminals)
    bindkey '^[OA' _history_substring_search_backward   # Up arrow (some terminals)
    bindkey '^[OB' _history_substring_search_forward   # Down arrow (some terminals)
    
    # Also bind to Page Up/Down for alternative navigation
    bindkey '^[[5~' _history_substring_search_backward   # Page Up
    bindkey '^[[6~' _history_substring_search_forward   # Page Down
    
elif [ -n "$BASH_VERSION" ]; then
    # ============================================================================
    # Bash History Substring Search
    # ============================================================================
    
    # Enable history substring search for bash
    # This allows searching history by typing part of a command and using arrow keys
    
    # Store the current search string and position
    _HISTORY_SEARCH_STRING=""
    _HISTORY_SEARCH_INDEX=0
    
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
            _HISTORY_SEARCH_INDEX=$HISTCMD
        fi
        
        # Search backward from current position
        local found=0
        local start_index=${_HISTORY_SEARCH_INDEX:-$HISTCMD}
        
        for ((i=start_index-1; i>=1; i--)); do
            # Get history entry without line number
            local hist_entry=$(HISTTIMEFORMAT= history $i | sed 's/^[ ]*[0-9]*[ ]*//')
            if [[ "$hist_entry" == *"$current_line"* ]]; then
                READLINE_LINE="$hist_entry"
                READLINE_POINT=${#READLINE_LINE}
                _HISTORY_SEARCH_INDEX=$i
                found=1
                break
            fi
        done
        
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
            _HISTORY_SEARCH_INDEX=1
        fi
        
        # Search forward from current position
        local found=0
        local start_index=${_HISTORY_SEARCH_INDEX:-1}
        
        for ((i=start_index+1; i<=HISTCMD; i++)); do
            # Get history entry without line number
            local hist_entry=$(HISTTIMEFORMAT= history $i | sed 's/^[ ]*[0-9]*[ ]*//')
            if [[ "$hist_entry" == *"$current_line"* ]]; then
                READLINE_LINE="$hist_entry"
                READLINE_POINT=${#READLINE_LINE}
                _HISTORY_SEARCH_INDEX=$i
                found=1
                break
            fi
        done
        
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
    
    # Also bind Ctrl-Up and Ctrl-Down as alternatives
    bind -x '"\e[1;5A": _history_search_backward' 2>/dev/null || true
    bind -x '"\e[1;5B": _history_search_forward' 2>/dev/null || true
fi
