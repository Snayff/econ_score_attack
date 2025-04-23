## A viewer for log files that provides filtering and search capabilities.
## This is the main control node that coordinates all log viewer components.
extends Control


#region SIGNALS


#endregion


#region CONSTANTS

const LOG_DIRECTORY := "dev/logs/"

#endregion


#region ON READY

func _ready() -> void:
	assert(%FileSelector != null, "FileSelector node not found")
	assert(%LogContent != null, "LogContent node not found")

	%FileSelector.file_selected.connect(_on_file_selected)

#endregion


#region EXPORTS


#endregion


#region PUBLIC FUNCTIONS


#endregion


#region PRIVATE FUNCTIONS

func _on_file_selected(file_path: String) -> void:
	%LogContent.load_file(file_path)

#endregion
