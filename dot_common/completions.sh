#!/usr/bin/env bash
# Autocomplete/Completion scripts loader
# This file automatically detects and loads completion scripts for various tools
# Works for both Zsh and Bash

# Function to safely source a completion script
_load_completion() {
    local completion_file="$1"
    if [ -f "$completion_file" ]; then
        # shellcheck source=/dev/null
        source "$completion_file" 2>/dev/null && return 0
    fi
    return 1
}

# Function to check if a command exists (for lazy loading)
_has_command() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================================================
# Git Completion
# ============================================================================
if _has_command git; then
    # Git completion locations (in order of preference)
    if [[ -n "$ZSH_VERSION" ]]; then
        # Zsh: Use built-in git completion or system completion
        if [ -f /usr/share/zsh/functions/Completion/Unix/_git ]; then
            # System zsh git completion
            fpath=(/usr/share/zsh/functions/Completion/Unix $fpath)
        elif [ -f /usr/local/share/zsh/site-functions/_git ]; then
            fpath=(/usr/local/share/zsh/site-functions $fpath)
        elif [ -f "$HOME/.zsh/completions/_git" ]; then
            fpath=("$HOME/.zsh/completions" $fpath)
        fi
    else
        # Bash: Load git completion
        _load_completion "$HOME/.git-completion.bash" || \
        _load_completion "/usr/share/bash-completion/completions/git" || \
        _load_completion "/usr/local/share/bash-completion/completions/git" || \
        _load_completion "/opt/homebrew/share/bash-completion/completions/git" || \
        _load_completion "/etc/bash_completion.d/git"
    fi
fi

# ============================================================================
# Docker & Docker Compose Completion
# ============================================================================
if _has_command docker; then
    if [[ -n "$ZSH_VERSION" ]]; then
        # Zsh: Docker completion
        _load_completion /usr/share/zsh/site-functions/_docker || \
        _load_completion /usr/local/share/zsh/site-functions/_docker || \
        _load_completion "$HOME/.zsh/completions/_docker"
    else
        # Bash: Docker completion
        _load_completion /usr/share/bash-completion/completions/docker || \
        _load_completion /usr/local/share/bash-completion/completions/docker || \
        _load_completion /opt/homebrew/share/bash-completion/completions/docker || \
        _load_completion /etc/bash_completion.d/docker
    fi
fi

if _has_command docker-compose; then
    if [[ -n "$ZSH_VERSION" ]]; then
        _load_completion /usr/share/zsh/site-functions/_docker-compose || \
        _load_completion /usr/local/share/zsh/site-functions/_docker-compose || \
        _load_completion "$HOME/.zsh/completions/_docker-compose"
    else
        _load_completion /usr/share/bash-completion/completions/docker-compose || \
        _load_completion /usr/local/share/bash-completion/completions/docker-compose || \
        _load_completion /opt/homebrew/share/bash-completion/completions/docker-compose
    fi
fi

# ============================================================================
# Kubernetes (kubectl) Completion
# ============================================================================
if _has_command kubectl; then
    if [[ -n "$ZSH_VERSION" ]]; then
        # Zsh: kubectl completion
        if [ -f "$HOME/.kubectl-completion.zsh" ]; then
            _load_completion "$HOME/.kubectl-completion.zsh"
        else
            # Generate completion if kubectl supports it
            if kubectl completion zsh >/dev/null 2>&1; then
                kubectl completion zsh > "$HOME/.kubectl-completion.zsh" 2>/dev/null && \
                _load_completion "$HOME/.kubectl-completion.zsh"
            fi
        fi
    else
        # Bash: kubectl completion
        if [ -f "$HOME/.kubectl-completion.bash" ]; then
            _load_completion "$HOME/.kubectl-completion.bash"
        else
            # Generate completion if kubectl supports it
            if kubectl completion bash >/dev/null 2>&1; then
                kubectl completion bash > "$HOME/.kubectl-completion.bash" 2>/dev/null && \
                _load_completion "$HOME/.kubectl-completion.bash"
            fi
        fi
    fi
fi

# ============================================================================
# Terraform Completion
# ============================================================================
if _has_command terraform; then
    if [[ -n "$ZSH_VERSION" ]]; then
        _load_completion "$HOME/.terraform-completion.zsh" || \
        _load_completion /usr/share/zsh/site-functions/_terraform || \
        _load_completion /usr/local/share/zsh/site-functions/_terraform
    else
        _load_completion "$HOME/.terraform-completion.bash" || \
        _load_completion /usr/share/bash-completion/completions/terraform || \
        _load_completion /usr/local/share/bash-completion/completions/terraform
    fi
    
    # Generate terraform completion if available
    if [ ! -f "$HOME/.terraform-completion.$([ -n "$ZSH_VERSION" ] && echo zsh || echo bash)" ]; then
        if terraform -help >/dev/null 2>&1; then
            terraform -install-autocomplete >/dev/null 2>&1 || true
        fi
    fi
fi

# ============================================================================
# AWS CLI Completion
# ============================================================================
if _has_command aws; then
    if [[ -n "$ZSH_VERSION" ]]; then
        _load_completion /usr/share/zsh/site-functions/_aws || \
        _load_completion /usr/local/share/zsh/site-functions/_aws || \
        _load_completion "$HOME/.zsh/completions/_aws"
    else
        _load_completion /usr/share/bash-completion/completions/aws || \
        _load_completion /usr/local/share/bash-completion/completions/aws || \
        _load_completion /opt/homebrew/share/bash-completion/completions/aws || \
        _load_completion /etc/bash_completion.d/aws
    fi
    
    # AWS CLI v2 completion
    if [ -f /usr/local/bin/aws_completer ] || [ -f /opt/homebrew/bin/aws_completer ]; then
        if [[ -n "$ZSH_VERSION" ]]; then
            # Zsh: aws_completer needs special handling
            if [ -f "$HOME/.aws-completion.zsh" ]; then
                _load_completion "$HOME/.aws-completion.zsh"
            fi
        else
            # Bash: aws_completer
            if [ -f /usr/local/bin/aws_completer ]; then
                complete -C /usr/local/bin/aws_completer aws
            elif [ -f /opt/homebrew/bin/aws_completer ]; then
                complete -C /opt/homebrew/bin/aws_completer aws
            fi
        fi
    fi
fi

# ============================================================================
# npm Completion
# ============================================================================
if _has_command npm; then
    if [[ -n "$ZSH_VERSION" ]]; then
        _load_completion /usr/share/zsh/site-functions/_npm || \
        _load_completion /usr/local/share/zsh/site-functions/_npm || \
        _load_completion "$HOME/.zsh/completions/_npm"
    else
        _load_completion /usr/share/bash-completion/completions/npm || \
        _load_completion /usr/local/share/bash-completion/completions/npm || \
        _load_completion /opt/homebrew/share/bash-completion/completions/npm
    fi
    
    # Generate npm completion if available
    if [ ! -f "$HOME/.npm-completion.$([ -n "$ZSH_VERSION" ] && echo zsh || echo bash)" ]; then
        if npm completion >/dev/null 2>&1; then
            if [[ -n "$ZSH_VERSION" ]]; then
                npm completion > "$HOME/.npm-completion.zsh" 2>/dev/null && \
                _load_completion "$HOME/.npm-completion.zsh"
            else
                npm completion > "$HOME/.npm-completion.bash" 2>/dev/null && \
                _load_completion "$HOME/.npm-completion.bash"
            fi
        fi
    fi
fi

# ============================================================================
# pip/pip3 Completion
# ============================================================================
if _has_command pip || _has_command pip3; then
    if [[ -n "$ZSH_VERSION" ]]; then
        _load_completion /usr/share/zsh/site-functions/_pip || \
        _load_completion /usr/local/share/zsh/site-functions/_pip || \
        _load_completion "$HOME/.zsh/completions/_pip"
    else
        _load_completion /usr/share/bash-completion/completions/pip || \
        _load_completion /usr/local/share/bash-completion/completions/pip || \
        _load_completion /opt/homebrew/share/bash-completion/completions/pip
    fi
fi

# ============================================================================
# Homebrew Completion (macOS)
# ============================================================================
if [[ "$OSTYPE" == "darwin"* ]] && _has_command brew; then
    if [[ -n "$ZSH_VERSION" ]]; then
        # Zsh: Homebrew completion
        if [ -d /opt/homebrew/share/zsh/site-functions ]; then
            fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
        elif [ -d /usr/local/share/zsh/site-functions ]; then
            fpath=(/usr/local/share/zsh/site-functions $fpath)
        fi
    else
        # Bash: Homebrew completion
        _load_completion /opt/homebrew/etc/bash_completion.d/brew || \
        _load_completion /usr/local/etc/bash_completion.d/brew
    fi
fi

# ============================================================================
# chezmoi Completion
# ============================================================================
if _has_command chezmoi; then
    if [[ -n "$ZSH_VERSION" ]]; then
        # Zsh: chezmoi completion
        if [ -f "$HOME/.chezmoi-completion.zsh" ]; then
            _load_completion "$HOME/.chezmoi-completion.zsh"
        else
            # Generate completion
            if chezmoi completion zsh >/dev/null 2>&1; then
                chezmoi completion zsh > "$HOME/.chezmoi-completion.zsh" 2>/dev/null && \
                _load_completion "$HOME/.chezmoi-completion.zsh"
            fi
        fi
    else
        # Bash: chezmoi completion
        if [ -f "$HOME/.chezmoi-completion.bash" ]; then
            _load_completion "$HOME/.chezmoi-completion.bash"
        else
            # Generate completion
            if chezmoi completion bash >/dev/null 2>&1; then
                chezmoi completion bash > "$HOME/.chezmoi-completion.bash" 2>/dev/null && \
                _load_completion "$HOME/.chezmoi-completion.bash"
            fi
        fi
    fi
fi

# ============================================================================
# gh (GitHub CLI) Completion
# ============================================================================
if _has_command gh; then
    if [[ -n "$ZSH_VERSION" ]]; then
        # Zsh: gh completion
        if [ -f "$HOME/.gh-completion.zsh" ]; then
            _load_completion "$HOME/.gh-completion.zsh"
        else
            # Generate completion
            if gh completion -s zsh >/dev/null 2>&1; then
                gh completion -s zsh > "$HOME/.gh-completion.zsh" 2>/dev/null && \
                _load_completion "$HOME/.gh-completion.zsh"
            fi
        fi
    else
        # Bash: gh completion
        if [ -f "$HOME/.gh-completion.bash" ]; then
            _load_completion "$HOME/.gh-completion.bash"
        else
            # Generate completion
            if gh completion -s bash >/dev/null 2>&1; then
                gh completion -s bash > "$HOME/.gh-completion.bash" 2>/dev/null && \
                _load_completion "$HOME/.gh-completion.bash"
            fi
        fi
    fi
fi

# ============================================================================
# cargo (Rust) Completion
# ============================================================================
if _has_command cargo; then
    if [[ -n "$ZSH_VERSION" ]]; then
        _load_completion "$HOME/.cargo/etc/bash_completion.d/cargo" || \
        _load_completion /usr/share/zsh/site-functions/_cargo || \
        _load_completion /usr/local/share/zsh/site-functions/_cargo
    else
        _load_completion "$HOME/.cargo/etc/bash_completion.d/cargo" || \
        _load_completion /usr/share/bash-completion/completions/cargo || \
        _load_completion /usr/local/share/bash-completion/completions/cargo
    fi
fi

# ============================================================================
# go Completion
# ============================================================================
if _has_command go; then
    if [[ -n "$ZSH_VERSION" ]]; then
        _load_completion /usr/share/zsh/site-functions/_go || \
        _load_completion /usr/local/share/zsh/site-functions/_go || \
        _load_completion "$HOME/.zsh/completions/_go"
    else
        _load_completion /usr/share/bash-completion/completions/go || \
        _load_completion /usr/local/share/bash-completion/completions/go
    fi
fi

# ============================================================================
# docker-compose v2 (as plugin) Completion
# ============================================================================
if _has_command docker && docker compose version >/dev/null 2>&1; then
    if [[ -n "$ZSH_VERSION" ]]; then
        # Docker Compose v2 completion (plugin)
        if [ -f "$HOME/.docker-compose-completion.zsh" ]; then
            _load_completion "$HOME/.docker-compose-completion.zsh"
        else
            # Generate completion
            if docker compose completion zsh >/dev/null 2>&1; then
                docker compose completion zsh > "$HOME/.docker-compose-completion.zsh" 2>/dev/null && \
                _load_completion "$HOME/.docker-compose-completion.zsh"
            fi
        fi
    else
        # Bash: Docker Compose v2 completion
        if [ -f "$HOME/.docker-compose-completion.bash" ]; then
            _load_completion "$HOME/.docker-compose-completion.bash"
        else
            # Generate completion
            if docker compose completion bash >/dev/null 2>&1; then
                docker compose completion bash > "$HOME/.docker-compose-completion.bash" 2>/dev/null && \
                _load_completion "$HOME/.docker-compose-completion.bash"
            fi
        fi
    fi
fi

# ============================================================================
# Custom completion directory
# ============================================================================
# Load any custom completions from ~/.zsh/completions or ~/.bash_completion.d
if [[ -n "$ZSH_VERSION" ]]; then
    if [ -d "$HOME/.zsh/completions" ]; then
        fpath=("$HOME/.zsh/completions" $fpath)
    fi
else
    if [ -d "$HOME/.bash_completion.d" ]; then
        for completion_file in "$HOME/.bash_completion.d"/*; do
            [ -f "$completion_file" ] && _load_completion "$completion_file"
        done
    fi
fi

# ============================================================================
# Conda Completion
# ============================================================================
if _has_command conda || [ -d "$HOME/miniconda3" ] || [ -d "$HOME/miniconda" ] || [ -d "$HOME/anaconda3" ] || [ -d "$HOME/anaconda" ]; then
    # Determine conda location (check miniconda3 first, then fallbacks)
    conda_dir=""
    if [ -d "$HOME/miniconda3" ]; then
        conda_dir="$HOME/miniconda3"
    elif [ -d "$HOME/miniconda" ]; then
        conda_dir="$HOME/miniconda"
    elif [ -d "$HOME/anaconda3" ]; then
        conda_dir="$HOME/anaconda3"
    elif [ -d "$HOME/anaconda" ]; then
        conda_dir="$HOME/anaconda"
    fi
    
    if [ -n "$conda_dir" ] && [ -f "$conda_dir/etc/profile.d/conda.sh" ]; then
        if [[ -n "$ZSH_VERSION" ]]; then
            # Zsh: conda completion
            if [ -f "$conda_dir/etc/profile.d/conda.sh" ]; then
                # Conda completion is loaded via conda init, which happens lazily
                # But we can set up the completion path
                if [ -d "$conda_dir/etc/profile.d" ]; then
                    fpath=("$conda_dir/etc/profile.d" $fpath)
                fi
            fi
        else
            # Bash: conda completion
            # Conda completion is loaded via conda init, which happens lazily
            # The completion will be available after conda is initialized
            if [ -f "$conda_dir/etc/profile.d/conda.sh" ]; then
                # Completion is handled by conda init
                :
            fi
        fi
    fi
fi

# Clean up
unset -f _load_completion _has_command
