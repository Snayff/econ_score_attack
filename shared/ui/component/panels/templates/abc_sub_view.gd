## Abstract base class for standardised layout of all sub views.
## Usage:
##  Inherit from this script in a new sub view scene (e.g. SubViewPopulation, SubViewDecisions).
##  Use the provided region setters (set_left_sidebar_content, set_right_sidebar_content, set_centre_content) to populate UI regions with a Control or an array of Controls.
##  Implement update_view() in your subclass to populate all regions. Call refresh() to update the view; this will clear all regions, call update_view(), and automatically show a standard message in any empty region.
##  All user actions in sidebars should emit the standard signals (left_action_selected, right_info_requested) where appropriate.
##  Error and empty state handling is managed by the base class.
##  For all standard UI elements (headers, buttons, sidebar containers), use UIFactory (see global/ui_factory.gd).
##
## See: dev/docs/designs/sub_view_system_design.md
## Last Updated: 2025-05-24
class_name ABCSubView
extends Control

#region CONSTANTS
var _DEFAULT_SIDEBAR_WIDTH: int = 180
#endregion

#region SIGNALS
## Emitted when a left sidebar action is selected.
signal left_action_selected(action: String)
## Emitted when right sidebar info is requested.
signal right_info_requested(info_id: int)
#endregion

#region ON READY
@onready var left_sidebar: VBoxContainer = %TemplateSubView/%LeftSidebar
@onready var left_sidebar_bg: ColorRect = %TemplateSubView/%BGLeftSidebarDebug
@onready var right_sidebar: VBoxContainer = %TemplateSubView/%RightSidebar
@onready var right_sidebar_bg: ColorRect = %TemplateSubView/%BGRightSidebarDebug
@onready var centre_panel: PanelContainer = %TemplateSubView/%CentrePanel
@onready var centre_panel_bg: ColorRect = %TemplateSubView/%BGCentrePanelDebug
#endregion

#region EXPORTS
@export var sub_view_key: Constants.SUB_VIEW_KEY
@export var sidebar_width: int = _DEFAULT_SIDEBAR_WIDTH:
	set(value):
		sidebar_width = value
		if not is_node_ready():
			return
		_update_sidebar_widths()

@export var show_right_sidebar: bool = true:
	set(value):
		show_right_sidebar = value
		if not is_node_ready():
			return
		set_right_sidebar_visible(value)

@export var show_debug_backgrounds: bool = false:
	set(v):
		show_debug_backgrounds = v

		if not is_node_ready():
			return

		_update_bg_visibility()
#endregion

#region VARS
## simulation node, where most data will reside
var _sim: Sim
## nodes to be deleted when `_free_to_clear_list` is called. used during refresh.
var to_clear_list: Array = []
#endregion

#region PUBLIC FUNCTIONS
## Sets the main content of the centre panel.
## @param content (Array[Control]): The array of Controls to display in the centre panel.
## @return void
func set_centre_content(content: Array[Control]) -> void:
	for c in content:
		centre_panel.add_child(c)

## Sets the content of the left sidebar.
## @param content (Array[Control]): The array of Controls to display in the left sidebar.
## @return void
func set_left_sidebar_content(content: Array[Control]) -> void:
	for c in content:
		left_sidebar.add_child(c)

## Sets the content of the right sidebar.
## @param content (Array[Control]): The array of Controls to display in the right sidebar.
## @return void
func set_right_sidebar_content(content: Array[Control]) -> void:
	for c in content:
		right_sidebar.add_child(c)

## Shows or hides the right sidebar.
## @param visible (bool): Whether the right sidebar should be visible.
## @return void
func set_right_sidebar_visible(visible_: bool) -> void:
	right_sidebar.visible = visible_

## Standard refresh pattern: clears all regions, calls update_view, then fills empty regions with a default message.
## @return void
func refresh() -> void:
	_free_to_clear_list()
	update_view()
	_check_and_show_empty_states()

## Abstract method to be implemented by subclasses. Should populate all regions.
## @virtual
## @return void
func update_view() -> void:
	# ensure correct sizing
	offset_top = 0
	offset_bottom = 0
	offset_left = 0
	offset_right = 0

	_create_debug_backgrounds()
#endregion

#region PRIVATE FUNCTIONS
## Asserts all required nodes exist and sets up initial state.
## @return void
func _ready() -> void:
	assert(left_sidebar != null)
	assert(right_sidebar != null)
	assert(centre_panel != null)
	assert(left_sidebar_bg != null)
	assert(centre_panel_bg != null)
	assert(right_sidebar_bg != null)
	right_sidebar.visible = show_right_sidebar
	_update_sidebar_widths()

	ReferenceRegistry.reference_registered.connect(_on_reference_registered)
	if EventBusGame.has_signal("turn_complete"):
		EventBusGame.turn_complete.connect(_on_turn_complete)

	# Attempt to get sim if already registered
	var sim_ref = ReferenceRegistry.get_reference(Constants.REFERENCE_KEY.SIM)
	if sim_ref:
		_set_sim(sim_ref)

	# N.B. Do not call update_view immediately; wait for sim_initialised or turn_complete

func _on_turn_complete() -> void:
	refresh()

## Handles updates from the ReferenceRegistry.
## @param key (int): The reference key.
## @param value (Object): The reference value.
## @return void
func _on_reference_registered(key: int, value: Object) -> void:
	if key == Constants.REFERENCE_KEY.SIM:
		_set_sim(value)

## Sets the sim reference and updates info.
## @param sim_ref (Sim): The simulation reference.
## @return void
func _set_sim(sim_ref: Sim) -> void:
	_sim = sim_ref
	refresh()

## Updates the minimum width of the sidebars to match the sidebar_width property.
## @return void
func _update_sidebar_widths() -> void:
	if left_sidebar:
		left_sidebar.custom_minimum_size.x = sidebar_width
	if right_sidebar:
		right_sidebar.custom_minimum_size.x = sidebar_width

## Updates the visibility of the debug backgrounds to match show_debug_backgrounds.
## @return void
func _update_bg_visibility() -> void:
	if left_sidebar_bg:
		left_sidebar_bg.visible = show_debug_backgrounds
	if centre_panel_bg:
		centre_panel_bg.visible = show_debug_backgrounds
	if right_sidebar_bg:
		right_sidebar_bg.visible = show_debug_backgrounds

## Ensures debug background ColorRects exist in each region. If missing, recreates them with correct name, colour, and sizing.
## @return void
func _create_debug_backgrounds() -> void:
	# Left Sidebar
	if left_sidebar and not left_sidebar.has_node("BGLeftSidebarDebug"):
		var bg = ColorRect.new()
		bg.name = "BGLeftSidebarDebug"
		bg.color = Color(0.6, 0.7, 1, 0.5)
		bg.size_flags_vertical = Control.SIZE_EXPAND_FILL
		left_sidebar_bg = bg
		left_sidebar.add_child(bg, true)
	# Centre Panel
	if centre_panel and not centre_panel.has_node("BGCentrePanelDebug"):
		var bg = ColorRect.new()
		bg.name = "BGCentrePanelDebug"
		bg.color = Color(1, 1, 1, 0.5)
		centre_panel_bg = bg
		centre_panel.add_child(bg, true)
	# Right Sidebar
	if right_sidebar and not right_sidebar.has_node("BGRightSidebarDebug"):
		var bg = ColorRect.new()
		bg.name = "BGRightSidebarDebug"
		bg.color = Color(0.8, 0.8, 0.8, 0.5)
		bg.size_flags_vertical = Control.SIZE_EXPAND_FILL
		right_sidebar_bg = bg
		right_sidebar.add_child(bg, true)

## Shows a standard empty message in the specified region if it is empty.
## @param region (String): "left", "right", or "centre".
## @return void
func _show_empty_message(region: String) -> void:
	var label := Label.new()
	label.text = "No information available."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	match region:
		"left":
			left_sidebar.add_child(label)
		"right":
			right_sidebar.add_child(label)
		"centre":
			centre_panel.add_child(label)

## Checks each region and shows an empty message if it is empty.
## @return void
func _check_and_show_empty_states() -> void:
	# FIXME: this will never work as child count will always be at leats 1 due to debug backgrounds
	if left_sidebar.get_child_count() == 0:
		_show_empty_message("left")
	if right_sidebar.visible and right_sidebar.get_child_count() == 0:
		_show_empty_message("right")
	if centre_panel.get_child_count() == 0:
		_show_empty_message("centre")

## frees all items in `to_clear_list`.
func _free_to_clear_list() -> void:
	for node in to_clear_list:
		node.queue_free()
	to_clear_list.clear()

## add node to the list of items to be cleared when `_free_to_clear_list` is called.
func _add_to_clear_list(node: Node) -> void:
	to_clear_list.append(node)

#endregion
