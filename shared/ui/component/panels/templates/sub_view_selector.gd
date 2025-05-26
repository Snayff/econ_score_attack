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
var _active_sub_view_id: String = ""
#endregion

#region PUBLIC FUNCTIONS
#endregion

#region PRIVATE FUNCTIONS
func _ready() -> void:
	assert(_view_name != "", "view name must be set in the editor for SubViewSelector to work.")

	_load_sub_views()

func _load_sub_views() -> void:
	# Clear previous buttons and sub view nodes
	for child in top_bar.get_children():
		top_bar.remove_child(child)
		child.queue_free()
	for child in sub_view_container.get_children():
		sub_view_container.remove_child(child)
		child.queue_free()
	_sub_views = Library.get_all_sub_views_data(_view_name)
	_sub_view_nodes.clear()
	if _sub_views.is_empty():
		return
	# Instance all sub view scenes, but only show the active one
	for sub_view in _sub_views:
		var scene = load(sub_view.scene_path)
		if not scene:
			push_error("Failed to load sub view scene: %s" % sub_view.scene_path)
			continue
		var node = scene.instantiate()
		node.visible = false
		sub_view_container.add_child(node)
		_sub_view_nodes[sub_view.id] = node
	# Create buttons in the top bar
	for sub_view in _sub_views:
		var btn = UIFactory.create_button(sub_view.label)
		btn.icon = load(sub_view.icon)
		btn.tooltip_text = sub_view.tooltip
		btn.pressed.connect(_on_sub_view_button_pressed.bind(sub_view.id))
		top_bar.add_child(btn)
	# Show the first sub view by default, or last selected if available
	var default_id = _active_sub_view_id if _active_sub_view_id in _sub_view_nodes else _sub_views[0].id
	_set_active_sub_view(default_id)

func _on_sub_view_button_pressed(sub_view_id: String) -> void:
	_set_active_sub_view(sub_view_id)

func _set_active_sub_view(sub_view_id: String) -> void:
	for id in _sub_view_nodes.keys():
		_sub_view_nodes[id].visible = (id == sub_view_id)
	_active_sub_view_id = sub_view_id
	emit_signal("sub_view_changed", sub_view_id)
#endregion
