# cliconf

Hierarchical Configuration Management Framework for Command-line Tools

## Overview

`cliconf` is a simple yet powerful framework for managing command-line tool configurations at both global (user-wide) and local (project-specific) levels. Inspired by Git's configuration system, it provides similar hierarchical configuration capabilities for any command-line tool.

## Background and Purpose

Many command-line tools lack configuration file support, but there are many cases where you want to use different settings for each project:

- Exclude specific directories and files with `grep`
- Use project-specific patterns with the `find` command
- Set project-specific flags for build tools and test runners

`cliconf` provides hierarchical configuration management capabilities to these tools as an add-on, streamlining command-line operations.

## Key Features

- **Two-level Configuration Hierarchy**: Global and local (project) settings
- **Versatility**: Compatible with any command-line tool
- **Override Mechanism**: Local settings override global settings
- **Simple Configuration Files**: Intuitive one-option-per-line format
- **Configuration Discovery**: Automatically finds appropriate configuration files within projects
- **Configuration Display**: View currently applied settings

## Installation and Requirements

### System Requirements
- Bash 4.0 or higher

### Installation Method

```bash
# Clone repository from GitHub
git clone https://github.com/ymmtmdk/cliconf.git
cd cliconf

# Install
./install.sh
```

Or use the source directly:

```bash
source /path/to/cliconf.sh
```

### Shell Integration

#### Shell Function Integration (Recommended)

For Bash users, add to `.bashrc`, for Fish Shell users, add to `~/.config/fish/config.fish`:

```bash
# For Bash
source /path/to/cliconf/scripts/cliconf_integrate.bash

# For Fish Shell
source /path/to/cliconf/scripts/cliconf_integrate.fish
```

By default, `grep` and `find` commands are integrated. To customize integrated commands, set environment variables:

```bash
# For Bash
export CLICONF_TARGET_COMMANDS="grep find ls"
source /path/to/cliconf/scripts/cliconf_integrate.bash

# For Fish Shell
set -gx CLICONF_TARGET_COMMANDS "grep find ls"
source /path/to/cliconf/scripts/cliconf_integrate.fish
```

## Basic Usage

### Command Execution

```bash
# Basic format
cliconf <command> [arguments...]

# Example: Running grep command
cliconf grep "function" src/

# Example: Running find command
cliconf find . -name "*.js"
```

### Creating Configuration Files

#### Global Configuration (Applied to All Projects)

```bash
# Create global configuration directory
mkdir -p ~/.config/cliconf

# Global grep configuration
cat > ~/.config/cliconf/.grep.conf << EOF
--color=auto
--exclude-dir=.git
--exclude-dir=node_modules
--exclude-dir=dist
EOF

# Global find configuration
cat > ~/.config/cliconf/.find.conf << EOF
-not -path "*/node_modules/*"
-not -path "*/.git/*"
EOF
```

#### Local Configuration (Applied to Specific Projects)

```bash
# Project-specific grep configuration
cat > .grep.conf << EOF
--include=*.{js,ts,jsx,tsx}
--exclude=*.min.js
EOF
```

### Checking Configuration

```bash
# Display current applied configuration
cliconf show grep

# Check where configurations are loaded from
cliconf show --verbose grep
```

### Temporarily Disabling Specific Configuration

```bash
# Execute command ignoring global configuration
cliconf --no-global grep "pattern"

# Execute command ignoring local configuration
cliconf --no-local grep "pattern"

# Execute command ignoring all configurations (run raw command)
cliconf --no-config grep "pattern"
```

## Technical Specifications

### File Structure

- Global configuration: `~/.config/cliconf/.<command>.conf`
- Local configuration: `.<command>.conf` in project directory

### Configuration File Format

Each configuration file follows this simple format:

```
# Comment line
--option1
--option2=value
--flag
```

Written in a format that can be passed directly as command-line arguments.

### Core Components

1. **Configuration Loading**: File reading and parsing
2. **Configuration Merging**: Integration of global and local settings
3. **Configuration Application**: Apply settings during command execution
4. **Utility Functions**: Display settings, export functionality, etc.

## License

MIT