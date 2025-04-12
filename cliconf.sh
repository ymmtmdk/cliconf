#!/bin/bash
VERSION="0.1.0"
export TEST_GLOBAL_DIR=""

# Function to get configuration directory
get_config_dir() {
    [[ "$VERBOSE" == true ]] && echo "Current TEST_GLOBAL_DIR: '$TEST_GLOBAL_DIR'" >&2
    local dir
    if [[ -n "$TEST_GLOBAL_DIR" ]]; then
        dir="$TEST_GLOBAL_DIR"
        [[ "$VERBOSE" == true ]] && echo "Using test global config directory: $dir" >&2
    else
        dir="$HOME/.config/cliconf"
        [[ "$VERBOSE" == true ]] && echo "Using default config directory: $dir" >&2
    fi
    echo "$dir"
}

# Base directory for local configuration
LOCAL_DIR="$PWD"


# Show usage information
show_usage() {
    cat << EOF
cliconf - Hierarchical Configuration Management Framework for Command Line Tools

Usage:
  cliconf [OPTIONS] COMMAND [ARGS...]
  cliconf show COMMAND
  cliconf --help

Options:
  --help          Show this help message
  --version       Show version information
  --no-global     Ignore global configuration
  --no-local      Ignore local configuration
  --no-config     Ignore all configurations
  --verbose       Show detailed information

Commands:
  show            Display current configuration for specified command
EOF
    exit 0
}

# Show version information
show_version() {
    echo "cliconf version $VERSION"
    exit 0
}

# Find global configuration file
find_global_config() {
    local cmd=$1
    local config_dir=$(get_config_dir)
    [[ "$VERBOSE" == true ]] && echo "Starting global configuration search..." >&2
    [[ "$VERBOSE" == true ]] && echo "Configuration directory: $config_dir" >&2
    
    local global_conf="$config_dir/.${cmd}.conf"
    [[ "$VERBOSE" == true ]] && echo "Search path: $global_conf" >&2
    
    if [[ -f "$global_conf" ]]; then
        [[ "$VERBOSE" == true ]] && echo "Status: File exists" >&2
        echo "$global_conf"
    else
        [[ "$VERBOSE" == true ]] && echo "Status: File not found" >&2
        echo ""
    fi
}

# Find local configuration file
find_local_config() {
    local cmd=$1
    local local_conf="$LOCAL_DIR/.${cmd}.conf"
    [[ "$VERBOSE" == true ]] && echo "Local configuration file path: $local_conf" >&2
    
    if [[ -f "$local_conf" ]]; then
        [[ "$VERBOSE" == true ]] && echo "Local configuration file found" >&2
        echo "$local_conf"
    else
        [[ "$VERBOSE" == true ]] && echo "Local configuration file not found" >&2
        echo ""
    fi
}

# Load valid options from configuration file
load_config_file() {
    local config_file=$1
    local options=""
    
    if [[ -f "$config_file" ]]; then
        # Load file excluding comment lines
        options=$(grep -v '^[[:space:]]*#' "$config_file" | grep -v '^[[:space:]]*$')
        [[ "$VERBOSE" == true ]] && echo "Content loaded from configuration file ($config_file): '$options'" >&2
    fi
    
    echo "$options"
}

# Apply and execute command with configuration
execute_with_config() {
    local cmd=$1
    shift
    
    local use_global=true
    local use_local=true
    
    # Process special flags
    while [[ "$1" == --no-* ]]; do
        case "$1" in
            --no-global)
                use_global=false
                shift
                ;;
            --no-local)
                use_local=false
                shift
                ;;
            --no-config)
                use_global=false
                use_local=false
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    local options=""
    
    # Load local configuration (loaded first, so global configuration takes precedence)
    if [[ "$use_local" == true ]]; then
        local local_conf=$(find_local_config "$cmd")
        if [[ -n "$local_conf" ]]; then
            options+=" $(load_config_file "$local_conf")"
            [[ "$VERBOSE" == true ]] && echo "Loaded local configuration: $local_conf" >&2
        fi
    fi

    # Load global configuration (loaded after to override local configuration)
    if [[ "$use_global" == true ]]; then
        local global_conf=$(find_global_config "$cmd")
        if [[ -n "$global_conf" ]]; then
            options+=" $(load_config_file "$global_conf")"
            [[ "$VERBOSE" == true ]] && echo "Loaded global configuration: $global_conf" >&2
        fi
    fi
    
    # Trim options
    options=$(echo "$options" | xargs)
    
    # Display details in verbose mode
    if [[ "$VERBOSE" == true ]]; then
        echo "Command execution details:" >&2
        echo "  Applied configuration:" >&2
        [[ "$use_global" == true ]] && echo "    - Global configuration: Enabled" >&2 || echo "    - Global configuration: Disabled" >&2
        [[ "$use_local" == true ]] && echo "    - Local configuration: Enabled" >&2 || echo "    - Local configuration: Disabled" >&2
        echo "  Final command:" >&2
        echo "    $cmd $options $@" >&2
        echo "----------------------------------------" >&2
    fi
    
    # Execute command
    eval "$cmd $options $@"
    local exit_code=$?
    
    [[ "$VERBOSE" == true ]] && echo "Command exit code: $exit_code" >&2
    return $exit_code
}

# Show configuration
show_config() {
    local cmd=$1
    if [[ -z "$cmd" ]]; then
        echo "Error: No command specified" >&2
        return 1
    fi

    [[ "$VERBOSE" == true ]] && {
        echo "Searching configuration for command $cmd..." >&2
        echo "Starting global configuration search..." >&2
    }
    local global_conf=$(find_global_config "$cmd")
    [[ "$VERBOSE" == true ]] && {
        if [[ -n "$global_conf" ]]; then
            echo "Global configuration found: $global_conf" >&2
        else
            echo "Global configuration not found" >&2
        fi
        echo "Starting local configuration search..." >&2
    }
    local local_conf=$(find_local_config "$cmd")
    
    echo "Configuration information: $cmd"
    echo "----------------------------------------"
    
    # Display global configuration
    echo "Global configuration:"
    if [[ -n "$global_conf" ]]; then
        [[ "$VERBOSE" == true ]] && echo "Loading global configuration: $global_conf" >&2
        echo "  File: $global_conf"
        echo "  Content:"
        if [[ -s "$global_conf" ]]; then
            sed 's/^/    /' "$global_conf"
        else
            echo "    (empty file)"
        fi
    else
        echo "  No configuration file"
    fi
    
    echo ""
    # Display local configuration
    echo "Local configuration:"
    if [[ -n "$local_conf" ]]; then
        [[ "$VERBOSE" == true ]] && echo "Loading local configuration: $local_conf" >&2
        echo "  File: $local_conf"
        echo "  Content:"
        if [[ -s "$local_conf" ]]; then
            sed 's/^/    /' "$local_conf"
        else
            echo "    (empty file)"
        fi
    else
        echo "  No configuration file"
    fi
    
    # Display active options
    echo ""
    echo "Active options:"
    local global_options=$(load_config_file "$global_conf")
    local local_options=$(load_config_file "$local_conf")
    
    if [[ "$VERBOSE" == true ]]; then
        echo "Configuration analysis details:"
        [[ -n "$global_conf" ]] && echo "  Global configuration file: $global_conf"
        [[ -n "$local_conf" ]] && echo "  Local configuration file: $local_conf"
        echo "  Load results:"
        [[ -n "$global_options" ]] && echo "    Global configuration: $cmd $global_options"
        [[ -n "$local_options" ]] && echo "    Local configuration: $cmd $local_options"
        echo "----------------------------------------"
    fi

    if [[ -n "$global_options" || -n "$local_options" ]]; then
        [[ -n "$global_options" ]] && echo "  Global: $cmd $global_options"
        [[ -n "$local_options" ]] && echo "  Local : $cmd $local_options"
        echo "  Final application: $cmd $global_options $local_options"
    else
        echo "  No configuration"
    fi
}

# Main process
main() {
    # Show help if no arguments provided
    if [[ $# -eq 0 ]]; then
        show_usage
    fi
    
    # Initialize options
    VERBOSE=false
    NO_GLOBAL=false
    NO_LOCAL=false
    NO_CONFIG=false
    export TEST_GLOBAL_DIR=""

    # Process options
    while [[ "$1" == --* ]]; do
        case "$1" in
            --verbose)
                VERBOSE=true
                shift
                ;;
            --no-global)
                NO_GLOBAL=true
                shift
                ;;
            --no-local)
                NO_LOCAL=true
                shift
                ;;
            --no-config)
                NO_CONFIG=true
                shift
                ;;
            --test-global-dir)
                shift
                TEST_GLOBAL_DIR="$1"
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    # Process special commands
    case "$1" in
        --help)
            show_usage
            ;;
        --version)
            show_version
            ;;
        show)
            shift
            show_config "$@"
            ;;
        *)
            # Normal command execution
            local cmd=$1
            shift
            # Add --no-* options
            local opts=""
            [[ "$NO_GLOBAL" == true ]] && opts+="--no-global "
            [[ "$NO_LOCAL" == true ]] && opts+="--no-local "
            [[ "$NO_CONFIG" == true ]] && opts+="--no-config "
            execute_with_config "$cmd" $opts"$@"
            ;;
    esac
}

# Execute script
main "$@"