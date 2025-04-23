extends Control

## Main UI controller that handles switching between different content views
## based on sidebar button clicks.


#region EXPORTS


#endregion


#region CONSTANTS

const VIEWS = {
	"People": "RTLPeopleInfo",
	"Laws": "LawsInfo"
}

#endregion


#region SIGNALS


#endregion


#region ON READY

@onready var panel_header: VBoxContainer = %PanelHeader

func _ready() -> void:
	# Ensure we have our required nodes
	assert(panel_header != null, "PanelHeader node not found!")

	# Connect button signals
	for button_name in VIEWS.keys():
		var button = get_node_or_null("HBoxContainer/Sidebar/MarginContainer/VBoxContainer/btn_" + button_name.to_lower())
		if button:
			button.sidebar_button_pressed.connect(_on_sidebar_button_pressed)
		else:
			push_error("Button not found: " + button_name)

	# Show default view
	_show_view("People")


#endregion


#region PUBLIC FUNCTIONS


#endregion


#region PRIVATE FUNCTIONS

func _on_sidebar_button_pressed(button_text: String) -> void:
	_show_view(button_text)


func _show_view(view_name: String) -> void:
	if not VIEWS.has(view_name):
		push_error("Invalid view name: " + view_name)
		return

	var container = $"CentrePanel/MarginContainer/VBoxContainer/ScrollContainer"
	if not container:
		push_error("ScrollContainer not found!")
		return

	# Update header title
	panel_header.set_title(view_name)

	# Hide all views first
	for view in VIEWS.values():
		var node = container.get_node_or_null(view)
		if node:
			node.visible = false

	# Show and update the requested view
	var target_view = container.get_node_or_null(VIEWS[view_name])
	if target_view:
		target_view.visible = true
		if target_view.has_method("update_info"):
			target_view.update_info()
	else:
		push_error("View not found: " + VIEWS[view_name])


#endregion
