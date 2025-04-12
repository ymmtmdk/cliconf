#!/bin/bash

# Test result counter
total_tests=0
passed_tests=0
failed_tests=0

# Common variables
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cliconf_path="$script_dir/../cliconf.sh"
test_dir="$script_dir/integration"
global_config_dir="$test_dir/temp_global_config"

# Variables for colored output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Set up test environment
setup() {
    rm -rf "$test_dir/temp_*"
    mkdir -p "$global_config_dir"
    [[ "$VERBOSE" == true ]] && echo "Test environment set up in $test_dir"
}

# Clean up test environment
teardown() {
    rm -rf "$test_dir/temp_*"
    [[ "$VERBOSE" == true ]] && echo "Test environment cleaned up"
}

# Display test case start
start_test() {
    local test_name="$1"
    echo -n "Running test: $test_name ... "
    ((total_tests++))
}

# Display test success
pass_test() {
    echo -e "${GREEN}PASS${NC}"
    ((passed_tests++))
}

# Display test failure
fail_test() {
    local message="$1"
    echo -e "${RED}FAIL${NC}"
    echo "  $message"
    ((failed_tests++))
}

# Assert command success
assert_success() {
    if ! "$@"; then
        fail_test "Expected command to succeed: $*"
        return 1
    fi
}

# Assert command failure
assert_fail() {
    if "$@"; then
        fail_test "Expected command to fail: $*"
        return 1
    fi
}

# Assert standard output
assert_stdout() {
    local expected="$1"
    shift
    local output
    output=$("$@")
    
    if [[ "$output" != "$expected" ]]; then
        fail_test "Expected stdout: '$expected', but got: '$output'"
        return 1
    fi
}

# Assert standard error output
assert_stderr() {
    local expected="$1"
    shift
    local output
    output=$("$@" 2>&1 1>/dev/null)
    
    if [[ "$output" != "$expected" ]]; then
        fail_test "Expected stderr: '$expected', but got: '$output'"
        return 1
    fi
}

# Assert file content
assert_file_content() {
    local expected="$1"
    local file="$2"
    
    if [[ ! -f "$file" ]]; then
        fail_test "File does not exist: $file"
        return 1
    fi
    
    local content
    content=$(cat "$file")
    
    if [[ "$content" != "$expected" ]]; then
        fail_test "Expected file content: '$expected', but got: '$content'"
        return 1
    fi
}

# Test case 1: Basic execution
test_basic_execution() {
    start_test "Basic execution without config"
    
    # Execute without configuration
    assert_success "$cliconf_path" echo "hello"
    pass_test
}

# Test case 2: Global configuration only
test_global_config_only() {
    start_test "Execution with global config only"
    
    # Create global configuration
    mkdir -p "$global_config_dir"
    echo "-n" > "$global_config_dir/.echo.conf"
    
    # Execute with global configuration
    assert_stdout "test" "$cliconf_path" --test-global-dir "$global_config_dir" echo "test"
    pass_test
}

# Test case 3: Local configuration only
test_local_config_only() {
    start_test "Execution with local config only"
    
    # Create local configuration
    echo "-n" > "$test_dir/.echo.conf"
    cd "$test_dir"
    
    # Execute with local configuration
    assert_stdout "test" "$cliconf_path" echo "test"
    cd - > /dev/null
    pass_test
}

# Test case 4: Both global and local configurations
test_both_configs() {
    start_test "Execution with both global and local configs"
    
    # Create global configuration
    mkdir -p "$global_config_dir"
    echo "-n" > "$global_config_dir/.echo.conf"
    
    # Create local configuration (should take precedence)
    echo "-e" > "$test_dir/.echo.conf"
    cd "$test_dir"
    
    # Execute with both configurations (local takes precedence)
    assert_success "$cliconf_path" --test-global-dir "$global_config_dir" echo "test"
    cd - > /dev/null
    pass_test
}

# Test case 5: Show subcommand
test_show_command() {
    start_test "Show command"
    
    # Create global configuration
    mkdir -p "$global_config_dir"
    echo "-n" > "$global_config_dir/.echo.conf"
    
    # Execute show command
    assert_success "$cliconf_path" --test-global-dir "$global_config_dir" show echo
    pass_test
}

# Main process
main() {
    # Set up trap for cleanup
    trap teardown EXIT
    
    # Set up test environment
    setup
    
    # Execute test cases
    test_basic_execution
    test_global_config_only
    test_local_config_only
    test_both_configs
    test_show_command
    
    # Display test results summary
    echo "----------------------------------------"
    echo "Test Summary:"
    echo "  Total:  $total_tests"
    echo "  Passed: $passed_tests"
    echo "  Failed: $failed_tests"
    
    # Set exit code
    [[ $failed_tests -eq 0 ]]
}

# Execute script
main "$@"
