##
## ABCView: Abstract base class for standardised layout of all main views.
## Usage: Extend this scene for each specific view (e.g., EconomyView, LawView).
## See: dev/docs/docs/systems/ui_view_layout.md
## Last Updated: 2025-05-11
##
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
@onready var top_bar: HBoxContainer = %TopBar
@onready var right_sidebar: VBoxContainer = %RightSidebar
@onready var centre_panel: PanelContainer = %CentrePanel
#endregion

#region EXPORTS
@export var show_right_sidebar: bool = true
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
    right_sidebar.visible = show_right_sidebar
#endregion 