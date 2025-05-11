## Abstract base class for standardised layout of all main views.
## Usage:
##  Create a new view scene. 1 for each specific view. (e.g. EconomyView, LawView)
##  Instance template_view.tscn as a child.
##  Inherit from this script in a new .gd file. Attach to the instanced template.
##
## See: dev/docs/docs/systems/ui_view_layout.md
## Last Updated: 2024-06-09
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
@export var show_right_sidebar: bool = true
@export var show_debug_backgrounds: bool = false
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
	# Toggle debug backgrounds
	left_sidebar_bg.visible = show_debug_backgrounds
	top_bar_bg.visible = show_debug_backgrounds
	centre_panel_bg.visible = show_debug_backgrounds
	right_sidebar_bg.visible = show_debug_backgrounds
#endregion
