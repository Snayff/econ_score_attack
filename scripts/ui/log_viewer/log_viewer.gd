## A viewer for log files that provides filtering and search capabilities.
## This is the main control node that coordinates all log viewer components.
extends Control

const DataLogEntry := preload("res://scripts/ui/log_viewer/components/data_log_entry.gd")


#region SIGNALS


#endregion


#region CONSTANTS

const LOG_DIRECTORY := "dev/logs/"
const EXPORT_DIRECTORY := "dev/logs/exports/"

#endregion


#region ON READY

var _auto_refresh_timer: Timer
var _selected_entries: Array[DataLogEntry] = []

func _ready() -> void:
	assert(%FileSelector != null, "FileSelector node not found")
	assert(%LogContent != null, "LogContent node not found")
	assert(%LogHeader != null, "LogHeader node not found")
	assert(%LogFilters != null, "LogFilters node not found")

	%FileSelector.file_selected.connect(_on_file_selected)
	%LogContent.entries_updated.connect(_on_entries_updated)
	%LogFilters.filters_changed.connect(_on_filters_changed)
	%LogContent.entry_selected.connect(_on_entry_selected)
	%LogContent.copy_requested.connect(_on_copy_requested)

	# Create export directory if it doesn't exist
	DirAccess.make_dir_recursive_absolute(EXPORT_DIRECTORY)

	# Setup auto-refresh
	_setup_auto_refresh()

#endregion


#region EXPORTS


#endregion


#region PUBLIC FUNCTIONS

## Exports the currently filtered entries to a file
func export_filtered_entries() -> void:
	var timestamp := Time.get_datetime_string_from_system().replace(":", "-")
	var export_path := EXPORT_DIRECTORY.path_join("log_export_" + timestamp + ".log")

	var file := FileAccess.open(export_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to create export file: ", export_path)
		return

	var filtered_entries: Array[DataLogEntry] = %LogContent.get_filtered_entries()
	for entry in filtered_entries:
		file.store_line(entry.raw_text)

#endregion


#region PRIVATE FUNCTIONS

## Sets up auto-refresh functionality
func _setup_auto_refresh() -> void:
	_auto_refresh_timer = Timer.new()
	_auto_refresh_timer.wait_time = 5.0  # 5 seconds between refreshes
	_auto_refresh_timer.timeout.connect(_on_auto_refresh_timeout)
	add_child(_auto_refresh_timer)
	_auto_refresh_timer.start()

## Copies the selected entries to the clipboard
func _copy_entries(entries: Array[DataLogEntry]) -> void:
	if entries.is_empty():
		return

	var text := ""
	for entry in entries:
		text += entry.raw_text + "\n"

	DisplayServer.clipboard_set(text)

func _on_file_selected(file_path: String) -> void:
	%LogContent.load_file(file_path)

func _on_entries_updated(entries: Array[DataLogEntry]) -> void:
	%LogHeader.update_statistics(entries)

func _on_filters_changed(filter_state: Dictionary) -> void:
	%LogContent.update_filters(filter_state)

func _on_entry_selected(entry: DataLogEntry) -> void:
	if not Input.is_key_pressed(KEY_SHIFT):
		_selected_entries.clear()
	_selected_entries.append(entry)

func _on_copy_requested(entry: DataLogEntry) -> void:
	if _selected_entries.has(entry):
		_copy_entries(_selected_entries)
	else:
		_copy_entries([entry])

func _on_auto_refresh_timeout() -> void:
	%FileSelector.refresh_file_list()

#endregion
