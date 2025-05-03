# Logger System

## Overview
The Logger System provides a centralised, configurable logging facility for the game. It supports multiple log levels, output to both console and file, and a built-in log viewer UI. The logger is designed to be autoloaded as a singleton, making it accessible from anywhere in the project.

## Intent
- Provide consistent, structured logging for debugging, monitoring, and auditing game events.
- Support log file rotation and retention to manage disk usage and keep logs relevant.
- Allow configuration of log output, formatting, and retention via external JSON config.
- Enable developers to easily log events, errors, and state changes with minimal boilerplate.

## Usage
- The logger is autoloaded as `Logger`.
- Log messages using:
  - `Logger.debug(message: String, source: String = "")`
  - `Logger.info(message: String, source: String = "")`
  - `Logger.warning(message: String, source: String = "")`
  - `Logger.error(message: String, source: String = "")`
- Log standardised events using helper methods (e.g., `log_state_change`, `log_resource_change`, etc.).
- The logger can be configured via `dev_tools/logger/config/logger_config.json`.

## Log Retention Policy
- **On every game start, old log files are deleted, retaining only the most recent as per the `max_log_files` config, regardless of whether file logging is enabled.**
- This ensures the log directory never grows unbounded and always contains only the most recent logs.
- Log files are stored in the directory specified by `file_path` in the config (default: `dev/logs`).

### Log Retention Data Schema
- `max_log_files` (int): Maximum number of log files to retain. Older files are deleted on game start.
- `file_path` (string): Directory where log files are stored.
- Log files are named using ISO date-time format for easy sorting and identification.

## Configuration Example
```json
{
  "log_level": "DEBUG",
  "output": {
    "console": true,
    "file": true,
    "file_path": "dev/logs",
    "max_log_files": 7
  },
  "formatting": {
    "show_timestamps": true,
    "show_levels": true,
    "show_source": true
  },
  "signals": {
    "emit_signals": true
  }
}
```

## Developer Notes
- The logger will always prune old log files on game start, even if file logging is disabled.
- To change retention, update `max_log_files` in the config.
- The logger must be autoloaded for log retention and logging to function correctly.
- Log viewer UI is available for in-game log inspection and filtering.

## Example
```gdscript
Logger.info("Game started", "Main")
Logger.log_event("player_action", {"action": "build", "building": "farm"}, "GameLoop")
``` 