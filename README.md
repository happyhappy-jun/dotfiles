# Cross-Platform Dotfiles

Cross-platform dotfiles configuration that works seamlessly across macOS (zsh) and Ubuntu Linux (bash), with lazy loading for optimal performance.

## Features

- **Cross-Platform**: Works on macOS with zsh and Ubuntu Linux with bash
- **Lazy Loading**: Heavy tools and plugins load only when needed, improving shell startup time
- **Feature Parity**: Same aliases, functions, and utilities work in both environments
- **Chezmoi Integration**: Easy synchronization across machines using chezmoi
- **OS-Aware**: Automatically detects and adapts to the operating system
- **Pure Prompt**: Beautiful minimal prompt for zsh (auto-installs) and Pure-inspired prompt for bash
- **Autocomplete**: Automatically detects and loads completion scripts for common tools (git, docker, kubectl, terraform, aws, npm, etc.)

## Installation

### Prerequisites

- [chezmoi](https://www.chezmoi.io/) installed on your system
- Git (for syncing with remote repository)

### Initial Setup

1. **Install chezmoi** (if not already installed):
   ```bash
   sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-git-repo-url>
   ```
   
   Or if you already have chezmoi:
   ```bash
   chezmoi init https://github.com/yourusername/dotfiles.git
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
├── dot_common/                 # Shell-agnostic scripts (becomes ~/.common/)
│   ├── aliases.sh              # Common aliases
│   ├── functions.sh            # Common functions
│   ├── paths.sh                # PATH management
│   ├── lazy_load.sh            # Lazy loading utilities
│   ├── completions.sh          # Autocomplete scripts loader
│   └── prompts/                # Prompt configurations
│       ├── pure_zsh.sh         # Pure prompt for zsh
│       └── pure_bash.sh        # Pure-inspired prompt for bash
├── run_once_before/            # One-time setup scripts
│   └── install_dependencies.sh
└── README.md                   # This file
```

**Note**: Chezmoi automatically converts files/directories starting with `dot_` to dotfiles in your home directory. For example:
- `dot_bashrc` → `~/.bashrc`
- `dot_common/` → `~/.common/`

The shell configurations automatically detect the common directory in multiple locations for flexibility.

## Lazy Loading

Lazy loading defers the initialization of heavy tools until they are first used, significantly improving shell startup time.

### How It Works

- **Heavy Tools**: nvm, pyenv, rbenv, cargo, etc. are loaded only when first invoked
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

See `dot_common/aliases.sh` for the complete list.

## Functions

### File Operations
- `mkcd <dir>` - Create directory and cd into it
- `extract <archive>` - Extract various archive formats
- `ff <name>` - Find files by name
- `ffe <ext>` - Find files by extension

### Development
- `gac <message>` - Git add all and commit
- `gacp <message>` - Git add, commit, and push
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
```

### Local Overrides

Create `~/.bashrc.local` or `~/.zshrc.local` (not tracked by git) for local customizations that won't be synced.

### Adding Custom Aliases/Functions

1. Edit `dot_common/aliases.sh` or `dot_common/functions.sh`
2. Commit and push changes
3. Run `chezmoi apply` on all machines

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

## Performance

### Startup Time Optimization

- **Lazy Loading**: Heavy tools load only when needed
- **Deferred Completion**: Completion system optimized for speed
- **Minimal Early Loading**: Only essential configuration loads at startup
- **Fast Prompt**: Pure prompt is lightweight and fast

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
   ```

### Lazy Loading Not Working

1. Check that `lazy_load.sh` is being sourced
2. Verify the tool exists in the expected location
3. Check shell compatibility (function syntax)

### PATH Issues

1. Check `dot_common/paths.sh` for correct OS detection
2. Verify paths exist before being added
3. Use `path` command to see current PATH

## Reference

This dotfiles setup is inspired by:
- [renemarc/dotfiles](https://github.com/renemarc/dotfiles) - Cross-platform dotfiles structure
- [chezmoi](https://www.chezmoi.io/) - Dotfile manager

## License

MIT License - feel free to use and modify for your needs.
