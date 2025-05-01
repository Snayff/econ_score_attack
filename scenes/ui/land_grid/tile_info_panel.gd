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
## Updates the info panel to show information for the selected tile and demesne.
## @param tile_data: DataLandParcel or null
## @param demesne: Node or null
## @null If tile_data is null, shows 'No tile selected'.
func update_tile_info(tile_data, demesne = null) -> void:
	var info: Array[String] = []
	if tile_data == null:
		info.append("No tile selected")
		Logger.log_event("diagnostic_tile_info_update", {
			"status": "no_tile_selected",
			"timestamp": Time.get_unix_time_from_system()
		}, "TileInfoPanel")
	else:
		var is_surveyed_demesne = false
		var survey_in_progress = false
		if demesne:
			is_surveyed_demesne = demesne.is_parcel_surveyed(tile_data.x, tile_data.y)
			survey_in_progress = demesne.surveys_in_progress.has(Vector2i(tile_data.x, tile_data.y))

		Logger.log_event("diagnostic_tile_info_update", {
			"x": tile_data.x,
			"y": tile_data.y,
			"is_surveyed_parcel": tile_data.is_surveyed,
			"is_surveyed_demesne": is_surveyed_demesne,
			"survey_in_progress": survey_in_progress,
			"has_aspects": not tile_data.get_aspect_storage().get_all_aspects().is_empty(),
			"timestamp": Time.get_unix_time_from_system()
		}, "TileInfoPanel")

		info.append("Parcel: (%d, %d)" % [tile_data.x, tile_data.y])
		if demesne and survey_in_progress:
			info.append("Survey in progress")
		elif not tile_data.is_surveyed or (demesne and not is_surveyed_demesne):
			info.append("Parcel not surveyed")
		else:
			info.append("Terrain: %s" % tile_data.terrain_type)
			info.append("Building: %s" % (tile_data.building_id if tile_data.building_id != "" else "No building"))

			var discovered_aspects = tile_data.get_discovered_aspects()
			Logger.log_event("diagnostic_tile_info_aspects", {
				"x": tile_data.x,
				"y": tile_data.y,
				"discovered_count": discovered_aspects.size(),
				"discovered_ids": discovered_aspects.keys(),
				"all_aspects": tile_data.get_aspect_storage().get_all_aspects(),
				"timestamp": Time.get_unix_time_from_system()
			}, "TileInfoPanel")

			if not discovered_aspects.is_empty():
				var aspect_info: Array[String] = []
				for aspect_id in discovered_aspects:
					var aspect_def = Library.get_land_aspect_by_id(aspect_id)
					if aspect_def.is_empty():
						Logger.log_event("diagnostic_aspect_def_missing", {
							"aspect_id": aspect_id,
							"timestamp": Time.get_unix_time_from_system()
						}, "TileInfoPanel")
						continue

					var amount_text = ""
					# Check if aspect is finite and show amount if it is
					for method in aspect_def.get("extraction_methods", []):
						if method.get("is_finite", true):
							amount_text = " (%.1f remaining)" % tile_data.get_aspect_amount(aspect_id)
							break

					aspect_info.append("%s%s" % [aspect_def.get("f_name", "Unknown"), amount_text])

				if not aspect_info.is_empty():
					info.append("Aspects: " + ", ".join(aspect_info))
			else:
				info.append("No discovered aspects")

	if has_node("VBoxContainer/lbl_info"):
		$VBoxContainer/lbl_info.text = "\n".join(info)
		$VBoxContainer/lbl_info.tooltip_text = "Information about the selected parcel."
	else:
		push_error("TileInfoPanelUI: lbl_info node not found!")
#endregion


#region PRIVATE FUNCTIONS
#endregion
