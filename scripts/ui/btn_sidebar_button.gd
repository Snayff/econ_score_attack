extends Button

## A button used in the sidebar for navigation.
## Example:
## var button = btn_sidebar_button.new()
## button.text = "People"


#region EXPORTS

@export var button_text: String = "":
	set(value):
		button_text = value
		text = value

#endregion


#region CONSTANTS


#endregion


#region SIGNALS


#endregion


#region ON READY

func _ready() -> void:
	text = button_text
	custom_minimum_size = Vector2(120, 40)
	size_flags_horizontal = SIZE_EXPAND_FILL

#endregion


#region PUBLIC FUNCTIONS


#endregion


#region PRIVATE FUNCTIONS


#endregion 