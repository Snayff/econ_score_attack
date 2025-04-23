## Component for selecting log files from the logs directory.
extends HBoxContainer


#region SIGNALS

## Emitted when a log file is selected
signal file_selected(file_path: String)

#endregion


#region CONSTANTS

const LOG_DIRECTORY := "dev/logs/"

#endregion


#region ON READY

func _ready() -> void:
	assert(%OptFiles != null, "OptFiles node not found")
	assert(%BtnRefresh != null, "BtnRefresh node not found")
	
	%BtnRefresh.pressed.connect(_on_refresh_pressed)
	%OptFiles.item_selected.connect(_on_file_selected)
	
	_populate_file_list()

#endregion


#region EXPORTS


#endregion


#region PUBLIC FUNCTIONS

## Refreshes the list of available log files
func refresh_file_list() -> void:
	_populate_file_list()

#endregion


#region PRIVATE FUNCTIONS

## Populates the file list dropdown with available log files
func _populate_file_list() -> void:
	%OptFiles.clear()
	
	var dir := DirAccess.open(LOG_DIRECTORY)
	if not dir:
		push_error("Failed to access log directory: ", LOG_DIRECTORY)
		return
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".log"):
			%OptFiles.add_item(file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	# Select first file if available
	if %OptFiles.item_count > 0:
		%OptFiles.select(0)
		_on_file_selected(0)


func _on_refresh_pressed() -> void:
	refresh_file_list()


func _on_file_selected(index: int) -> void:
	if index >= 0:
		var file_name: String = %OptFiles.get_item_text(index)
		file_selected.emit(LOG_DIRECTORY.path_join(file_name))

#endregion 