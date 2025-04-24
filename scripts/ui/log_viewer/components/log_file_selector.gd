## Component for selecting log files from the logs directory.
extends HBoxContainer


#region SIGNALS

## Emitted when a log file is selected
signal file_selected(file_path: String)

## Emitted when auto-refresh state changes
signal auto_refresh_toggled(enabled: bool)

#endregion


#region CONSTANTS

const LOG_DIRECTORY := "dev/logs/"

#endregion


#region ON READY

func _ready() -> void:
	assert(%OptFiles != null, "OptFiles node not found")
	assert(%BtnRefresh != null, "BtnRefresh node not found")
	assert(%chk_AutoRefresh != null, "Auto-refresh checkbox not found")
	
	%BtnRefresh.pressed.connect(_on_refresh_pressed)
	%OptFiles.item_selected.connect(_on_file_selected)
	%chk_AutoRefresh.toggled.connect(_on_auto_refresh_toggled)
	
	_populate_file_list()

#endregion


#region EXPORTS


#endregion


#region PUBLIC FUNCTIONS

## Refreshes the list of available log files
func refresh_file_list() -> void:
	if not %chk_AutoRefresh.button_pressed:
		return
		
	var current_file: String = ""
	if %OptFiles.selected >= 0:
		current_file = %OptFiles.get_item_text(%OptFiles.selected)
	
	_populate_file_list()
	
	# Try to reselect the previously selected file
	if not current_file.is_empty():
		for i in %OptFiles.item_count:
			if %OptFiles.get_item_text(i) == current_file:
				%OptFiles.select(i)
				return
	
	# If the file wasn't found or no file was selected, select the first one
	if %OptFiles.item_count > 0:
		%OptFiles.select(0)
		_on_file_selected(0)

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


func _on_auto_refresh_toggled(enabled: bool) -> void:
	auto_refresh_toggled.emit(enabled)

#endregion 