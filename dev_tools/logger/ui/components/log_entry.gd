## A UI component for displaying a single log entry.
extends PanelContainer

const DataLogEntry := preload("res://dev_tools/logger/ui/components/data_log_entry.gd")


#region SIGNALS

## Emitted when the entry is selected
signal entry_selected(entry: DataLogEntry)

## Emitted when the entry should be copied
signal copy_requested(entry: DataLogEntry)

#endregion


#region CONSTANTS

enum ContextMenuItems {
	COPY = 1
}

#endregion


#region ON READY

var _context_menu: PopupMenu
var _current_entry: DataLogEntry

func _ready() -> void:
	assert(%Timestamp != null, "Timestamp label not found")
	assert(%Level != null, "Level label not found")
	assert(%Source != null, "Source label not found")
	assert(%Message != null, "Message label not found")

	# Setup context menu
	_context_menu = PopupMenu.new()
	add_child(_context_menu)
	_context_menu.add_item("Copy Entry", ContextMenuItems.COPY)
	_context_menu.id_pressed.connect(_on_context_menu_selected)

	# Setup mouse interaction
	gui_input.connect(_on_gui_input)

#endregion


#region EXPORTS


#endregion


#region PUBLIC FUNCTIONS

## Updates the entry display with data from a LogEntry
func display_entry(entry: DataLogEntry) -> void:
	_current_entry = entry
	%Timestamp.text = entry.timestamp
	%Level.text = DataLogEntry.Level.keys()[entry.level]
	%Source.text = entry.source
	%Message.text = entry.message
	
	# Set colours based on log level
	%Level.modulate = entry.get_colour()
	%Message.modulate = entry.get_colour()

#endregion


#region PRIVATE FUNCTIONS

## Handles GUI input events
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_RIGHT and mouse_event.pressed:
			_context_menu.position = get_screen_transform() * event.position
			_context_menu.popup()
		elif mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			entry_selected.emit(_current_entry)

## Handles context menu selection
func _on_context_menu_selected(id: int) -> void:
	match id:
		ContextMenuItems.COPY:
			if _current_entry:
				copy_requested.emit(_current_entry)

#endregion 