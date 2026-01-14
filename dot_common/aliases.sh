#!/usr/bin/env bash
# Cross-platform aliases that work in both zsh and bash
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

# List files with colors and details
if [ "$IS_MACOS" = true ]; then
    # macOS: use gls if available (from coreutils), otherwise ls
    if command -v gls >/dev/null 2>&1; then
        alias ls='gls --color=auto'
        alias ll='gls -lh --color=auto'
        alias la='gls -lah --color=auto'
    else
        alias ls='ls -G'
        alias ll='ls -lhG'
        alias la='ls -lahG'
    fi
else
    # Linux: standard ls with colors
    alias ls='ls --color=auto'
    alias ll='ls -lh --color=auto'
    alias la='ls -lah --color=auto'
fi

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Common paths
alias dls='cd ~/Downloads'
alias docs='cd ~/Documents'
alias dt='cd ~/Desktop'
alias repos='cd ~/Code 2>/dev/null || cd ~/repos 2>/dev/null || cd ~/Projects 2>/dev/null'
alias archives='cd ~/Archives 2>/dev/null || cd ~/archive 2>/dev/null'

# ============================================================================
# System Information
# ============================================================================

# System info (lazy loaded - uses neofetch, screenfetch, or winfetch)
alias sysinfo='command -v neofetch >/dev/null 2>&1 && neofetch || command -v screenfetch >/dev/null 2>&1 && screenfetch || command -v winfetch >/dev/null 2>&1 && winfetch || echo "No system info tool available"'

# Process monitoring (lazy loaded)
alias top='command -v htop >/dev/null 2>&1 && htop || command -v atop >/dev/null 2>&1 && atop || command top'

# ============================================================================
# Development Tools
# ============================================================================

# Git aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gb='git branch'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log'
alias gpl='git pull'
alias gps='git push'
alias gs='git status'
alias gst='git status'

# Docker aliases
alias dk='docker'
alias dco='docker-compose'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dcb='docker-compose build'

# Python virtual environments
alias va='source venv/bin/activate 2>/dev/null || source .venv/bin/activate 2>/dev/null || echo "No virtual environment found"'
alias ve='python3 -m venv venv'

# ============================================================================
# Applications
# ============================================================================

# Browser commands (OS-specific)
if [ "$IS_MACOS" = true ]; then
    alias browse='open'
    alias chrome='open -a "Google Chrome"'
    alias firefox='open -a Firefox'
    alias safari='open -a Safari'
    alias edge='open -a "Microsoft Edge"'
    alias opera='open -a Opera'
elif [ "$IS_LINUX" = true ]; then
    alias browse='xdg-open'
    alias chrome='google-chrome 2>/dev/null || chromium-browser 2>/dev/null || chromium 2>/dev/null || echo "Chrome not found"'
    alias firefox='firefox'
    alias edge='microsoft-edge 2>/dev/null || echo "Edge not found"'
    alias opera='opera 2>/dev/null || echo "Opera not found"'
fi

# Editor aliases
alias subl='sublime_text 2>/dev/null || subl 2>/dev/null || echo "Sublime Text not found"'
alias sublst='subl'

# ============================================================================
# Utilities
# ============================================================================

# Clipboard operations (OS-specific)
if [ "$IS_MACOS" = true ]; then
    alias cb='pbcopy'
    alias cbpaste='pbpaste'
elif [ "$IS_LINUX" = true ]; then
    if command -v xclip >/dev/null 2>&1; then
        alias cb='xclip -selection clipboard'
        alias cbpaste='xclip -selection clipboard -o'
    elif command -v xsel >/dev/null 2>&1; then
        alias cb='xsel --clipboard --input'
        alias cbpaste='xsel --clipboard --output'
    fi
fi

# Hash calculations
alias md5sum='command -v md5 >/dev/null 2>&1 && md5 || md5sum'
alias sha1sum='command -v shasum >/dev/null 2>&1 && shasum -a 1 || sha1sum'
alias sha256sum='command -v shasum >/dev/null 2>&1 && shasum -a 256 || sha256sum'

# Weather (using wttr.in)
alias weather='curl -s "wttr.in/?format=%l:+%28%C%29+%c++%t+%5B%h,+%w%5D"'
alias forecast='curl -s "wttr.in/?n"'

# ============================================================================
# Configuration Paths
# ============================================================================

# Navigate to configuration directories
alias chezmoiconf='cd ~/.config/chezmoi 2>/dev/null || cd "$(chezmoi source-path)" 2>/dev/null || echo "Chezmoi config not found"'
alias powershellconf='cd ~/.config/powershell 2>/dev/null || cd "$HOME/Documents/PowerShell" 2>/dev/null || echo "PowerShell config not found"'
alias sublimeconf='cd ~/.config/sublime-text 2>/dev/null || cd "$HOME/Library/Application Support/Sublime Text" 2>/dev/null || echo "Sublime Text config not found"'

# ============================================================================
# macOS Specific
# ============================================================================

if [ "$IS_MACOS" = true ]; then
    # Toggle desktop icons
    alias hidedesktop='defaults write com.apple.finder CreateDesktop false && killall Finder'
    alias showdesktop='defaults write com.apple.finder CreateDesktop true && killall Finder'
    
    # Toggle hidden files in Finder
    alias hidefiles='defaults write com.apple.finder AppleShowAllFiles false && killall Finder'
    alias showfiles='defaults write com.apple.finder AppleShowAllFiles true && killall Finder'
    
    # Toggle Spotlight
    alias spotoff='sudo mdutil -a -i off'
    alias spoton='sudo mdutil -a -i on'
fi

# ============================================================================
# Linux Specific
# ============================================================================

if [ "$IS_LINUX" = true ]; then
    # Update system packages
    alias update='sudo apt update && sudo apt upgrade -y'
    
    # Show hidden files in file manager (if using Nautilus)
    alias showfiles='gsettings set org.gnome.nautilus.preferences show-hidden-files true'
    alias hidefiles='gsettings set org.gnome.nautilus.preferences show-hidden-files false'
fi

# ============================================================================
# Safety Aliases
# ============================================================================

# Confirm before overwriting
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# ============================================================================
# Convenience Aliases
# ============================================================================

# Clear screen
alias c='clear'
alias cl='clear'

# History
alias h='history'
alias hg='history | grep'

# PATH display (function defined in functions.sh, no alias to avoid conflict)
# Use 'path' function instead of alias

# Reload shell configuration
if [ -n "$ZSH_VERSION" ]; then
    alias reload='source ~/.zshrc'
elif [ -n "$BASH_VERSION" ]; then
    alias reload='source ~/.bashrc'
fi
