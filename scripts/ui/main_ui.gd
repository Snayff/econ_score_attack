extends Control

## Main UI controller that handles switching between different content views
## based on sidebar button clicks.


#region EXPORTS


#endregion


#region CONSTANTS


#endregion


#region SIGNALS


#endregion


#region ON READY

func _ready() -> void:
	# Get references to UI elements
	var btn_people: Button = %btn_people
	var btn_laws: Button = %btn_laws

	# Connect button signals
	btn_people.sidebar_button_pressed.connect(_on_sidebar_button_pressed)
	btn_laws.sidebar_button_pressed.connect(_on_sidebar_button_pressed)

	# Show people info by default
	_show_people_info()


#endregion


#region PUBLIC FUNCTIONS


#endregion


#region PRIVATE FUNCTIONS

func _on_sidebar_button_pressed(button_text: String) -> void:
	match button_text:
		"People":
			_show_people_info()
		"Laws":
			_show_laws_info()

func _show_people_info() -> void:
	# Hide laws info if it exists
	var existing_laws = $CentrePanel/ScrollContainer.get_node_or_null("RTLLawsInfo")
	if existing_laws:
		existing_laws.queue_free()

	# Show people info
	var people_info = $CentrePanel/ScrollContainer/RTLPeopleInfo
	people_info.visible = true
	people_info.update_info()

func _show_laws_info() -> void:
	# Hide people info
	var people_info = $CentrePanel/ScrollContainer/RTLPeopleInfo
	people_info.visible = false

	# Show laws info
	var existing_laws = $CentrePanel/ScrollContainer.get_node_or_null("RTLLawsInfo")
	if not existing_laws:
		var laws_info = preload("res://scripts/ui/rtl_laws_info.gd").new()
		laws_info.name = "RTLLawsInfo"
		laws_info.custom_minimum_size = Vector2(580, 0)
		laws_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		$CentrePanel/ScrollContainer.add_child(laws_info)


#endregion
