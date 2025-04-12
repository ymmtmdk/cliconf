# Developer Documentation

## Project Structure

```
cliconf/
├── cliconf.sh        # Main script
├── install.sh        # Installation script
├── scripts/          # Shell integration scripts
├── examples/         # Configuration examples
├── test/            # Test suite
└── docs/            # Documentation
```

## Core Components

### Configuration Management System

The code consists of the following main components:

1. **Configuration File Search**
   - `find_global_config()`: Search for global configuration files
   - `find_local_config()`: Search for local configuration files
   - Default global configuration directory: `~/.config/cliconf/`
   - Local configuration: `.*.conf` files in the current directory

2. **Configuration Loading and Execution**
   - `load_config_file()`: Parse configuration files
   - `execute_with_config()`: Apply configuration and execute commands
   - Merge process for global and local configurations

3. **Utility Functions**
   - `show_config()`: Display current configuration settings

### Configuration File Format

Configuration files are simple text files that follow these rules:

- One option per line
- Lines starting with `#` are comments
- Empty lines are ignored
- Each line must be in a format that can be used directly as a command-line option

Example:
```bash
# grep configuration example
--color=auto
--exclude-dir=.git
--exclude-dir=node_modules
```

## Development Environment Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/ymmtmdk/cliconf.git
   cd cliconf
   ```

2. Required tools:
   - Bash 4.0 or higher
   - Shell script syntax checker (shellcheck recommended)

## Testing

### Test Structure

Tests are organized into the following categories:

- Integration tests: `test/run_integration_tests.sh`
  - Basic execution tests
  - Configuration tests
    - Global configuration
    - Local configuration
    - Priority settings
  - Show command tests

### Running Tests

```bash
# Run all tests
./test/run_integration_tests.sh

# Run with detailed logging
VERBOSE=true ./test/run_integration_tests.sh
```

### Adding Test Cases

1. Add a new test function to `test/run_integration_tests.sh`:
   ```bash
   test_new_feature() {
       start_test "New feature test"
       
       # Test setup
       
       # Test execution and assertions
       assert_success "$cliconf_path" [commands...]
       
       # Record success
       pass_test
   }
   ```

2. Add the new test to the test execution list in the `main()` function

### Available Assertions

- `assert_success`: Verify that a command succeeds
- `assert_fail`: Verify that a command fails
- `assert_stdout`: Check standard output content
- `assert_stderr`: Check standard error output content
- `assert_file_content`: Check file content