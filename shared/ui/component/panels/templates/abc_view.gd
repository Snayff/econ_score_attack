## Abstract base class for standardised layout of all main views.
## Usage:
##  Inherit from this script in a new view scene (e.g. EconomyView, LawView).
##  Use the provided region setters (set_left_sidebar_content, set_top_bar_content, set_right_sidebar_content, set_centre_content) to populate UI regions with a Control or an array of Controls.
##  Implement update_view() in your subclass to populate all regions. Call refresh() to update the view; this will clear all regions, call update_view(), and automatically show a standard message in any empty region.
##  All user actions in sidebars and top bar should emit the standard signals (left_action_selected, top_tab_selected, right_info_requested) where appropriate.
##  Error and empty state handling is managed by the base class.
##  For all standard UI elements (headers, buttons, sidebar containers), use UIFactory (see global/ui_factory.gd).
##
## See: dev/docs/docs/systems/ui.md
## Last Updated: 2025-05-13
##
class_name ABCView
extends Control

#region CONSTANTS
var _DEFAULT_SIDEBAR_WIDTH: int = 180
#endregion

#region SIGNALS
## Emitted when a left sidebar action is selected.
signal left_action_selected(action: String)
## Emitted when a top bar tab is selected.
signal top_tab_selected(tab: String)
## Emitted when right sidebar info is requested.
signal right_info_requested(info_id: int)
#endregion

#region ON READY
@onready var left_sidebar: VBoxContainer = %LeftSidebar
@onready var left_sidebar_bg: ColorRect = %BGLeftSidebarDebug
@onready var top_bar: HBoxContainer = %TopBar
@onready var top_bar_bg: ColorRect = %BGTopBarDebug
@onready var right_sidebar: VBoxContainer = %RightSidebar
@onready var right_sidebar_bg: ColorRect = %BGRightSidebarDebug
@onready var centre_panel: PanelContainer = %CentrePanel
@onready var centre_panel_bg: ColorRect = %BGCentrePanelDebug
#endregion

#region EXPORTS
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

#region PUBLIC FUNCTIONS
## Sets the main content of the centre panel.
## @param content (Array[Control]): The array of Controls to display in the centre panel.
## @return void
func set_centre_content(content: Array[Control]) -> void:
	_clear_all_children(centre_panel)
	for c in content:
		centre_panel.add_child(c)

## Sets the content of the left sidebar.
## @param content (Array[Control]): The array of Controls to display in the left sidebar.
## @return void
func set_left_sidebar_content(content: Array[Control]) -> void:
	_clear_all_children(left_sidebar)
	for c in content:
		left_sidebar.add_child(c)

## Sets the content of the top bar.
## @param content (Array[Control]): The array of Controls to display in the top bar.
## @return void
func set_top_bar_content(content: Array[Control]) -> void:
	_clear_all_children(top_bar)
	for c in content:
		top_bar.add_child(c)

## Sets the content of the right sidebar.
## @param content (Array[Control]): The array of Controls to display in the right sidebar.
## @return void
func set_right_sidebar_content(content: Array[Control]) -> void:
	_clear_all_children(right_sidebar)
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
	_clear_sidebars()
	_clear_top_bar()
	_clear_all_children(centre_panel)
	update_view()
	_check_and_show_empty_states()

## Abstract method to be implemented by subclasses. Should populate all regions.
## @virtual
## @return void
func update_view() -> void:
	pass
#endregion

#region PRIVATE FUNCTIONS
## Called when the node is added to the scene tree. Asserts all required nodes exist and sets up initial state.
## @return void
func _ready() -> void:
	assert(left_sidebar != null)
	assert(top_bar != null)
	assert(right_sidebar != null)
	assert(centre_panel != null)
	assert(left_sidebar_bg != null)
	assert(top_bar_bg != null)
	assert(centre_panel_bg != null)
	assert(right_sidebar_bg != null)
	right_sidebar.visible = show_right_sidebar
	_update_sidebar_widths()

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
	if top_bar_bg:
		top_bar_bg.visible = show_debug_backgrounds
	if centre_panel_bg:
		centre_panel_bg.visible = show_debug_backgrounds
	if right_sidebar_bg:
		right_sidebar_bg.visible = show_debug_backgrounds

## Shows a standard empty message in the specified region if it is empty.
## @param region (String): "left", "right", "top", or "centre".
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
		"top":
			top_bar.add_child(label)
		"centre":
			centre_panel.add_child(label)

## Checks each region and shows an empty message if it is empty.
## @return void
func _check_and_show_empty_states() -> void:
	if left_sidebar.get_child_count() == 0:
		_show_empty_message("left")
	if right_sidebar.visible and right_sidebar.get_child_count() == 0:
		_show_empty_message("right")
	if top_bar.get_child_count() == 0:
		_show_empty_message("top")
	if centre_panel.get_child_count() == 0:
		_show_empty_message("centre")

## Removes and frees all children from the given container.
## @param container (Node): The container whose children will be removed and freed.
## @return void
func _clear_all_children(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

## Clears all sidebars (left and right).
## @return void
func _clear_sidebars() -> void:
	_clear_all_children(left_sidebar)
	_clear_all_children(right_sidebar)

## Clears the top bar.
## @return void
func _clear_top_bar() -> void:
	_clear_all_children(top_bar)
#endregion
