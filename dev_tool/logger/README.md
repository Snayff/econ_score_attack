# Logger Module

A comprehensive logging system for Godot 4.x projects with a built-in log viewer UI.

## Features

- Multiple log levels (DEBUG, INFO, WARNING, ERROR)
- Configurable output (console and/or file)
- Standardised message formatting
- Emoji indicators for different types of events
- Log file rotation
- Built-in log viewer with filtering and search capabilities

## Installation

1. Copy the `logger` directory into your project's `dev_tools` folder
2. Add the logger as an autoload in your project settings:
   - Name: Logger
   - Path: res://dev_tool/logger/logger.gd

## Basic Usage

```gdscript
# Log messages at different levels
Logger.debug("Detailed debug information")
Logger.info("Important state change")
Logger.warning("Potential issue detected")
Logger.error("Critical error occurred")

# Log with source information
Logger.info("Player joined", "GameServer")

# Log standardised events
Logger.log_state_change("health", -10, 90, "Combat")
Logger.log_resource_change("gold", 50, 150, "Quest")
Logger.log_money_change(100.0, 1000.0, "Transaction")
Logger.log_validation("SaveGame", true, "All data valid", "SaveSystem")
Logger.log_event("LevelComplete", {"score": 1000, "time": 120}, "GameLoop")
Logger.log_threshold_violation("MemoryUsage", 1000, 1200, "ResourceMonitor")
```

## Configuration

The logger can be configured through the `logger_config.json` file:

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

## Log Viewer

The log viewer provides a graphical interface for viewing and filtering log files:

1. Add the log viewer scene to your project:
   ```gdscript
   var log_viewer = preload("res://dev_tool/logger/ui/scenes/log_viewer.tscn").instantiate()
   add_child(log_viewer)
   ```

2. Features:
   - Filter by log level
   - Search by text
   - Filter by source
   - Filter by timestamp range
   - Copy log entries
   - Export filtered entries

## Message Patterns

The logger provides standardised message patterns for consistency:

- State Changes: "{attribute} changed {change:+d} → {new_value}"
- Resource Changes: "{resource} changed {amount:+d} → {new_total}"
- Events: "{event_name} [{details}]"
- Validations: "{validation_name}: {result} [{details}]"

## Emoji Indicators

The logger uses emoji indicators for different types of events:

- 📈 Increases
- 📉 Decreases
- ❌ Errors
- ⚠️ Warnings
- ✅ Success
- 💰 Money operations
- 📦 Resource operations 