#!/bin/bash

# Installation directory
INSTALL_DIR="$HOME/bin"
CONFIG_DIR="$HOME/.config/cliconf"
SCRIPTS_DIR="$CONFIG_DIR/scripts"

# Installation confirmation
echo "Installing cliconf"
echo "Installation directory: $INSTALL_DIR/cliconf"
echo "Configuration directory: $CONFIG_DIR"

# Create necessary directories
mkdir -p "$CONFIG_DIR"
mkdir -p "$SCRIPTS_DIR"

# Install script
cp cliconf.sh "$INSTALL_DIR/cliconf"
chmod +x "$INSTALL_DIR/cliconf"

# Copy sample configuration files
if [[ -d "examples" ]]; then
    cp -r examples/.[!.]* "$CONFIG_DIR/"
    echo "Sample configuration files have been copied"
fi
# Copy shell integration scripts
cp scripts/cliconf_integrate.bash "$SCRIPTS_DIR/"
cp scripts/cliconf_integrate.fish "$SCRIPTS_DIR/"

echo "Installation completed"
echo ""
echo "Shell integration setup:"
echo ""
echo "For Bash users, add the following to .bashrc:"
echo "source $SCRIPTS_DIR/cliconf_integrate.bash"
echo ""
echo "For Fish Shell users, add the following to ~/.config/fish/config.fish:"
echo "source $SCRIPTS_DIR/cliconf_integrate.fish"
echo ""
echo "Optional: To customize integrated commands, set environment variables before the source command:"
echo 'export CLICONF_TARGET_COMMANDS="grep find ls"  # For Bash'
echo 'set -gx CLICONF_TARGET_COMMANDS "grep find ls" # For Fish Shell'
echo ""
echo "Traditional alias method is also available:"
echo 'for cmd in grep find ls curl; do'
echo '  alias $cmd="cliconf $cmd"'
echo 'done'
echo 'done'
