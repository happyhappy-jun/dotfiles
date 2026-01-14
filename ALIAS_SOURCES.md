# Alias Sources Documentation

Based on the alias output from your terminal, here's where all the aliases are loaded from:

## Alias Sources Breakdown

### 1. **From Your Dotfiles (`~/.common/aliases.sh`)**

These aliases come from your chezmoi-managed dotfiles:

- `..`, `...`, `....`, `.....` - Directory navigation
- `dls`, `docs`, `dt`, `repos`, `archives` - Quick navigation
- `g`, `ga`, `gaa`, `gap`, `gb`, `gc`, `gcm`, `gco`, `gd`, `gds`, `gl`, `gpl`, `gps`, `gs`, `gst` - Git shortcuts
- `dk`, `dco`, `dcu`, `dcd`, `dcb` - Docker shortcuts
- `va`, `ve` - Python virtual environments
- `ls`, `ll`, `la` - File listing (OS-aware)
- `top` - Process monitor
- `update` - System update (Linux)
- `cb`, `cbpaste` - Clipboard operations
- `md5sum`, `sha1sum`, `sha256sum` - Hash calculations
- `chezmoiconf`, `powershellconf`, `sublimeconf` - Config navigation
- `chrome`, `firefox`, `edge`, `opera`, `browse` - Browser shortcuts
- `subl`, `sublst` - Editor shortcuts
- `showfiles`, `hidefiles` - File visibility (OS-specific)
- `cp`, `mv`, `rm` - Safety aliases (with -i flag)
- `c`, `cl` - Clear screen
- `h`, `hg` - History shortcuts

**Location**: `~/.common/aliases.sh` (managed by chezmoi)

### 2. **From oh-my-bash Framework**

Many aliases come from oh-my-bash (installed at `~/.oh-my-bash/`):

- `alias -- -='cd -'` - Previous directory
- `alias 1='cd -'`, `alias 2='cd -2'`, etc. - Directory stack navigation
- `alias _='sudo'` - Sudo shortcut
- `alias afind='ack -il'` - Ack find
- `alias cat='bat --paging=never --style=plain'` - Bat instead of cat
- `alias cd='_omb_directories_cd'` - Enhanced cd function
- `alias d='dirs -v | head -10'` - Directory stack display
- `alias po='popd'` - Pop directory
- `alias please='sudo'` - Polite sudo
- `alias rd='rmdir'` - Remove directory
- `alias l='ls -lha'` - Long listing
- `alias lsa='ls -lha'` - Long listing all
- `alias md='mkdir -p'` - Make directory
- `alias egrep`, `fgrep`, `grep` - Enhanced grep with exclusions

**Location**: `~/.oh-my-bash/` (oh-my-bash framework)
**Note**: oh-my-bash is likely loaded from a system-wide configuration or from `~/.bashrc.local` (if it exists)

### 3. **Custom/System-Specific Aliases**

These appear to be custom aliases specific to your environment:

- `alias micromamba='/virtual_lab/sjw_alinlab/byungjun_alinlab/.local/bin/micromamba'` - Micromamba path
- `alias mm='micromamba'` - Micromamba shortcut
- `alias sg='slurm-gres-viz'` - SLURM GPU visualization
- `alias sqm='squeue -u byungjun_alinlab'` - SLURM queue for user
- `alias squeue='squeue -o "%.18i %.9P %.40j %.8u %.2t %.10M %.6D %R"'` - Custom squeue format
- `alias sr1='srun --gpus 1 --pty bash'` - SLURM run with 1 GPU
- `alias sr2='srun --gpus 2 --pty bash'` - SLURM run with 2 GPUs
- `alias sr4='srun --gpus 4 --pty bash'` - SLURM run with 4 GPUs

**Location**: Likely in `~/.bashrc.local` or system-wide configuration

## How to Find Where oh-my-bash is Loaded

To find where oh-my-bash is being sourced, run:

```bash
# Check all bash config files
grep -r "oh-my-bash\|OMB" ~/.bashrc ~/.bash_profile ~/.profile ~/.bashrc.local /etc/bash.bashrc /etc/profile 2>/dev/null

# Check what's sourcing oh-my-bash
grep -r "source.*oh-my-bash\|\. .*oh-my-bash" ~/.bash* ~/.profile /etc/bash* /etc/profile* 2>/dev/null

# Check if it's in a system-wide config
ls -la /etc/profile.d/ | grep -i bash
```

## Summary

1. **Your dotfiles** (`~/.common/aliases.sh`) - Managed by chezmoi, contains cross-platform aliases
2. **oh-my-bash framework** (`~/.oh-my-bash/`) - Provides many enhanced aliases and functions
3. **Custom/system aliases** - Likely in `~/.bashrc.local` or system-wide configs

The oh-my-bash framework is being loaded from somewhere (possibly a system-wide configuration on your login node), which is why you see all those additional aliases beyond what's in your dotfiles.
