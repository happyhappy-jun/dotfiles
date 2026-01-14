#!/usr/bin/env bash
# Set up Starship configuration with Pure preset
# This script configures Starship to use the Pure preset theme

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

# Check if config already exists
if [ -f "$STARSHIP_CONFIG_FILE" ]; then
    echo "Starship config already exists at $STARSHIP_CONFIG_FILE"
    echo "Backing up existing config to ${STARSHIP_CONFIG_FILE}.bak"
    cp "$STARSHIP_CONFIG_FILE" "${STARSHIP_CONFIG_FILE}.bak"
fi

# Generate Pure preset configuration
echo "Setting up Starship with Pure preset..."
starship preset pure-preset -o "$STARSHIP_CONFIG_FILE"

if [ -f "$STARSHIP_CONFIG_FILE" ]; then
    echo "Starship configured successfully with Pure preset!"
    echo "Config file: $STARSHIP_CONFIG_FILE"
else
    echo "Error: Failed to create Starship config file."
    exit 1
fi
