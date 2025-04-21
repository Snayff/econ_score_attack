## Logger
## Centralised logging system for the application
## Provides consistent formatting and control over log output
#@icon("")
extends Node


#region SIGNALS
signal log_message(level: String, message: String)
#endregion


#region VARS
## Log levels
enum Level {
	DEBUG,
	INFO,
	WARNING,
	ERROR
}

## Current log level
var current_level: int = Level.INFO

## Whether to show timestamps
var show_timestamps: bool = true

## Whether to show log levels
var show_levels: bool = true

## Whether to show source
var show_source: bool = true

## Whether to print to console
var print_to_console: bool = true

## Whether to emit signals
var emit_signals: bool = true

## Log level names
const LEVEL_NAMES: Dictionary = {
	Level.DEBUG: "DEBUG",
	Level.INFO: "INFO",
	Level.WARNING: "WARNING",
	Level.ERROR: "ERROR"
}

## Log level colors
const LEVEL_COLORS: Dictionary = {
	Level.DEBUG: Color(0.5, 0.5, 0.5),
	Level.INFO: Color(1, 1, 1),
	Level.WARNING: Color(1, 0.8, 0),
	Level.ERROR: Color(1, 0, 0)
}
#endregion


#region PUBLIC FUNCS
## Log a debug message
## @param message: The message to log
## @param source: The source of the message (optional)
func debug(message: String, source: String = "") -> void:
	_log(Level.DEBUG, message, source)

## Log an info message
## @param message: The message to log
## @param source: The source of the message (optional)
func info(message: String, source: String = "") -> void:
	_log(Level.INFO, message, source)

## Log a warning message
## @param message: The message to log
## @param source: The source of the message (optional)
func warning(message: String, source: String = "") -> void:
	_log(Level.WARNING, message, source)

## Log an error message
## @param message: The message to log
## @param source: The source of the message (optional)
func error(message: String, source: String = "") -> void:
	_log(Level.ERROR, message, source)

## Set the current log level
## @param level: The new log level
func set_level(level: int) -> void:
	current_level = level

## Enable or disable timestamps
## @param enabled: Whether to show timestamps
func set_show_timestamps(enabled: bool) -> void:
	show_timestamps = enabled

## Enable or disable log levels
## @param enabled: Whether to show log levels
func set_show_levels(enabled: bool) -> void:
	show_levels = enabled

## Enable or disable source
## @param enabled: Whether to show source
func set_show_source(enabled: bool) -> void:
	show_source = enabled

## Enable or disable console printing
## @param enabled: Whether to print to console
func set_print_to_console(enabled: bool) -> void:
	print_to_console = enabled

## Enable or disable signal emission
## @param enabled: Whether to emit signals
func set_emit_signals(enabled: bool) -> void:
	emit_signals = enabled
#endregion


#region PRIVATE FUNCS
## Internal logging function
## @param level: The log level
## @param message: The message to log
## @param source: The source of the message
func _log(level: int, message: String, source: String = "") -> void:
	if level < current_level:
		return
		
	var formatted_message: String = _format_message(level, message, source)
	
	if print_to_console:
		print(formatted_message)
		
	if emit_signals:
		emit_signal("log_message", LEVEL_NAMES[level], formatted_message)

## Format a log message
## @param level: The log level
## @param message: The message to log
## @param source: The source of the message
## @return: The formatted message
func _format_message(level: int, message: String, source: String = "") -> String:
	var parts: Array = []
	
	if show_timestamps:
		parts.append(Time.get_datetime_string_from_system())
		
	if show_levels:
		parts.append(LEVEL_NAMES[level])
		
	if show_source and source != "":
		parts.append(source)
		
	parts.append(message)
	
	return " | ".join(parts)
#endregion 