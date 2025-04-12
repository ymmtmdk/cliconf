#!/bin/bash

# Set target command list
if [ -n "${CLICONF_TARGET_COMMANDS}" ]; then
    _target_commands="${CLICONF_TARGET_COMMANDS}"
else
    _target_commands="grep find"
fi

# Define functions for each command
for cmd in ${_target_commands}; do
    if [ -n "$cmd" ]; then
        eval "
        $cmd() {
            if ! command -v \"\cliconf\" &> /dev/null; then
                echo \"cliconf command not found\" >&2
                command $cmd \"\$@\"
                return \$?
            fi
            \"\cliconf\" \"$cmd\" \"\$@\"
        }
        "
    fi
done