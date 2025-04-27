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
## @param tile_data: DataLandParcel or null
## @null If tile_data is null, shows 'No tile selected'.
func update_tile_info(tile_data) -> void:
	var info: Array[String] = []
	if tile_data == null:
		info.append("No tile selected")
	elif not tile_data.is_surveyed:
		info.append("Parcel not surveyed")
	else:
		info.append("Terrain: %s" % tile_data.terrain_type)
		info.append("Building: %s" % (tile_data.building_id if tile_data.building_id != "" else "No building"))
		var discovered_resources: Array[String] = []
		for resource_id in tile_data.resources.keys():
			var res = tile_data.resources[resource_id]
			if res.discovered:
				discovered_resources.append("%s: %.1f" % [resource_id, res.amount])
		if discovered_resources.size() > 0:
			info.append("Resources: " + ", ".join(discovered_resources))
		else:
			info.append("No discovered resources")
	if has_node("VBoxContainer/lbl_info"):
		$VBoxContainer/lbl_info.text = "\n".join(info)
	else:
		push_error("TileInfoPanelUI: lbl_info node not found!")
#endregion


#region PRIVATE FUNCTIONS
#endregion
