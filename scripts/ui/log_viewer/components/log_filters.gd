## Component for managing log filtering options.
extends PanelContainer

const DataLogEntry := preload("res://scripts/ui/log_viewer/components/data_log_entry.gd")


#region SIGNALS

## Emitted when filter settings change
signal filters_changed(filter_state: Dictionary)

#endregion


#region CONSTANTS

const SEARCH_DEBOUNCE_TIME := 0.3  # Seconds to wait before applying search filter

#endregion


#region ON READY

func _ready() -> void:
	assert(%chk_Debug != null, "Debug checkbox not found")
	assert(%chk_Info != null, "Info checkbox not found")
	assert(%chk_Warning != null, "Warning checkbox not found")
	assert(%chk_Error != null, "Error checkbox not found")
	assert(%txt_Search != null, "Search textbox not found")

	# Connect signals
	%chk_Debug.toggled.connect(_on_filter_changed)
	%chk_Info.toggled.connect(_on_filter_changed)
	%chk_Warning.toggled.connect(_on_filter_changed)
	%chk_Error.toggled.connect(_on_filter_changed)
	%txt_Search.text_changed.connect(_on_search_changed)

	# Initial filter state
	_emit_current_filter_state()

#endregion


#region EXPORTS


#endregion


#region PUBLIC FUNCTIONS

## Gets the current filter state
func get_filter_state() -> Dictionary:
	return {
		"levels": _get_active_levels(),
		"search_text": %txt_Search.text
	}

## Applies filters to a list of entries
func apply_filters(entries: Array[DataLogEntry]) -> Array[DataLogEntry]:
	var filter_state := get_filter_state()
	var filtered_entries: Array[DataLogEntry] = []

	for entry in entries:
		if _entry_matches_filters(entry, filter_state):
			filtered_entries.append(entry)

	return filtered_entries

#endregion


#region PRIVATE FUNCTIONS

var _search_timer: SceneTreeTimer

## Returns array of active log levels
func _get_active_levels() -> Array[DataLogEntry.Level]:
	var levels: Array[DataLogEntry.Level] = []

	if %chk_Debug.button_pressed:
		levels.append(DataLogEntry.Level.DEBUG)
	if %chk_Info.button_pressed:
		levels.append(DataLogEntry.Level.INFO)
	if %chk_Warning.button_pressed:
		levels.append(DataLogEntry.Level.WARNING)
	if %chk_Error.button_pressed:
		levels.append(DataLogEntry.Level.ERROR)

	return levels

## Checks if an entry matches the current filters
func _entry_matches_filters(entry: DataLogEntry, filter_state: Dictionary) -> bool:
	# Check log level
	if not entry.level in filter_state.levels:
		return false

	# Check search text
	if not filter_state.search_text.is_empty():
		var search_text: String = filter_state.search_text.to_lower()
		var message_matches := entry.message.to_lower().contains(search_text)
		var source_matches := entry.source.to_lower().contains(search_text)

		if not (message_matches or source_matches):
			return false

	return true

## Emits the current filter state
func _emit_current_filter_state() -> void:
	filters_changed.emit(get_filter_state())

## Called when any level filter checkbox changes
func _on_filter_changed(_toggled: bool) -> void:
	_emit_current_filter_state()

## Called when search text changes
func _on_search_changed(_new_text: String) -> void:
	# Cancel previous timer if it exists
	if _search_timer and not _search_timer.is_queued_for_deletion():
		_search_timer.timeout.disconnect(_emit_current_filter_state)
		_search_timer.queue_free()

	# Start new timer
	_search_timer = get_tree().create_timer(SEARCH_DEBOUNCE_TIME)
	_search_timer.timeout.connect(_emit_current_filter_state)

#endregion
