# Cross-Platform Dotfiles

Cross-platform dotfiles configuration that works seamlessly across macOS (zsh) and Ubuntu Linux (bash), with lazy loading for optimal performance.

## Features

- **Cross-Platform**: Works on macOS with zsh and Ubuntu Linux with bash
- **Lazy Loading**: Heavy tools and plugins load only when needed, improving shell startup time
- **Feature Parity**: Same aliases, functions, and utilities work in both environments
- **Chezmoi Integration**: Easy synchronization across machines using chezmoi
- **OS-Aware**: Automatically detects and adapts to the operating system
- **Pure Prompt**: Beautiful minimal prompt for zsh (auto-installs) and Pure-inspired prompt for bash
- **Autocomplete**: Automatically detects and loads completion scripts for common tools
- **Environment Management**: Hierarchical `.env` file loading with automatic directory-based reloading
- **Git Auto-Configuration**: Automatically configures git user name and email from environment variables
- **Tmux Configuration**: Oh my tmux! integration with automatic installation and symlink management

## Installation

### Prerequisites

- [chezmoi](https://www.chezmoi.io/) installed on your system
- Git (for syncing with remote repository)

### Initial Setup

1. **Install chezmoi** (if not already installed):
   ```bash
   sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/happyhappy-jun/dotfiles.git
   ```
   
   Or if you already have chezmoi:
   ```bash
   chezmoi init https://github.com/happyhappy-jun/dotfiles.git
   chezmoi apply
   ```

2. **Configure machine-specific settings** (optional):
   Create `~/.config/chezmoi/chezmoi.toml` with your machine-specific variables:
   ```toml
   [data]
       email = "your.email@example.com"
       name = "Your Name"
       gitUser = "yourusername"
   ```

3. **Reload your shell**:
   ```bash
   source ~/.bashrc  # For bash
   # or
   source ~/.zshrc   # For zsh
   ```

## Structure

```
dotfiles/
├── .chezmoi.toml.tmpl          # Chezmoi configuration template
├── .chezmoiignore              # Files to ignore
├── .gitignore                  # Git ignore file
├── dot_bashrc                  # Bash configuration (becomes ~/.bashrc)
├── dot_zshrc                   # Zsh configuration (becomes ~/.zshrc)
├── dot_env.tmpl                # Environment variables template (becomes ~/.env)
├── dot_tmux.conf.local         # Tmux customization file (becomes ~/.tmux.conf.local)
├── dot_common/                  # Shell-agnostic scripts (becomes ~/.common/)
│   ├── aliases.sh              # Common aliases
│   ├── functions.sh            # Common functions
│   ├── paths.sh                # PATH management
│   ├── lazy_load.sh            # Lazy loading utilities
│   ├── completions.sh          # Autocomplete scripts loader
│   ├── env_manager.sh          # Environment variable manager
│   ├── tmux_setup.sh           # Tmux symlink management
│   └── prompts/                # Prompt configurations
│       ├── pure_zsh.sh         # Pure prompt for zsh
│       └── pure_bash.sh        # Pure-inspired prompt for bash
├── run_once_before/            # One-time setup scripts
│   ├── install_dependencies.sh
│   └── install_tmux_config.sh # Installs Oh my tmux! repository
└── README.md                   # This file
```

**Note**: Chezmoi automatically converts files/directories starting with `dot_` to dotfiles in your home directory. For example:
- `dot_bashrc` → `~/.bashrc`
- `dot_common/` → `~/.common/`
- `dot_env.tmpl` → `~/.env`

The shell configurations automatically detect the common directory in multiple locations for flexibility.

## Lazy Loading

Lazy loading defers the initialization of heavy tools until they are first used, significantly improving shell startup time.

### How It Works

- **Heavy Tools**: nvm, pyenv, rbenv, conda, cargo, etc. are loaded only when first invoked
- **Function Wrappers**: Commands are wrapped in functions that load the tool on first use
- **Shell-Agnostic**: Works in both zsh and bash using the same interface

### Example

```bash
# nvm is not loaded until you use it
nvm install node

# On first use, nvm loads automatically
# Subsequent uses are instant
```

### Supported Tools

- Node Version Manager (nvm)
- Fast Node Manager (fnm)
- Python Version Manager (pyenv)
- Conda (miniconda3/anaconda3)
- Ruby Version Manager (rbenv)
- Rust (cargo)
- Go
- Starship prompt (if installed)

## Autocomplete

The dotfiles automatically detect and load completion scripts for common tools, providing intelligent tab completion in both zsh and bash.

### Supported Tools

The completion system automatically detects and loads completions for:

- **Version Control**: git, gh (GitHub CLI)
- **Containers**: docker, docker-compose
- **Kubernetes**: kubectl
- **Infrastructure**: terraform, aws-cli
- **Package Managers**: npm, pip/pip3, brew (Homebrew)
- **Development Tools**: cargo (Rust), go, chezmoi

### How It Works

1. **Automatic Detection**: The system checks if tools are installed before loading their completions
2. **Multiple Sources**: Checks common installation locations (system-wide, Homebrew, user-local)
3. **Auto-Generation**: For tools that support it (kubectl, terraform, gh), completions are automatically generated if not found
4. **Custom Completions**: Supports custom completions in `~/.zsh/completions/` (zsh) or `~/.bash_completion.d/` (bash)

### Adding Custom Completions

**For Zsh:**
```bash
# Place completion files in ~/.zsh/completions/
# Files should be named _commandname
mkdir -p ~/.zsh/completions
# Copy or create your completion file
cp my_completion.zsh ~/.zsh/completions/_mycommand
```

**For Bash:**
```bash
# Place completion files in ~/.bash_completion.d/
mkdir -p ~/.bash_completion.d
# Copy or create your completion file
cp my_completion.bash ~/.bash_completion.d/mycommand
```

The completion system will automatically load these on the next shell startup.

## Environment Variable Management

The dotfiles include an environment variable manager that automatically loads and manages `.env` files with hierarchical override support.

### How It Works

1. **Base Environment (`~/.env`)**: Loaded first, contains default/shared environment variables
2. **Local Environment (`./.env`)**: Loaded when present in the current directory, overrides base variables
3. **Automatic Reloading**: Environment variables are automatically reloaded when you change directories

### Features

- **Hierarchical Loading**: `~/.env` loads first, then `./.env` overrides it
- **Automatic Detection**: Automatically detects directory changes and reloads environment
- **Security**: Values are masked when using `env_show` command
- **Chezmoi Integration**: Base `.env` file can be templated using chezmoi

### Usage

```bash
# View environment variables (values are masked for security)
env_show

# Manually reload environment variables
env_reload

# Environment variables are automatically loaded when you cd into a directory
cd ~/myproject  # Loads ~/.env and ~/myproject/.env if it exists
```

### Managing Base Environment File

The base `~/.env` file is managed by chezmoi as `dot_env.tmpl`. You can customize it:

```bash
# Edit the template
chezmoi edit ~/.env

# Apply changes
chezmoi apply
```

### Security Best Practices

- **DO NOT** store credentials in `~/.env` (the chezmoi-managed template)
- **DO** use `~/.config/chezmoi/chezmoi.toml` for machine-specific secrets
- **DO** use `./.env` files in project directories for project-specific variables
- **DO** add `.env.local`, `.env.secret`, etc. to `.chezmoiignore` to prevent syncing credentials

### Example `.env` Files

**`~/.env` (base, managed by chezmoi)**:
```bash
# Base configuration
USER_NAME="Byungjun Yoon"
USER_EMAIL="bjyoon513@gmail.com"
GIT_USER_NAME="Byungjun Yoon"
GIT_USER_EMAIL="bjyoon513@gmail.com"
EDITOR=vim
LANG=en_US.UTF-8
```

**`~/myproject/.env` (project-specific)**:
```bash
# Project-specific overrides
PROJECT_NAME=myproject
API_URL=https://api.myproject.com
# Note: Credentials should be in .env.local (not tracked by chezmoi)
```

## Git Auto-Configuration

Git user name and email are automatically configured from environment variables, ensuring consistent git identity across all development servers.

### Default Configuration

The dotfiles automatically set:
- `git config --global user.name "Byungjun Yoon"`
- `git config --global user.email "bjyoon513@gmail.com"`

These values are set from `GIT_USER_NAME` and `GIT_USER_EMAIL` environment variables (defined in `~/.env`).

### How It Works

1. Environment variables are loaded from `~/.env` on shell startup
2. Git configuration is automatically set from `GIT_USER_NAME` and `GIT_USER_EMAIL`
3. Configuration is updated whenever environment variables are reloaded
4. Git functions (`gac`, `gacp`) ensure git is configured before committing

### Override for Specific Machines

If you want different git config on specific machines:

1. **Set in `~/.config/chezmoi/chezmoi.toml`**:
   ```toml
   [data]
       name = "Different Name"
       email = "different@email.com"
   ```

2. **Or override in project `.env` files**:
   ```bash
   # ~/myproject/.env
   GIT_USER_NAME="Project Specific Name"
   GIT_USER_EMAIL="project@email.com"
   ```

### Verification

```bash
# Check current git configuration
git config --global user.name
git config --global user.email

# Or view environment variables
env_show
```

## Aliases

### File Operations
- `ls`, `ll`, `la` - List files with colors
- `..`, `...`, `....` - Navigate up directories
- `dls`, `docs`, `dt` - Quick navigation to common directories
- `repos` - Navigate to code directory

### Development
- `g`, `ga`, `gc`, `gco`, `gd`, `gs` - Git shortcuts
- `dk`, `dco` - Docker shortcuts
- `va`, `ve` - Python virtual environment management

### System
- `sysinfo` - System information (uses neofetch/screenfetch)
- `top` - Process monitor (uses htop if available)
- `update` - Update system packages (OS-aware)
- `path` - Display PATH entries

### Utilities
- `cb`, `cbpaste` - Clipboard operations
- `weather`, `forecast` - Weather information
- `reload` - Reload shell configuration
- `env_show` - Show environment variables from .env files (values masked)
- `env_reload` - Manually reload environment variables

See `dot_common/aliases.sh` for the complete list.

## Functions

### File Operations
- `mkcd <dir>` - Create directory and cd into it
- `extract <archive>` - Extract various archive formats
- `ff <name>` - Find files by name
- `ffe <ext>` - Find files by extension

### Development
- `gac <message>` - Git add all and commit (auto-configures git if needed)
- `gacp <message>` - Git add, commit, and push (auto-configures git if needed)
- `venv [name]` - Create and activate Python virtual environment

### Network
- `localip` - Get local IP address
- `publicip` - Get public IP address
- `port <num>` - Check if port is in use

### System
- `psgrep <name>` - Find process by name
- `pkill <name>` - Kill process by name
- `loc [dir]` - Count lines of code

See `dot_common/functions.sh` for the complete list.

## Tmux Configuration

### Oh my tmux!

This dotfiles setup includes [Oh my tmux!](https://github.com/gpakosz/.tmux) - a self-contained, pretty and versatile tmux configuration.

**Features:**
- Automatic installation via `run_once_before/install_tmux_config.sh`
- Symlink management via `dot_common/tmux_setup.sh`
- Customization file (`dot_tmux.conf.local`) managed by chezmoi
- Same configuration across all machines

**Installation:**

Oh my tmux! is automatically installed when you run:
```bash
chezmoi apply
```

The installation script (`install_tmux_config.sh`) will:
1. Clone the Oh my tmux! repository to `~/.tmux` (or `~/.config/tmux` if `XDG_CONFIG_HOME` is set)
2. Create symlinks for `.tmux.conf` and `.tmux.conf.local`
3. Preserve any existing customizations

**Customization:**

Edit `dot_tmux.conf.local` in your chezmoi source directory:
```bash
chezmoi edit ~/.tmux.conf.local
```

Or edit directly in tmux:
- Press `<prefix> e` (default prefix is `Ctrl-b`, then press `e`)

After making changes, apply them:
```bash
chezmoi apply
```

**Key Bindings:**

Oh my tmux! provides many useful key bindings:
- `<prefix> e` - Edit `.tmux.conf.local`
- `<prefix> r` - Reload tmux configuration
- `<prefix> |` - Split window vertically
- `<prefix> -` - Split window horizontally
- `<prefix> h/j/k/l` - Navigate panes (Vim-style)
- `<prefix> H/J/K/L` - Resize panes
- `<prefix> <` and `<prefix> >` - Swap panes
- `<prefix> +` - Maximize current pane to new window
- `<prefix> m` - Toggle mouse mode

For a complete list of bindings, see the [Oh my tmux! documentation](https://github.com/gpakosz/.tmux).

**Requirements:**

- tmux >= 2.6
- awk, perl (with Time::HiRes support), grep, and sed
- `TERM` environment variable set to `xterm-256color` (outside of tmux)

**Troubleshooting:**

If tmux configuration is not loading:
1. Check that Oh my tmux! is installed: `ls -la ~/.tmux` or `ls -la ~/.config/tmux`
2. Verify symlinks exist: `ls -la ~/.tmux.conf ~/.tmux.conf.local`
3. Check tmux version: `tmux -V` (must be >= 2.6)
4. Reload tmux config: Press `<prefix> r` in tmux

## Prompt Theme

### Pure Prompt

This dotfiles setup includes the [Pure prompt](https://github.com/sindresorhus/pure) for zsh and a Pure-inspired prompt for bash.

**For Zsh (macOS):**
- Pure prompt is automatically cloned from GitHub on first use
- Located at `~/.zsh/pure/`
- Features: Git status, branch info, execution time, minimal design

**For Bash (Linux):**
- Pure-inspired prompt with similar features
- Shows git branch, dirty status, and arrows
- Minimal, clean design matching Pure's aesthetic

**Customization:**
- Pure (zsh): Configure via `zstyle` commands in `~/.zshrc.local`
- Pure-inspired (bash): Edit `~/.common/prompts/pure_bash.sh`

**Fallback:**
- If Pure fails to load, falls back to Starship (if installed) or simple prompt

## History Substring Search

Both zsh and bash include enhanced history search functionality that allows you to search through command history by typing part of a command.

**How it works:**
1. Type part of a command you want to find
2. Press **Up arrow** to search backward through history for matching commands
3. Press **Down arrow** to search forward through history for matching commands
4. The search matches any command containing the text you typed (substring match)

**Example:**
```bash
# Type "git" and press Up arrow
git
# Navigates through all commands containing "git" in your history
# e.g., git commit, git push, git pull, etc.
```

**Features:**
- **Substring matching**: Finds commands containing your search text anywhere in the command
- **Bidirectional search**: Navigate both forward and backward through matching history
- **Smart reset**: Automatically resets search when you change the search text
- **Empty line fallback**: If the line is empty, uses normal history navigation

**Key Bindings:**
- **Up Arrow** (`↑`): Search backward through matching history
- **Down Arrow** (`↓`): Search forward through matching history
- **Page Up/Down**: Alternative navigation keys (zsh only)

**Technical Details:**
- Implemented in `~/.common/history_search.sh`
- Automatically loaded by both `~/.zshrc` and `~/.bashrc`
- Works seamlessly with existing history configuration
- Compatible with both emacs and vi key bindings

## Synchronization

### Updating Dotfiles

1. **Make changes** to files in the chezmoi source directory:
   ```bash
   chezmoi cd
   # Edit files...
   ```

2. **Commit and push**:
   ```bash
   git add .
   git commit -m "Update dotfiles"
   git push
   ```

3. **Apply on other machines**:
   ```bash
   chezmoi update
   ```

### Adding New Files

1. **Add file to chezmoi**:
   ```bash
   chezmoi add ~/.newfile
   ```

2. **Edit in source directory**:
   ```bash
   chezmoi edit ~/.newfile
   ```

3. **Apply changes**:
   ```bash
   chezmoi apply
   ```

## Customization

### Machine-Specific Configuration

Create `~/.config/chezmoi/chezmoi.toml` (not tracked by git) for machine-specific settings:

```toml
[data]
    email = "work@example.com"
    name = "Work Machine"
    gitUser = "workusername"
```

### Local Overrides

Create `~/.bashrc.local` or `~/.zshrc.local` (not tracked by git) for local customizations that won't be synced.

### Adding Custom Aliases/Functions

1. Edit `dot_common/aliases.sh` or `dot_common/functions.sh`
2. Commit and push changes
3. Run `chezmoi apply` on all machines

## Performance

### Startup Time Optimization

- **Lazy Loading**: Heavy tools load only when needed
- **Deferred Completion**: Completion system optimized for speed
- **Minimal Early Loading**: Only essential configuration loads at startup
- **Fast Prompt**: Pure prompt is lightweight and fast
- **Environment Caching**: Environment variables are cached and only reloaded on directory change

### Measuring Startup Time

```bash
# Bash
time bash -i -c exit

# Zsh
time zsh -i -c exit
```

## Troubleshooting

### Shell Not Loading Configuration

1. Check that chezmoi has applied the files:
   ```bash
   chezmoi verify
   ```

2. Ensure the shell config is being sourced:
   ```bash
   # Check ~/.bashrc or ~/.zshrc exists and sources the right file
   cat ~/.bashrc | head -20
   ```

### Lazy Loading Not Working

1. Check that `lazy_load.sh` is being sourced
2. Verify the tool exists in the expected location
3. Check shell compatibility (function syntax)

### PATH Issues

1. Check `dot_common/paths.sh` for correct OS detection
2. Verify paths exist before being added
3. Use `path` command to see current PATH
4. Ensure PATH is initialized early in shell startup

### Environment Variables Not Loading

1. Check that `~/.env` exists:
   ```bash
   ls -la ~/.env
   ```

2. Verify environment manager is loaded:
   ```bash
   type env_show
   ```

3. Manually reload:
   ```bash
   env_reload
   ```

### Git Configuration Not Set

1. Check environment variables:
   ```bash
   env_show
   ```

2. Verify git config:
   ```bash
   git config --global user.name
   git config --global user.email
   ```

3. Manually configure:
   ```bash
   git config --global user.name "Byungjun Yoon"
   git config --global user.email "bjyoon513@gmail.com"
   ```

## Reference

This dotfiles setup is inspired by:
- [renemarc/dotfiles](https://github.com/renemarc/dotfiles) - Cross-platform dotfiles structure
- [chezmoi](https://www.chezmoi.io/) - Dotfile manager
- [Pure prompt](https://github.com/sindresorhus/pure) - Minimal, fast prompt

## License

MIT License - feel free to use and modify for your needs.
