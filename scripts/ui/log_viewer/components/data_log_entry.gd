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
	Level.DEBUG: Color(0.5, 0.5, 0.5),
	Level.INFO: Color(1, 1, 1),
	Level.WARNING: Color(1, 0.8, 0),
	Level.ERROR: Color(1, 0, 0)
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
	
	# Split on pipe delimiter with whitespace trimming
	var parts := Array(line.split(" | ")).map(func(p): return p.strip_edges())
	
	if parts.size() >= 3:
		entry.timestamp = parts[0]
		entry.level = _parse_level(parts[1])
		
		# Handle source if present (parts[2] if 4 parts, otherwise empty)
		if parts.size() >= 4:
			entry.source = parts[2]
			entry.message = parts[3]
		else:
			entry.source = ""
			entry.message = parts[2]
	
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