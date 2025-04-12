#!/usr/bin/env fish

# Set target command list
if set -q CLICONF_TARGET_COMMANDS
    set -g _target_commands $CLICONF_TARGET_COMMANDS
else
    set -g _target_commands grep find
end

# Define functions for each command
for cmd in $_target_commands
    if test -n "$cmd"
        eval "
        function $cmd
            if not command -q cliconf
                echo \"cliconf command not found\" >&2
                command $cmd \$argv
                return \$status
            end
            cliconf \"$cmd\" \$argv
        end
        "
    end
end