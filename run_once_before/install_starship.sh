#!/usr/bin/env bash
# Install Starship prompt
# Supports Linux, macOS, and other Unix systems
# See https://starship.rs/guide/ for installation instructions

# Don't exit on error - we want to try multiple installation methods
set +e

echo "Installing Starship prompt..."

# Detect OS and architecture
if [[ "$OSTYPE" == "darwin"* ]]; then
    IS_MACOS=true
    IS_LINUX=false
elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "linux"* ]]; then
    IS_MACOS=false
    IS_LINUX=true
else
    IS_MACOS=false
    IS_LINUX=false
fi

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64)
        ARCH="x86_64"
        ;;
    arm64|aarch64)
        ARCH="aarch64"
        ;;
    armv7l|armv6l)
        ARCH="armv7"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        echo "Please install Starship manually from https://starship.rs/guide/"
        exit 1
        ;;
esac

# Check if Starship is already installed
if command -v starship >/dev/null 2>&1; then
    echo "Starship is already installed: $(starship --version)"
    exit 0
fi

# Try to install using package managers first (Linux only)
# macOS will use the official installer script
if [ "$IS_LINUX" = true ]; then
    # Linux: Try system package managers
    if command -v apt >/dev/null 2>&1; then
        # Debian/Ubuntu
        if [ -f /etc/debian_version ]; then
            DEBIAN_VERSION=$(cat /etc/debian_version | cut -d. -f1)
            UBUNTU_VERSION=$(lsb_release -rs 2>/dev/null | cut -d. -f1 || echo "0")
            if [ "$UBUNTU_VERSION" -ge 25 ] || [ "$DEBIAN_VERSION" -ge 13 ] 2>/dev/null; then
                echo "Installing Starship via apt..."
                sudo apt update && sudo apt install -y starship && exit 0
            fi
        fi
    elif command -v pacman >/dev/null 2>&1; then
        # Arch Linux
        echo "Installing Starship via pacman..."
        sudo pacman -S --noconfirm starship && exit 0
    elif command -v dnf >/dev/null 2>&1; then
        # Fedora/CentOS
        echo "Installing Starship via dnf (Copr)..."
        sudo dnf copr enable atim/starship -y && sudo dnf install -y starship && exit 0
    elif command -v apk >/dev/null 2>&1; then
        # Alpine Linux
        echo "Installing Starship via apk..."
        sudo apk add starship && exit 0
    elif command -v zypper >/dev/null 2>&1; then
        # openSUSE
        echo "Installing Starship via zypper..."
        sudo zypper install -y starship && exit 0
    elif command -v nix-env >/dev/null 2>&1; then
        # NixOS
        echo "Installing Starship via nix-env..."
        nix-env -iA nixpkgs.starship && exit 0
    fi
fi

# Fallback: Install using official installer script
echo "Installing Starship using official installer..."
INSTALL_SUCCESS=false
if command -v curl >/dev/null 2>&1; then
    if curl -sS https://starship.rs/install.sh | sh; then
        INSTALL_SUCCESS=true
    fi
elif command -v wget >/dev/null 2>&1; then
    if wget -qO- https://starship.rs/install.sh | sh; then
        INSTALL_SUCCESS=true
    fi
else
    echo "Error: curl or wget is required to install Starship."
    echo "Please install curl or wget, or install Starship manually from https://starship.rs/guide/"
    exit 1
fi

# Ensure Starship is in PATH (official installer installs to ~/.local/bin)
if [ "$INSTALL_SUCCESS" = true ]; then
    # Add ~/.local/bin to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        # Also add to shell config for persistence
        if [ -n "$ZSH_VERSION" ]; then
            if ! grep -q 'export PATH.*\.local/bin' ~/.zshrc 2>/dev/null; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
            fi
        elif [ -n "$BASH_VERSION" ]; then
            if ! grep -q 'export PATH.*\.local/bin' ~/.bashrc 2>/dev/null; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
            fi
        fi
    fi
    
    # Verify installation
    if command -v starship >/dev/null 2>&1; then
        echo "Starship installed successfully: $(starship --version)"
    else
        echo "Starship installation completed, but it's not in PATH yet."
        echo "Please run: export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo "Or restart your shell."
    fi
else
    echo "Failed to install Starship. Please install manually from https://starship.rs/guide/"
    exit 1
fi
