#!/usr/bin/env bash
# Set up Starship configuration
# NOTE: The config is now managed by chezmoi at dot_config/starship.toml
# This script only runs if the chezmoi-managed config doesn't exist yet

set -e

# Check if Starship is installed
if ! command -v starship >/dev/null 2>&1; then
    echo "Starship is not installed. Please run install_starship.sh first."
    exit 1
fi

# Create config directory if it doesn't exist
STARSHIP_CONFIG_DIR="$HOME/.config"
if [ ! -d "$STARSHIP_CONFIG_DIR" ]; then
    mkdir -p "$STARSHIP_CONFIG_DIR"
fi

STARSHIP_CONFIG_FILE="$STARSHIP_CONFIG_DIR/starship.toml"

# If config already exists (managed by chezmoi), skip setup
if [ -f "$STARSHIP_CONFIG_FILE" ]; then
    echo "Starship config already exists at $STARSHIP_CONFIG_FILE (managed by chezmoi)"
    exit 0
fi

# Generate Pure preset configuration as fallback
echo "Setting up Starship with Pure preset..."
starship preset pure-preset -o "$STARSHIP_CONFIG_FILE"

if [ -f "$STARSHIP_CONFIG_FILE" ]; then
    # Add scan_timeout at root level (prepend to file) to prevent hanging on large directories
    echo "Adding scan_timeout configuration..."
    echo "scan_timeout = 2000" > "${STARSHIP_CONFIG_FILE}.new"
    echo "" >> "${STARSHIP_CONFIG_FILE}.new"
    cat "$STARSHIP_CONFIG_FILE" >> "${STARSHIP_CONFIG_FILE}.new"
    mv "${STARSHIP_CONFIG_FILE}.new" "$STARSHIP_CONFIG_FILE"
    
    # Replace the Pure preset's minimal [python] section with enhanced version
    echo "Updating Python virtual environment configuration..."
    # Use sed to replace the existing [python] section
    # The Pure preset has: [python]\nformat = "[$virtualenv]($style) "\nstyle = "bright-black"\ndetect_extensions = []\ndetect_files = []
    sed -i.tmp '/^\[python\]$/,/^$/c\
[python]\
format = "via [${symbol}(${version} )]($style)"\
symbol = "🐍 "\
style = "yellow bold"\
pyenv_version_name = false\
detect_extensions = ["py"]\
detect_files = [".python-version", "Pipfile", "__pycache__", "pyproject.toml", "requirements.txt", "setup.py", "tox.ini"]\
detect_folders = [".venv", "venv", ".virtualenv"]\
' "$STARSHIP_CONFIG_FILE"
    rm -f "${STARSHIP_CONFIG_FILE}.tmp"
    
    # Add Conda and Node.js sections if they don't exist
    echo "Adding Conda and Node.js configuration..."
    if ! grep -q '^\[conda\]' "$STARSHIP_CONFIG_FILE"; then
        cat >> "$STARSHIP_CONFIG_FILE" << 'EOF'

# Conda environment
[conda]
format = '[$symbol$environment]($style) '
symbol = "🅒 "
style = "green bold"
ignore_base = true
EOF
    fi
    
    if ! grep -q '^\[nodejs\]' "$STARSHIP_CONFIG_FILE"; then
        cat >> "$STARSHIP_CONFIG_FILE" << 'EOF'

# Node.js (useful for JS projects)
[nodejs]
format = 'via [$symbol($version )]($style)'
symbol = "⬢ "
style = "green bold"
detect_files = ["package.json", ".node-version", ".nvmrc"]
detect_folders = ["node_modules"]
EOF
    fi
    
    echo "Starship configured successfully with Pure preset!"
    echo "Config file: $STARSHIP_CONFIG_FILE"
else
    echo "Error: Failed to create Starship config file."
    exit 1
fi
