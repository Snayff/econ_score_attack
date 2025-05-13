## Abstract base class for standardised layout of all main views.
## Usage:
##  Create a new view scene. 1 for each specific view. (e.g. EconomyView, LawView)
##  Instance template_view.tscn as a child.
##  Inherit from this script in a new .gd file. Attach to the instanced template.
##
## See: dev/docs/docs/systems/ui_view_layout.md
## Last Updated: 2025-05-13
##
class_name ABCView
extends Control

#region CONSTANTS
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
@export var sidebar_width: int = 120:
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
## @param content (Control): The control node to display in the centre panel.
func set_centre_content(content: Control) -> void:
	centre_panel.clear_children()
	centre_panel.add_child(content)

## Shows or hides the right sidebar.
## @param visible (bool): Whether the right sidebar should be visible.
func set_right_sidebar_visible(visible: bool) -> void:
	right_sidebar.visible = visible
#endregion

#region PRIVATE FUNCTIONS
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

func _update_sidebar_widths() -> void:
	if left_sidebar:
		left_sidebar.custom_minimum_size.x = sidebar_width
	if right_sidebar:
		right_sidebar.custom_minimum_size.x = sidebar_width

## Update the visibility of the debug backgrounds to align to show_debug_backgrounds
func _update_bg_visibility():
	if left_sidebar_bg:
		left_sidebar_bg.visible = show_debug_backgrounds
	if top_bar_bg:
		top_bar_bg.visible = show_debug_backgrounds
	if centre_panel_bg:
		centre_panel_bg.visible = show_debug_backgrounds
	if right_sidebar_bg:
		right_sidebar_bg.visible = show_debug_backgrounds
#endregion
