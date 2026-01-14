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
            export "$var_name=$var_value"
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
            if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)= ]]; then
                local var_name="${BASH_REMATCH[1]}"
                var_name="${var_name%"${var_name##*[![:space:]]}"}"
                var_name="${var_name#"${var_name%%[![:space:]]*}"}"
                if [ -n "${!var_name:-}" ]; then
                    echo "${var_name}=***"
                fi
            fi
        done < "$HOME/.env"
    fi
    if [ -f ".env" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)= ]]; then
                local var_name="${BASH_REMATCH[1]}"
                var_name="${var_name%"${var_name##*[![:space:]]}"}"
                var_name="${var_name#"${var_name%%[![:space:]]*}"}"
                if [ -n "${!var_name:-}" ]; then
                    echo "${var_name}=***"
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

# Initial load
_reload_env

# Export functions for use in shell (bash)
if [ -n "$BASH_VERSION" ]; then
    export -f _load_env_file _reload_env _check_and_reload_env env_show env_reload
fi
