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
## @param tile_data: DataLandParcel
func update_tile_info(tile_data) -> void:
	var info = []
	if not tile_data.is_surveyed:
		info.append("Parcel not surveyed")
	else:
		info.append("Terrain: %s" % tile_data.terrain_type)
		info.append("Building: %s" % (tile_data.building_id if tile_data.building_id != "" else "No building"))
		var discovered_resources = []
		for resource_id in tile_data.resources.keys():
			var res = tile_data.resources[resource_id]
			if res.discovered:
				discovered_resources.append("%s: %.1f" % [resource_id, res.amount])
		if discovered_resources.size() > 0:
			info.append("Resources: " + ", ".join(discovered_resources))
		else:
			info.append("No discovered resources")
	$VBoxContainer/lbl_info.text = "\n".join(info)
#endregion


#region PRIVATE FUNCTIONS
#endregion
