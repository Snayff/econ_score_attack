"""
TileInfoPanelUI

Panel for displaying information about the selected tile.
Usage: Attach to TileInfoPanel.tscn root node.
"""

class_name TileInfoPanelUI
extends PanelContainer

#region CONSTANTS
#endregion


#region SIGNALS
#endregion


#region ON READY
#endregion


#region EXPORTS
#endregion


#region PUBLIC FUNCTIONS
## Updates the info panel to show information for the selected tile.
## @param tile_id: int
func update_tile_info(tile_id: int) -> void:
	# For now, just display the tile ID as a placeholder
	if has_node("Label"):
		$Label.text = "Tile ID: %d" % tile_id
	else:
		var lbl = Label.new()
		lbl.f_name = "Label"
		lbl.text = "Tile ID: %d" % tile_id
		add_child(lbl)
#endregion


#region PRIVATE FUNCTIONS
#endregion 