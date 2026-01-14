#!/usr/bin/env bash
# Pure-inspired prompt for bash
# A minimal, fast prompt similar to Pure (https://github.com/sindresorhus/pure)
# Since Pure is ZSH-only, this provides a bash-compatible alternative

# Colors
PURE_BLUE='\[\033[0;34m\]'
PURE_GREEN='\[\033[0;32m\]'
PURE_YELLOW='\[\033[0;33m\]'
PURE_RED='\[\033[0;31m\]'
PURE_CYAN='\[\033[0;36m\]'
PURE_MAGENTA='\[\033[0;35m\]'
PURE_RESET='\[\033[0m\]'
PURE_GRAY='\[\033[0;90m\]'

# Git functions for prompt
_pure_bash_git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        echo "$branch"
    fi
}

_pure_bash_git_dirty() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
            echo "*"
        fi
    fi
}

_pure_bash_git_arrows() {
    local arrows=""
    local status=$(git status -sb 2>/dev/null | head -1)
    
    if [[ "$status" =~ ahead ]]; then
        arrows+="⇡"
    fi
    if [[ "$status" =~ behind ]]; then
        arrows+="⇣"
    fi
    
    echo "$arrows"
}

# Build the prompt
_pure_bash_prompt() {
    local exit_code=$?
    local prompt_symbol="❯"
    local user_host=""
    local path_info=""
    local git_info=""
    local exec_time=""
    
    # User and host (only show if SSH or different user)
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ "$USER" != "$(logname 2>/dev/null || echo "$USER")" ]; then
        user_host="${PURE_GRAY}${USER}@${HOSTNAME%%.*}${PURE_RESET} "
    fi
    
    # Current directory (shortened)
    local dir="${PWD/#$HOME/~}"
    path_info="${PURE_BLUE}${dir}${PURE_RESET}"
    
    # Git information
    local branch=$(_pure_bash_git_branch)
    if [ -n "$branch" ]; then
        local dirty=$(_pure_bash_git_dirty)
        local arrows=$(_pure_bash_git_arrows)
        git_info=" ${PURE_GRAY}${branch}${dirty:+${PURE_YELLOW}${dirty}}${arrows:+ ${PURE_CYAN}${arrows}}${PURE_RESET}"
    fi
    
    # Prompt symbol color based on exit code
    if [ $exit_code -eq 0 ]; then
        prompt_symbol="${PURE_MAGENTA}${prompt_symbol}${PURE_RESET}"
    else
        prompt_symbol="${PURE_RED}${prompt_symbol}${PURE_RESET}"
    fi
    
    # Build PS1
    PS1="${user_host}${path_info}${git_info}\n${prompt_symbol} "
}

# Set up the prompt
# If PROMPT_COMMAND is already set (e.g., by env_manager), append to it
if [ -n "$PROMPT_COMMAND" ]; then
    PROMPT_COMMAND="$PROMPT_COMMAND; _pure_bash_prompt"
else
    PROMPT_COMMAND="_pure_bash_prompt"
fi
