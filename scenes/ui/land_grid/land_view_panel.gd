"""
LandViewPanel

Main container for the Land View UI, holding the interaction, world view, and info panels.
Usage: Attach to LandViewPanel.tscn root node.
"""

class_name LandViewPanel
extends HSplitContainer

#region CONSTANTS
#endregion


#region SIGNALS
#endregion


#region ON READY
func _ready() -> void:
	# Get references to WorldViewPanel and TileInfoPanel
	var world_view_panel = $MiddleRightSplit/WorldViewPanel
	var tile_info_panel = $MiddleRightSplit/TileInfoPanel
	assert(world_view_panel != null)
	assert(tile_info_panel != null)
	# Connect signal (expects two arguments: tile_id, tile_data)
	world_view_panel.tile_selected.connect(_on_tile_selected)
	# Store for later use if needed
	self._world_view_panel = world_view_panel
	self._tile_info_panel = tile_info_panel
	EventBusGame.land_grid_updated.connect(_on_land_grid_updated)
#endregion


#region EXPORTS
#endregion


#region PUBLIC FUNCTIONS
## Sets the land grid and its dimensions, then passes to WorldViewPanel.
## @param land_grid: Array[Array[DataLandParcel]]
## @param width: int
## @param height: int
func set_land_grid(land_grid: Array, width: int, height: int) -> void:
	if _world_view_panel:
		_world_view_panel.set_land_grid(land_grid, width, height)
#endregion


#region PRIVATE FUNCTIONS
## Handles tile selection signal from WorldViewPanel.
## @param tile_id: int, the selected tile's id
## @param tile_data: DataLandParcel, the selected tile's data
func _on_tile_selected(tile_id: int, tile_data) -> void:
	if _tile_info_panel:
		_tile_info_panel.update_tile_info(tile_data)
	else:
		push_error("LandViewPanel: _tile_info_panel is null!")

func _on_land_grid_updated() -> void:
	if _world_view_panel:
		_world_view_panel._update_grid()

var _world_view_panel
var _tile_info_panel
#endregion
