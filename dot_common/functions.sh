#!/usr/bin/env bash
# Cross-platform functions that work in both zsh and bash
# Based on renemarc/dotfiles structure

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    IS_MACOS=true
    IS_LINUX=false
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    IS_MACOS=false
    IS_LINUX=true
else
    IS_MACOS=false
    IS_LINUX=false
fi

# ============================================================================
# File Operations
# ============================================================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1" || return 1
}

# Extract various archive formats
extract() {
    if [ -z "$1" ]; then
        echo "Usage: extract <archive>"
        return 1
    fi
    
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
        return 1
    fi
}

# ============================================================================
# System Information
# ============================================================================

# Display PATH entries on separate lines
path() {
    echo -e "${PATH//:/\\n}"
}

# System information (uses available tool)
# Unalias first to avoid conflicts if alias was set before function
sysinfo() {
    # Remove alias if it exists (to avoid conflicts)
    unalias sysinfo 2>/dev/null || true
    
    if command -v neofetch >/dev/null 2>&1; then
        neofetch
    elif command -v screenfetch >/dev/null 2>&1; then
        screenfetch
    elif command -v winfetch >/dev/null 2>&1; then
        winfetch
    else
        echo "No system info tool available. Install neofetch, screenfetch, or winfetch."
        return 1
    fi
}

# ============================================================================
# Process Management
# ============================================================================

# Find process by name
psgrep() {
    if [ -z "$1" ]; then
        echo "Usage: psgrep <process_name>"
        return 1
    fi
    ps aux | grep -i "$1" | grep -v grep
}

# Kill process by name
pkill() {
    if [ -z "$1" ]; then
        echo "Usage: pkill <process_name>"
        return 1
    fi
    local pids
    pids=$(ps aux | grep -i "$1" | grep -v grep | awk '{print $2}')
    if [ -z "$pids" ]; then
        echo "No processes found matching '$1'"
        return 1
    fi
    echo "Killing processes: $pids"
    echo "$pids" | xargs kill -9
}

# ============================================================================
# Development Tools
# ============================================================================

# Git functions
gac() {
    if [ -z "$1" ]; then
        echo "Usage: gac <message>"
        return 1
    fi
    # Ensure git is configured before committing
    if command -v git >/dev/null 2>&1; then
        if [ -n "${GIT_USER_NAME:-}" ] || [ -n "${USER_NAME:-}" ]; then
            git config --global user.name "${GIT_USER_NAME:-${USER_NAME:-}}" 2>/dev/null || true
        fi
        if [ -n "${GIT_USER_EMAIL:-}" ] || [ -n "${USER_EMAIL:-}" ]; then
            git config --global user.email "${GIT_USER_EMAIL:-${USER_EMAIL:-}}" 2>/dev/null || true
        fi
    fi
    git add --all && git commit -m "$1"
}

gacp() {
    if [ -z "$1" ]; then
        echo "Usage: gacp <message>"
        return 1
    fi
    # Ensure git is configured before committing
    if command -v git >/dev/null 2>&1; then
        if [ -n "${GIT_USER_NAME:-}" ] || [ -n "${USER_NAME:-}" ]; then
            git config --global user.name "${GIT_USER_NAME:-${USER_NAME:-}}" 2>/dev/null || true
        fi
        if [ -n "${GIT_USER_EMAIL:-}" ] || [ -n "${USER_EMAIL:-}" ]; then
            git config --global user.email "${GIT_USER_EMAIL:-${USER_EMAIL:-}}" 2>/dev/null || true
        fi
    fi
    git add --all && git commit -m "$1" && git push
}

# Create Python virtual environment and activate
venv() {
    local venv_name="${1:-venv}"
    python3 -m venv "$venv_name"
    if [ -f "$venv_name/bin/activate" ]; then
        source "$venv_name/bin/activate"
        echo "Virtual environment '$venv_name' created and activated"
    else
        echo "Failed to create virtual environment"
        return 1
    fi
}

# ============================================================================
# Network Utilities
# ============================================================================

# Get local IP address
localip() {
    if [ "$IS_MACOS" = true ]; then
        ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1
    elif [ "$IS_LINUX" = true ]; then
        ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -1
    fi
}

# Get public IP address
publicip() {
    curl -s ifconfig.me || curl -s icanhazip.com || curl -s ipinfo.io/ip
}

# Port check
port() {
    if [ -z "$1" ]; then
        echo "Usage: port <port_number>"
        return 1
    fi
    if [ "$IS_MACOS" = true ]; then
        lsof -i :"$1"
    elif [ "$IS_LINUX" = true ]; then
        netstat -tuln | grep ":$1 "
    fi
}

# ============================================================================
# File Search
# ============================================================================

# Find files by name (case-insensitive)
ff() {
    if [ -z "$1" ]; then
        echo "Usage: ff <filename>"
        return 1
    fi
    find . -iname "*$1*" 2>/dev/null
}

# Find files by extension
ffe() {
    if [ -z "$1" ]; then
        echo "Usage: ffe <extension>"
        return 1
    fi
    find . -name "*.$1" 2>/dev/null
}

# ============================================================================
# Text Processing
# ============================================================================

# Count lines of code in a directory
loc() {
    local dir="${1:-.}"
    find "$dir" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" -o -name "*.cpp" -o -name "*.c" -o -name "*.go" -o -name "*.rs" -o -name "*.rb" \) | xargs wc -l 2>/dev/null | tail -1
}

# ============================================================================
# Weather
# ============================================================================

# Current weather
weather() {
    local location="${1:-}"
    if [ -z "$location" ]; then
        curl -s "wttr.in/?format=%l:+%28%C%29+%c++%t+%5B%h,+%w%5D"
    else
        curl -s "wttr.in/$location?format=%l:+%28%C%29+%c++%t+%5B%h,+%w%5D"
    fi
}

# Weather forecast
forecast() {
    local location="${1:-}"
    if [ -z "$location" ]; then
        curl -s "wttr.in/?n"
    else
        curl -s "wttr.in/$location?n"
    fi
}

# ============================================================================
# System Updates
# ============================================================================

# Update system packages (OS-specific)
# Unalias first to avoid conflicts if alias was set before function
update() {
    # Remove alias if it exists (to avoid conflicts)
    unalias update 2>/dev/null || true
    
    if [ "$IS_MACOS" = true ]; then
        if command -v brew >/dev/null 2>&1; then
            echo "Updating Homebrew..."
            brew update
            brew upgrade
            brew cleanup
        else
            echo "Homebrew not found"
            return 1
        fi
    elif [ "$IS_LINUX" = true ]; then
        if command -v apt >/dev/null 2>&1; then
            echo "Updating apt packages..."
            sudo apt update && sudo apt upgrade -y
        elif command -v yum >/dev/null 2>&1; then
            echo "Updating yum packages..."
            sudo yum update -y
        elif command -v dnf >/dev/null 2>&1; then
            echo "Updating dnf packages..."
            sudo dnf update -y
        else
            echo "No supported package manager found"
            return 1
        fi
    else
        echo "Unsupported operating system"
        return 1
    fi
}

# ============================================================================
# Directory Navigation
# ============================================================================

# Quick directory bookmarking (simple version)
# Note: For more advanced bookmarking, consider using tools like 'autojump' or 'z'
bookmark() {
    if [ -z "$1" ]; then
        echo "Usage: bookmark <name>"
        echo "Saves current directory as bookmark"
        return 1
    fi
    local bookmark_file="$HOME/.bookmarks"
    echo "cd $(pwd)" >> "$bookmark_file"
    echo "Bookmark '$1' saved: $(pwd)"
}

# ============================================================================
# Utility Functions
# ============================================================================

# Create a backup of a file
backup() {
    if [ -z "$1" ]; then
        echo "Usage: backup <file>"
        return 1
    fi
    if [ -f "$1" ]; then
        cp "$1" "$1.backup"
        echo "Backup created: $1.backup"
    else
        echo "File not found: $1"
        return 1
    fi
}

# Reload shell configuration
# Unalias first to avoid conflicts if alias was set before function
# This must be done BEFORE defining the function in zsh
if [ -n "$ZSH_VERSION" ]; then
    unalias reload 2>/dev/null || true
elif [ -n "$BASH_VERSION" ]; then
    unalias reload 2>/dev/null || true
fi

reload() {
    if [ -n "$ZSH_VERSION" ]; then
        source ~/.zshrc
        echo "Zsh configuration reloaded"
    elif [ -n "$BASH_VERSION" ]; then
        source ~/.bashrc
        echo "Bash configuration reloaded"
    fi
}
