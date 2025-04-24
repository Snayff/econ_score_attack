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
var _filtered_entries: Array[DataLogEntry] = []
var _current_filter_state: Dictionary = {}

## Loads and displays the content of a log file
func load_file(file_path: String) -> void:
	# Clear existing content
	_clear_content()

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

	# Apply current filters and display
	_apply_filters()
	entries_updated.emit(_entries)

## Updates the filter state and refreshes the display
func update_filters(filter_state: Dictionary) -> void:
	_current_filter_state = filter_state
	_apply_filters()

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
	_filtered_entries = _entries.duplicate()
	_display_entries(_filtered_entries)
	entries_updated.emit(_entries)

## Adds a new entry node to the content container
func _add_entry_node(entry: DataLogEntry) -> void:
	var entry_node: Node = LogEntryScene.instantiate()
	%ContentContainer.add_child(entry_node)
	entry_node.display_entry(entry)

## Clears all content from the container
func _clear_content() -> void:
	for child in %ContentContainer.get_children():
		child.queue_free()
	_entries.clear()
	_filtered_entries.clear()

## Applies current filters and updates display
func _apply_filters() -> void:
	if _current_filter_state.is_empty():
		_filtered_entries = _entries.duplicate()
	else:
		_filtered_entries.clear()
		for entry in _entries:
			if _entry_matches_filters(entry):
				_filtered_entries.append(entry)

	_display_entries(_filtered_entries)

## Displays the given entries in the content container
func _display_entries(entries: Array[DataLogEntry]) -> void:
	# Clear existing display
	for child in %ContentContainer.get_children():
		child.queue_free()

	# Add filtered entries
	for entry in entries:
		_add_entry_node(entry)

## Checks if an entry matches the current filters
func _entry_matches_filters(entry: DataLogEntry) -> bool:
	if _current_filter_state.is_empty():
		return true

	# Check log level
	if not entry.level in _current_filter_state.levels:
		return false

	# Check search text
	if not _current_filter_state.search_text.is_empty():
		var search_text: String = _current_filter_state.search_text.to_lower()
		var message_matches := entry.message.to_lower().contains(search_text)
		var source_matches := entry.source.to_lower().contains(search_text)

		if not (message_matches or source_matches):
			return false

	return true

#endregion
