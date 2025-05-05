## Component for managing log filtering options.
extends PanelContainer

const DataLogEntry := preload("res://dev_tool/logger/ui/components/data_log_entry.gd")


#region SIGNALS

## Emitted when filter settings change
signal filters_changed(filter_state: Dictionary)

#endregion


#region CONSTANTS

const SEARCH_DEBOUNCE_TIME := 0.3  # Seconds to wait before applying search filter
const TIMESTAMP_FORMAT := "YYYY-MM-DD HH:MM:SS"

#endregion


#region ON READY

var _search_timer: SceneTreeTimer
var _source_timer: SceneTreeTimer
var _timestamp_timer: SceneTreeTimer

func _ready() -> void:
	assert(%chk_Debug != null, "Debug checkbox not found")
	assert(%chk_Info != null, "Info checkbox not found")
	assert(%chk_Warning != null, "Warning checkbox not found")
	assert(%chk_Error != null, "Error checkbox not found")
	assert(%txt_Search != null, "Search textbox not found")
	assert(%txt_Source != null, "Source filter not found")
	assert(%txt_TimestampFrom != null, "Timestamp from filter not found")
	assert(%txt_TimestampTo != null, "Timestamp to filter not found")

	# Connect signals
	%chk_Debug.toggled.connect(_on_filter_changed)
	%chk_Info.toggled.connect(_on_filter_changed)
	%chk_Warning.toggled.connect(_on_filter_changed)
	%chk_Error.toggled.connect(_on_filter_changed)
	%txt_Search.text_changed.connect(_on_search_changed)
	%txt_Source.text_changed.connect(_on_source_changed)
	%txt_TimestampFrom.text_changed.connect(_on_timestamp_changed)
	%txt_TimestampTo.text_changed.connect(_on_timestamp_changed)

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
		"search_text": %txt_Search.text,
		"source_filter": %txt_Source.text,
		"timestamp_from": _parse_timestamp(%txt_TimestampFrom.text),
		"timestamp_to": _parse_timestamp(%txt_TimestampTo.text)
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

	# Check source filter
	if not filter_state.source_filter.is_empty():
		var source_filter: String = filter_state.source_filter.to_lower()
		if not entry.source.to_lower().contains(source_filter):
			return false

	# Check timestamp range
	var entry_timestamp := _parse_timestamp(entry.timestamp)
	if entry_timestamp != null:
		if filter_state.timestamp_from != null and entry_timestamp < filter_state.timestamp_from:
			return false
		if filter_state.timestamp_to != null and entry_timestamp > filter_state.timestamp_to:
			return false

	return true

## Parses a timestamp string into a dictionary
func _parse_timestamp(timestamp: String) -> Dictionary:
	if timestamp.is_empty():
		return {}

	var regex := RegEx.new()
	regex.compile("^(\\d{4})-(\\d{2})-(\\d{2}) (\\d{2}):(\\d{2}):(\\d{2})$")
	var result := regex.search(timestamp)

	if result:
		return {
			"year": result.get_string(1).to_int(),
			"month": result.get_string(2).to_int(),
			"day": result.get_string(3).to_int(),
			"hour": result.get_string(4).to_int(),
			"minute": result.get_string(5).to_int(),
			"second": result.get_string(6).to_int()
		}

	return {}

## Emits the current filter state
func _emit_current_filter_state() -> void:
	filters_changed.emit(get_filter_state())

## Called when any level filter checkbox changes
func _on_filter_changed(_toggled: bool) -> void:
	_emit_current_filter_state()

## Called when search text changes
func _on_search_changed(_new_text: String) -> void:
	_debounce_filter_change(_search_timer)

## Called when source filter changes
func _on_source_changed(_new_text: String) -> void:
	_debounce_filter_change(_source_timer)

## Called when timestamp filters change
func _on_timestamp_changed(_new_text: String) -> void:
	_debounce_filter_change(_timestamp_timer)

## Debounces filter changes
func _debounce_filter_change(timer: SceneTreeTimer) -> void:
	# If there's an existing timer and it hasn't triggered yet, disconnect it
	if timer and not timer.is_queued_for_deletion():
		if timer.timeout.is_connected(_emit_current_filter_state):
			timer.timeout.disconnect(_emit_current_filter_state)

	# Start new timer
	timer = get_tree().create_timer(SEARCH_DEBOUNCE_TIME)
	timer.timeout.connect(_emit_current_filter_state)

#endregion 