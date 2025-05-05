# Tester System Documentation

## Purpose and Intent

The tester system provides a modular, extensible framework for automated testing of game logic and features. It enables developers to write, organise, and execute unit and integration tests, track results, and ensure code quality across the project. The system is designed for clarity, maintainability, and ease of use.

---

## Architecture

The tester system is composed of:
- **TestSuite**: The main test runner and orchestrator.
- **ABCTest**: The abstract base class for all test cases, providing common assertions and lifecycle hooks.
- **test_runner.json**: The configuration file specifying test categories, paths, and output options.
- **Test Scripts**: Individual test scripts (typically named `test_*.gd`) implementing specific test cases.

### Architecture Diagram
```
+-------------------+
|   TestSuite       |
| (test_suite.gd)   |
+-------------------+
        |
        | loads config
        v
+-------------------+
| test_runner.json  |
+-------------------+
        |
        | discovers & runs
        v
+-------------------+
|  Test Scripts     |
| (test_*.gd)       |
+-------------------+
        |
        | extend
        v
+-------------------+
|    ABCTest        |
| (abc_test.gd)     |
+-------------------+
```

---

## Test Lifecycle

1. **Configuration**: TestSuite loads `test_runner.json` to determine enabled categories, test paths, and output settings.
2. **Discovery**: For each enabled category, TestSuite discovers test scripts in the specified directories.
3. **Execution**: TestSuite instantiates each test script, running all methods prefixed with `test_`. Each test method:
   - Calls `before_each()` (optional setup)
   - Executes the test logic
   - Calls `after_each()` (optional teardown)
   - Uses assertions (e.g., `assert_eq`, `assert_true`) to validate behaviour
   - Emits a `test_completed` signal with the result
4. **Result Collection**: TestSuite aggregates results, logs output, and writes a summary to the configured output directory.

---

## Configuration (`test_runner.json`)

- **output_directory**: Where test results are written (e.g., `dev/test_results/`)
- **categories**: Defines test categories (e.g., `unit`, `integration`), their enabled status, and test paths
- **output_format**: Controls verbosity and inclusion of stack traces

Example:
```json
{
  "output_directory": "dev/test_results/",
  "categories": {
    "unit": {
      "enabled": true,
      "test_paths": ["shared/tests/unit/"]
    },
    "integration": {
      "enabled": true,
      "test_paths": ["shared/tests/integration/"]
    }
  },
  "output_format": {
    "include_stack_traces": true,
    "verbose": true
  }
}
```

---

## Writing Tests

- All test scripts should extend `ABCTest`.
- Test methods must be prefixed with `test_` (e.g., `func test_addition(): ...`).
- Use assertions such as `assert_eq`, `assert_true`, and `assert_gt` to validate outcomes.
- Optionally override `before_each()` and `after_each()` for setup/teardown logic.

Example:
```gdscript
class_name TestMyFeature
extends ABCTest

func before_each():
    # Setup code
    pass

func test_addition():
    assert_eq(2 + 2, 4, "Basic math should work")

func after_each():
    # Teardown code
    pass
```

---

## Running Tests

- Run all tests by calling `TestSuite.run_all_tests()`.
- Results are printed to the console and written to the output directory as a JSON log.
- Each test result includes status, optional message, and stack trace for failures.

---

## Extending the System
- Add new test categories or paths in `test_runner.json`.
- Implement new assertion helpers in `ABCTest` as needed.
- Integrate with CI/CD pipelines by invoking the test runner and parsing output logs.

---

## Developer Notes
- Keep tests focused, independent, and repeatable.
- Use descriptive names for test methods and assertions.
- Group related tests into categories for clarity and selective execution.
- Review test output regularly to maintain code quality.

## Associated Files
- `dev_tool/tester/test_suite.gd`
- `dev_tool/tester/abc_test.gd`
- `dev_tool/tester/test_runner.json`

## Last Updated
2025-05-04 