## A data class representing a single log entry with parsing capabilities.
class_name DataLogEntry
extends RefCounted


#region CONSTANTS

enum Level {
	DEBUG,
	INFO,
	WARNING,
	ERROR
}

const LEVEL_COLOURS := {
	Level.DEBUG: Color.DARK_GRAY,
	Level.INFO: Color.WHITE,
	Level.WARNING: Color.YELLOW,
	Level.ERROR: Color.RED
}

#endregion


#region SIGNALS


#endregion


#region ON READY


#endregion


#region EXPORTS


#endregion


#region PUBLIC FUNCTIONS

var timestamp: String
var level: Level
var source: String
var message: String
var raw_text: String

## Creates a new log entry from a raw log line
static func from_line(line: String) -> DataLogEntry:
	var entry := DataLogEntry.new()
	entry.raw_text = line
	
	# Expected format: [TIMESTAMP] [LEVEL] [SOURCE] MESSAGE
	var regex := RegEx.new()
	regex.compile("\\[(.*?)\\]\\s*\\[(.*?)\\]\\s*\\[(.*?)\\]\\s*(.*)")
	
	var result := regex.search(line)
	if result:
		entry.timestamp = result.get_string(1).strip_edges()
		entry.level = _parse_level(result.get_string(2).strip_edges())
		entry.source = result.get_string(3).strip_edges()
		entry.message = result.get_string(4).strip_edges()
	else:
		# If parsing fails, treat the whole line as a message
		entry.timestamp = ""
		entry.level = Level.INFO
		entry.source = "Unknown"
		entry.message = line
	
	return entry

## Gets the colour associated with this log level
func get_colour() -> Color:
	return LEVEL_COLOURS[level]

#endregion


#region PRIVATE FUNCTIONS

## Parses a level string into a Level enum value
static func _parse_level(level_str: String) -> Level:
	match level_str.to_upper():
		"DEBUG": return Level.DEBUG
		"INFO": return Level.INFO
		"WARNING": return Level.WARNING
		"ERROR": return Level.ERROR
		_: return Level.INFO

#endregion 