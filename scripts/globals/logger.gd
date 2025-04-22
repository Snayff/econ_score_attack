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

## Whether to write to file
var write_to_file: bool = false

## Path to log file
var log_file_path: String = "logs/game.log"

## Log file handle
var log_file: FileAccess

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

## Configuration file path
const CONFIG_PATH: String = "res://config/logger_config.json"
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

## Enable or disable file writing
## @param enabled: Whether to write to file
func set_write_to_file(enabled: bool) -> void:
	write_to_file = enabled
	if enabled and log_file == null:
		_open_log_file()
	elif not enabled and log_file != null:
		_close_log_file()

## Set the log file path
## @param path: The path to the log file
func set_log_file_path(path: String) -> void:
	log_file_path = path
	if write_to_file:
		_close_log_file()
		_open_log_file()

## Enable or disable signal emission
## @param enabled: Whether to emit signals
func set_emit_signals(enabled: bool) -> void:
	emit_signals = enabled

## Load configuration from file
func load_config() -> void:
	if not FileAccess.file_exists(CONFIG_PATH):
		error("Logger configuration file not found: " + CONFIG_PATH)
		return
		
	var file: FileAccess = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	var json_string: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	var parse_result: int = json.parse(json_string)
	
	if parse_result != OK:
		error("Failed to parse logger configuration: " + json.get_error_message())
		return
		
	var config: Dictionary = json.get_data()
	
	# Set log level
	if config.has("log_level"):
		var level_name: String = config["log_level"]
		for level in LEVEL_NAMES:
			if LEVEL_NAMES[level] == level_name:
				current_level = level
				break
	
	# Set output options
	if config.has("output"):
		var output: Dictionary = config["output"]
		if output.has("console"):
			print_to_console = output["console"]
		if output.has("file"):
			write_to_file = output["file"]
		if output.has("file_path"):
			log_file_path = output["file_path"]
	
	# Set formatting options
	if config.has("formatting"):
		var formatting: Dictionary = config["formatting"]
		if formatting.has("show_timestamps"):
			show_timestamps = formatting["show_timestamps"]
		if formatting.has("show_levels"):
			show_levels = formatting["show_levels"]
		if formatting.has("show_source"):
			show_source = formatting["show_source"]
	
	# Set signal options
	if config.has("signals"):
		var signals_config: Dictionary = config["signals"]
		if signals_config.has("emit_signals"):
			emit_signals = signals_config["emit_signals"]
	
	# Open log file if needed
	if write_to_file:
		_open_log_file()
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
		
	if write_to_file and log_file != null:
		log_file.store_line(formatted_message)
		
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

## Open the log file
func _open_log_file() -> void:
	# Create directory if it doesn't exist
	var dir: DirAccess = DirAccess.open("res://")
	if not dir.dir_exists("logs"):
		dir.make_dir("logs")
	
	# Open file for writing
	log_file = FileAccess.open(log_file_path, FileAccess.WRITE)
	if log_file == null:
		error("Failed to open log file: " + log_file_path)

## Close the log file
func _close_log_file() -> void:
	if log_file != null:
		log_file.close()
		log_file = null

## Called when the node enters the scene tree
func _ready() -> void:
	load_config()

## Called when the node is about to be removed from the scene tree
func _exit_tree() -> void:
	_close_log_file()
#endregion 