#!/usr/bin/env bash
# Environment variable manager
# Loads ~/.env first, then overrides with ./.env (current directory)
# Automatically reloads when changing directories

# Track current directory to detect changes
_ENV_MANAGER_CURRENT_DIR="$PWD"

# Function to load environment variables from a file
_load_env_file() {
    local env_file="$1"
    
    if [ ! -f "$env_file" ]; then
        return 1
    fi
    
    # Read the file line by line
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        if [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        # Skip lines that don't look like variable assignments
        if [[ ! "$line" =~ ^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*= ]]; then
            continue
        fi
        
        # Export the variable safely
        # Extract variable name and value
        if [ -n "$ZSH_VERSION" ]; then
            # Zsh regex matching
            if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
                local var_name="${match[1]}"
                local var_value="${match[2]}"
                
                # Remove leading/trailing whitespace from variable name
                var_name="${var_name%"${var_name##*[![:space:]]}"}"
                var_name="${var_name#"${var_name%%[![:space:]]*}"}"
                
                # Remove quotes if present (handles both single and double quotes)
                if [[ "$var_value" =~ ^\".*\"$ ]] || [[ "$var_value" =~ ^\'.*\'$ ]]; then
                    # Remove first and last character (quotes)
                    var_value="${var_value#?}"
                    var_value="${var_value%?}"
                fi
                
                # Remove leading/trailing whitespace from value
                var_value="${var_value#"${var_value%%[![:space:]]*}"}"
                var_value="${var_value%"${var_value##*[![:space:]]}"}"
                
                # Export the variable
                export "${var_name}=${var_value}"
            fi
        else
            # Bash regex matching
            if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
                local var_name="${BASH_REMATCH[1]}"
                local var_value="${BASH_REMATCH[2]}"
                
                # Remove leading/trailing whitespace from variable name
                var_name="${var_name%"${var_name##*[![:space:]]}"}"
                var_name="${var_name#"${var_name%%[![:space:]]*}"}"
                
                # Remove quotes if present (handles both single and double quotes)
                if [[ "$var_value" =~ ^\".*\"$ ]] || [[ "$var_value" =~ ^\'.*\'$ ]]; then
                    var_value="${var_value:1:-1}"
                fi
                
                # Remove leading/trailing whitespace from value
                var_value="${var_value#"${var_value%%[![:space:]]*}"}"
                var_value="${var_value%"${var_value##*[![:space:]]}"}"
                
                # Export the variable
                export "${var_name}=${var_value}"
            fi
        fi
    done < "$env_file"
    
    return 0
}

# Function to reload environment variables
_reload_env() {
    # First, load base environment from home directory
    if [ -f "$HOME/.env" ]; then
        _load_env_file "$HOME/.env"
    fi
    
    # Then, override with current directory .env if it exists
    if [ -f ".env" ]; then
        _load_env_file ".env"
    fi
    
    # Configure git from environment variables after reloading
    _configure_git_from_env
    
    # Update tracked directory
    _ENV_MANAGER_CURRENT_DIR="$PWD"
}

# Function to check and reload if directory changed (for hooks)
_check_and_reload_env() {
    if [ "$_ENV_MANAGER_CURRENT_DIR" != "$PWD" ]; then
        _reload_env
    fi
}

# Function to show current environment variables from .env files
env_show() {
    echo "=== Base Environment (~/.env) ==="
    if [ -f "$HOME/.env" ]; then
        grep -v '^[[:space:]]*#' "$HOME/.env" | grep -v '^[[:space:]]*$' | sed 's/=.*/=***/' || echo "(empty or no variables)"
    else
        echo "(file not found)"
    fi
    
    echo ""
    echo "=== Current Directory Environment (./.env) ==="
    if [ -f ".env" ]; then
        grep -v '^[[:space:]]*#' ".env" | grep -v '^[[:space:]]*$' | sed 's/=.*/=***/' || echo "(empty or no variables)"
    else
        echo "(file not found)"
    fi
    
    echo ""
    echo "=== Active Environment Variables (from .env files) ==="
    # Show variables that are defined in .env files
    if [ -f "$HOME/.env" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            if [ -n "$ZSH_VERSION" ]; then
                if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)= ]]; then
                    local var_name="${match[1]}"
                    var_name="${var_name%"${var_name##*[![:space:]]}"}"
                    var_name="${var_name#"${var_name%%[![:space:]]*}"}"
                    if [ -n "${(P)var_name:-}" ]; then
                        echo "${var_name}=***"
                    fi
                fi
            else
                if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)= ]]; then
                    local var_name="${BASH_REMATCH[1]}"
                    var_name="${var_name%"${var_name##*[![:space:]]}"}"
                    var_name="${var_name#"${var_name%%[![:space:]]*}"}"
                    if [ -n "${!var_name:-}" ]; then
                        echo "${var_name}=***"
                    fi
                fi
            fi
        done < "$HOME/.env"
    fi
    if [ -f ".env" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            if [ -n "$ZSH_VERSION" ]; then
                if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)= ]]; then
                    local var_name="${match[1]}"
                    var_name="${var_name%"${var_name##*[![:space:]]}"}"
                    var_name="${var_name#"${var_name%%[![:space:]]*}"}"
                    if [ -n "${(P)var_name:-}" ]; then
                        echo "${var_name}=***"
                    fi
                fi
            else
                if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)= ]]; then
                    local var_name="${BASH_REMATCH[1]}"
                    var_name="${var_name%"${var_name##*[![:space:]]}"}"
                    var_name="${var_name#"${var_name%%[![:space:]]*}"}"
                    if [ -n "${!var_name:-}" ]; then
                        echo "${var_name}=***"
                    fi
                fi
            fi
        done < ".env"
    fi
}

# Function to reload environment (can be called manually)
env_reload() {
    _reload_env
    echo "Environment variables reloaded"
}

# Function to configure git from environment variables
_configure_git_from_env() {
    # Set git user name if GIT_USER_NAME is set
    if [ -n "${GIT_USER_NAME:-}" ]; then
        git config --global user.name "$GIT_USER_NAME" 2>/dev/null || true
    elif [ -n "${USER_NAME:-}" ]; then
        git config --global user.name "$USER_NAME" 2>/dev/null || true
    fi
    
    # Set git user email if GIT_USER_EMAIL is set
    if [ -n "${GIT_USER_EMAIL:-}" ]; then
        git config --global user.email "$GIT_USER_EMAIL" 2>/dev/null || true
    elif [ -n "${USER_EMAIL:-}" ]; then
        git config --global user.email "$USER_EMAIL" 2>/dev/null || true
    fi
}

# Initial load
_reload_env

# Configure git from environment variables after loading
_configure_git_from_env

# Export functions for use in shell (bash)
if [ -n "$BASH_VERSION" ]; then
    export -f _load_env_file _reload_env _check_and_reload_env env_show env_reload _configure_git_from_env
fi
