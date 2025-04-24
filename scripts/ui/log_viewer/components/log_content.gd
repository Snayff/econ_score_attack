## Component for displaying log file content with virtual scrolling.
extends ScrollContainer

const DataLogEntry := preload("res://scripts/ui/log_viewer/components/data_log_entry.gd")
const LogEntryScene := preload("res://scenes/ui/log_viewer/components/log_entry.tscn")


#region SIGNALS

signal entries_updated(entries: Array[DataLogEntry])

#endregion


#region CONSTANTS

const BUFFER_SIZE := 5  # Number of extra entries to keep above and below visible area
const ENTRY_HEIGHT := 40  # Estimated height of each entry in pixels
const POOL_SIZE := 50  # Maximum number of entry nodes to keep in memory
const UPDATE_INTERVAL := 0.1  # Seconds between scroll position checks

#endregion


#region ON READY

var _entries: Array[DataLogEntry] = []
var _filtered_entries: Array[DataLogEntry] = []
var _current_filter_state: Dictionary = {}

# Virtual scrolling variables
var _entry_pool: Array[Node] = []
var _visible_entries: Dictionary = {}  # Dictionary[int, Node]
var _first_visible_index: int = 0
var _last_visible_index: int = 0
var _total_height: float = 0.0
var _update_timer: Timer

func _ready() -> void:
	assert(%ContentContainer != null, "ContentContainer node not found")

	# Initialize virtual scrolling
	_init_virtual_scroll()

	# Connect scroll signals
	get_v_scroll_bar().value_changed.connect(_on_scroll_changed)

	# Start update timer
	_update_timer = Timer.new()
	_update_timer.wait_time = UPDATE_INTERVAL
	_update_timer.timeout.connect(_check_scroll_position)
	add_child(_update_timer)
	_update_timer.start()

func _exit_tree() -> void:
	if _update_timer:
		_update_timer.stop()
		_update_timer.queue_free()

#endregion


#region EXPORTS


#endregion


#region PUBLIC FUNCTIONS

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

## Initializes the virtual scrolling system
func _init_virtual_scroll() -> void:
	# Create initial pool of entry nodes
	for i in POOL_SIZE:
		var entry_node: Control = LogEntryScene.instantiate()
		entry_node.hide()
		_entry_pool.append(entry_node)
		%ContentContainer.add_child(entry_node)

## Gets an entry node from the pool or creates a new one
func _get_entry_node() -> Control:
	for node in _entry_pool:
		if not node.visible:
			return node

	# If no nodes available in pool, create a new one
	var new_node: Control = LogEntryScene.instantiate()
	_entry_pool.append(new_node)
	%ContentContainer.add_child(new_node)
	return new_node

## Updates visible entries based on scroll position
func _update_visible_entries() -> void:
	if _filtered_entries.is_empty():
		return

	var scroll_pos := get_v_scroll_bar().value
	var visible_height := size.y

	# Calculate visible range
	var first_visible := int(scroll_pos / ENTRY_HEIGHT) - BUFFER_SIZE
	var last_visible := int((scroll_pos + visible_height) / ENTRY_HEIGHT) + BUFFER_SIZE

	# Ensure we don't go out of bounds
	first_visible = maxi(0, first_visible)
	last_visible = mini(last_visible, _filtered_entries.size() - 1)

	# Hide entries that are no longer visible
	for idx in _visible_entries.keys():
		if idx < first_visible or idx > last_visible:
			_visible_entries[idx].hide()
			_visible_entries.erase(idx)

	# Show entries that should be visible
	for idx in range(first_visible, last_visible + 1):
		if not _visible_entries.has(idx):
			var node := _get_entry_node()
			node.show()
			node.custom_minimum_size.y = ENTRY_HEIGHT
			node.set("layout_mode", 1)  # CONTAINER_LAYOUT_MODE_ANCHORS
			node.set("anchor_top", float(idx * ENTRY_HEIGHT) / _total_height)
			node.set("anchor_bottom", float((idx + 1) * ENTRY_HEIGHT) / _total_height)
			node.set("offset_top", 0)
			node.set("offset_bottom", ENTRY_HEIGHT)
			node.display_entry(_filtered_entries[idx])
			_visible_entries[idx] = node

## Handles scroll value changes
func _on_scroll_changed(_value: float) -> void:
	_check_scroll_position()

## Periodic check of scroll position
func _check_scroll_position() -> void:
	if not _filtered_entries.is_empty():
		_update_visible_entries()

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

	# Update total height and container size
	_total_height = _filtered_entries.size() * ENTRY_HEIGHT
	%ContentContainer.custom_minimum_size.y = _total_height

	# Reset visible entries
	for visible_entry in _visible_entries.values():
		visible_entry.hide()
	_visible_entries.clear()

	# Update visible entries
	_update_visible_entries()

	entries_updated.emit(_entries)

## Clears all content from the container
func _clear_content() -> void:
	for visible_entry in _visible_entries.values():
		visible_entry.hide()
	_visible_entries.clear()
	_entries.clear()
	_filtered_entries.clear()
	_total_height = 0.0
	%ContentContainer.custom_minimum_size.y = 0

## Applies current filters and updates display
func _apply_filters() -> void:
	if _current_filter_state.is_empty():
		_filtered_entries = _entries.duplicate()
	else:
		_filtered_entries.clear()
		for entry in _entries:
			if _entry_matches_filters(entry):
				_filtered_entries.append(entry)

	# Update total height and container size
	_total_height = _filtered_entries.size() * ENTRY_HEIGHT
	%ContentContainer.custom_minimum_size.y = _total_height

	# Reset visible entries
	for visible_entry in _visible_entries.values():
		visible_entry.hide()
	_visible_entries.clear()

	# Update visible entries
	_update_visible_entries()

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
