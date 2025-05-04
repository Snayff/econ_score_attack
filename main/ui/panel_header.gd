extends VBoxContainer

## A shared header component for panels that displays a title and separator.
## Used to maintain consistent styling across different panels.
##
## Example usage:
## var header = preload("res://scenes/ui/panel_header.tscn").instantiate()
## header.set_title("My Panel")

#region EXPORTS

@export var title: String = "":
	set(value):
		title = value
		if title_label:
			title_label.text = value

#endregion


#region CONSTANTS

#endregion


#region SIGNALS

#endregion


#region ON READY

@onready var title_label: Label = $TitleLabel
@onready var separator: HSeparator = $HSeparator

func _ready() -> void:
	# Ensure we have our required nodes
	assert(title_label != null, "TitleLabel node not found!")
	assert(separator != null, "HSeparator node not found!")

	if title:
		title_label.text = title

#endregion


#region PUBLIC FUNCTIONS

## Sets the title of the header
func set_title(new_title: String) -> void:
	title = new_title

## Gets the current header title
func get_title() -> String:
	return title_label.text

#endregion


#region PRIVATE FUNCTIONS


#endregion
