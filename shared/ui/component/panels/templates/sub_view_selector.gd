## SubViewSelector: Manages sub view selection and switching for a main view.
## Usage:
##   Listens for button presses in the top bar to switch sub views.
##   Emits sub_view_changed(sub_view_id: String) when the active sub view changes.
## Last Updated: 2025-05-24
extends VBoxContainer

#region SIGNALS
signal sub_view_changed(sub_view_id: String)
#endregion

#region ON READY
@onready var top_bar: HBoxContainer = %View_TopBar
@onready var sub_view_container: Control = %View_SubViewContainer
#endregion

#region VARS
## the name of the view. To be set in the editor when  creating a new View.
## this determines what sub views to load.
@export var _view_name: String = ""
var _sub_views: Array = []
var _sub_view_nodes: Dictionary = {}
var _active_sub_view_key: int = -1
#endregion

#region PUBLIC FUNCTIONS
#endregion

#region PRIVATE FUNCTIONS
func _ready() -> void:
	assert(_view_name != "", "view name must be set in the editor for SubViewSelector to work.")

	_load_sub_views()

func _load_sub_views() -> void:
	# Clear previous buttons
	for child in top_bar.get_children():
		top_bar.remove_child(child)
		child.queue_free()
	_sub_views = Library.get_all_sub_views_data(_view_name)
	_sub_view_nodes.clear()
	if _sub_views.is_empty():
		return
	# Map sub view keys to existing children in sub_view_container
	for sub_view in _sub_views:
		var node = null
		for child in sub_view_container.get_children():
			if "sub_view_key" in child:
				if child.sub_view_key == sub_view.sub_view_key:
					node = child
					break
		if node:
			_sub_view_nodes[sub_view.sub_view_key] = node
		else:
			push_error("Sub view node not found for sub_view_key: %s" % Constants.SUB_VIEW_ENUM_TO_KEY[sub_view.sub_view_key])
	# Create buttons in the top bar
	for sub_view in _sub_views:
		var btn = UIFactory.create_button(sub_view.label)
		btn.icon = load(sub_view.icon)
		btn.tooltip_text = sub_view.tooltip
		btn.pressed.connect(_on_sub_view_button_pressed.bind(sub_view.sub_view_key))
		top_bar.add_child(btn)
	# Show the first sub view by default, or last selected if available
	var default_key = _active_sub_view_key if _active_sub_view_key in _sub_view_nodes else _sub_views[0].sub_view_key
	_set_active_sub_view(default_key)

func _on_sub_view_button_pressed(sub_view_key: int) -> void:
	_set_active_sub_view(sub_view_key)

func _set_active_sub_view(sub_view_key: int) -> void:
	for key in _sub_view_nodes.keys():
		_sub_view_nodes[key].visible = (key == sub_view_key)
	_active_sub_view_key = sub_view_key
	emit_signal("sub_view_changed", sub_view_key)
#endregion
