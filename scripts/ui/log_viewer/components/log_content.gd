## Component for displaying log file content.
extends ScrollContainer

const DataLogEntry := preload("res://scripts/ui/log_viewer/components/data_log_entry.gd")
const LogEntryScene := preload("res://scenes/ui/log_viewer/components/log_entry.tscn")


#region SIGNALS

signal entries_updated(entries: Array[DataLogEntry])

#endregion


#region CONSTANTS


#endregion


#region ON READY

func _ready() -> void:
	assert(%ContentContainer != null, "ContentContainer node not found")

#endregion


#region EXPORTS


#endregion


#region PUBLIC FUNCTIONS

var _entries: Array[DataLogEntry] = []

## Loads and displays the content of a log file
func load_file(file_path: String) -> void:
	# Clear existing content
	for child in %ContentContainer.get_children():
		child.queue_free()
	_entries.clear()

	# Read and parse file
	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open log file: ", file_path)
		_display_error("Error: Failed to open log file")
		return

	while not file.eof_reached():
		var line := file.get_line()
		if line.strip_edges().is_empty():
			continue

		var entry := DataLogEntry.from_line(line)
		_entries.append(entry)
		_add_entry_node(entry)

	entries_updated.emit(_entries)

#endregion


#region PRIVATE FUNCTIONS

## Displays an error message in the content area
func _display_error(message: String) -> void:
	var entry := DataLogEntry.new()
	entry.timestamp = Time.get_datetime_string_from_system()
	entry.level = DataLogEntry.Level.ERROR
	entry.source = "LogViewer"
	entry.message = message
	entry.raw_text = message

	_entries = [entry]
	_add_entry_node(entry)
	entries_updated.emit(_entries)

## Adds a new entry node to the content container
func _add_entry_node(entry: DataLogEntry) -> void:
	var entry_node: Node = LogEntryScene.instantiate()
	%ContentContainer.add_child(entry_node)
	entry_node.display_entry(entry)

#endregion
