## Component for displaying log file content.
extends ScrollContainer


#region SIGNALS


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

## Loads and displays the content of a log file
func load_file(file_path: String) -> void:
	%ContentContainer.text = ""

	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open log file: ", file_path)
		%ContentContainer.text = "Error: Failed to open log file"
		return

	%ContentContainer.text = file.get_as_text()

#endregion


#region PRIVATE FUNCTIONS


#endregion
