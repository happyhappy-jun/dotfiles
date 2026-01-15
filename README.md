# Dotfiles

Cross-platform shell configuration managed by [chezmoi](https://www.chezmoi.io/). Works with both **Bash** and **Zsh** on **macOS** and **Linux**.

## Features

- **Cross-platform**: Works on macOS and Linux with OS-specific optimizations
- **Multi-shell**: Supports both Bash and Zsh with shared configuration
- **Fast startup**: Lazy loading for heavy tools (nvm, pyenv, conda, rbenv, etc.)
- **Custom paths**: Add custom PATH entries via `~/.paths` file
- **Environment management**: Auto-load `.env` files with directory-aware reloading
- **Modern prompt**: [Starship](https://starship.rs/) with Pure preset
- **Tmux integration**: [Oh My Tmux](https://github.com/gpakosz/.tmux) configuration
- **History search**: Substring search with arrow keys
- **Git subrepo**: [git-subrepo](https://github.com/ingydotnet/git-subrepo) for better submodule management

## Quick Start

### Installation

```bash
# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-github-username>

# Or if chezmoi is already installed
chezmoi init --apply <your-github-username>
```

### Update

```bash
chezmoi update && chezmoi apply
# Or use the alias
chz
```

## Structure

```
.
├── dot_bashrc                  # Bash configuration
├── dot_zshrc                   # Zsh configuration
├── dot_env.tmpl                # Environment variables template (~/.env)
├── dot_paths                   # Custom PATH entries (~/.paths)
├── dot_tmux.conf.local         # Tmux local configuration
├── dot_common/                 # Shared shell modules
│   ├── aliases.sh              # Cross-platform aliases
│   ├── functions.sh            # Utility functions
│   ├── paths.sh                # PATH management
│   ├── env_manager.sh          # Environment variable manager
│   ├── lazy_load.sh            # Lazy loading utilities
│   ├── completions.sh          # Shell completions
│   ├── history_search.sh       # History substring search
│   ├── tmux_setup.sh           # Tmux symlink management
│   └── prompts/
│       └── starship.sh         # Starship prompt initialization
└── run_once_before_*.sh        # One-time setup scripts
```

## Configuration

### Custom PATH Entries (`~/.paths`)

Add custom directories to your PATH by editing `~/.paths`:

```bash
# One path per line, comments start with #
~/bin
~/scripts
/opt/custom/bin
```

Use the `path` command to view all PATH entries:

```bash
$ path
     1  /home/user/.local/bin
     2  /usr/local/bin
     3  /usr/bin
     ...
```

### Environment Variables (`~/.env`)

Configure environment variables in `~/.env`:

```bash
USER_NAME="Your Name"
USER_EMAIL="your@email.com"
GIT_USER_NAME="Your Name"
GIT_USER_EMAIL="your@email.com"
```

Project-specific variables can be added to `./.env` in any directory - they automatically load when you `cd` into that directory.

**Commands:**
- `env_show` - Display current environment variables
- `env_reload` - Manually reload environment

## Aliases

### Navigation
| Alias | Description |
|-------|-------------|
| `..` | Go up one directory |
| `...` | Go up two directories |
| `ll` | List files (long format) |
| `la` | List all files including hidden |

### Git
| Alias | Description |
|-------|-------------|
| `g` | git |
| `gs` | git status |
| `ga` | git add |
| `gc` | git commit |
| `gcm` | git commit -m |
| `gd` | git diff |
| `gpl` | git pull |
| `gps` | git push |

### Chezmoi
| Alias | Description |
|-------|-------------|
| `cma` | chezmoi apply |
| `cmu` | chezmoi update |
| `chz` | Update, apply, and reload shell |

### Utilities
| Alias | Description |
|-------|-------------|
| `c` | clear |
| `h` | history |
| `src` | Reload shell configuration |

## Functions

### File Operations
| Function | Description |
|----------|-------------|
| `mkcd <dir>` | Create directory and cd into it |
| `extract <file>` | Extract various archive formats |
| `backup <file>` | Create a backup copy |

### Development
| Function | Description |
|----------|-------------|
| `gac <msg>` | git add all + commit |
| `gacp <msg>` | git add all + commit + push |
| `venv [name]` | Create and activate Python virtualenv |

### Network
| Function | Description |
|----------|-------------|
| `localip` | Show local IP address |
| `publicip` | Show public IP address |
| `port <num>` | Check what's using a port |

### Search
| Function | Description |
|----------|-------------|
| `ff <name>` | Find files by name |
| `ffe <ext>` | Find files by extension |

### System
| Function | Description |
|----------|-------------|
| `update` | Update system packages |
| `sysinfo` | Show system information |
| `weather [loc]` | Current weather |
| `forecast [loc]` | Weather forecast |

## Lazy Loading

Heavy tools are lazy-loaded for fast shell startup:

- **Node.js**: nvm, fnm, node, npm, npx
- **Python**: pyenv, conda, python, pip
- **Ruby**: rbenv, ruby, gem, bundle
- **Rust**: cargo, rustc
- **Go**: go

Tools are only initialized when first used.

## Customization

### Machine-Specific Configuration

Create `~/.bashrc.local` or `~/.zshrc.local` for machine-specific settings (not managed by chezmoi):

```bash
# ~/.bashrc.local
export CUSTOM_VAR="value"
alias myalias='my-command'
```

### Chezmoi Data

Configure chezmoi variables in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
name = "Your Name"
email = "your@email.com"
```

## Requirements

- **Shell**: Bash 4+ or Zsh 5+
- **Git**: Version 2.23+ (required for git-subrepo)
- **chezmoi**: Automatically installed if not present
- **Optional**: starship, htop, neofetch

## Included Tools

The following tools are automatically installed:

- **[Starship](https://starship.rs/)**: Cross-shell prompt with Pure preset
- **[git-subrepo](https://github.com/ingydotnet/git-subrepo)**: Git submodule alternative - simpler workflow for managing nested repositories
- **[Oh My Tmux](https://github.com/gpakosz/.tmux)**: Pretty and versatile tmux configuration

## License

MIT
