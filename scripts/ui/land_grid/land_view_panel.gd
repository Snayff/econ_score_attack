"""
LandViewPanelUI

Main container for the Land View UI, holding the interaction, world view, and info panels.
Usage: Attach to LandViewPanel.tscn root node.
"""

class_name LandViewPanelUI
extends HSplitContainer

#region CONSTANTS
#endregion


#region SIGNALS
#endregion


#region ON READY
func _ready() -> void:
	# Get references to WorldViewPanel and TileInfoPanel
	var world_view_panel: WorldViewPanelUI = $MiddleRightSplit/WorldViewPanel
	var tile_info_panel: TileInfoPanelUI = $MiddleRightSplit/TileInfoPanel
	assert(world_view_panel != null)
	assert(tile_info_panel != null)
	# Connect signal
	world_view_panel.tile_selected.connect(_on_tile_selected)
	# Store for later use if needed
	self._world_view_panel = world_view_panel
	self._tile_info_panel = tile_info_panel
#endregion


#region EXPORTS
#endregion


#region PUBLIC FUNCTIONS
#endregion


#region PRIVATE FUNCTIONS
var _world_view_panel: WorldViewPanelUI
var _tile_info_panel: TileInfoPanelUI

func _on_tile_selected(tile_id: int) -> void:
	if _tile_info_panel:
		_tile_info_panel.update_tile_info(tile_id)
#endregion 