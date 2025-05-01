## AspectInfoPanel
## A simple UI panel for displaying land aspect information
## Shows discovered aspects for a selected parcel
extends Panel


#region CONSTANTS
#endregion


#region SIGNALS
#endregion


#region ON READY
func _ready() -> void:
	EventBusGame.connect("land_grid_updated", _on_land_grid_updated)
	EventBusGame.connect("aspect_discovered", _on_aspect_discovered)
	EventBusGame.connect("survey_completed", _on_survey_completed)
	
	%rtl_aspect_list.clear()
	%rtl_aspect_info.clear()
	%lbl_parcel_coords.text = ""
	%btn_survey.disabled = true
	%btn_survey.connect("pressed", _on_survey_button_pressed)
#endregion


#region EXPORTS
#endregion


#region PUBLIC FUNCTIONS
## Updates the panel to show information for a specific parcel
## @param parcel: The parcel to display information for
func update_for_parcel(parcel: DataLandParcel) -> void:
	_current_parcel = parcel
	var coords = parcel.get_coordinates()
	
	%lbl_parcel_coords.text = "Parcel (%d, %d)" % [coords.x, coords.y]
	%btn_survey.disabled = parcel.is_surveyed
	
	_update_aspect_list()
#endregion


#region PRIVATE FUNCTIONS
## Updates the aspect list display
func _update_aspect_list() -> void:
	%rtl_aspect_list.clear()
	
	if not _current_parcel:
		return
	
	if not _current_parcel.is_surveyed:
		%rtl_aspect_list.append_text("[center]This parcel has not been surveyed yet.[/center]")
		return
	
	var discovered = _current_parcel.get_discovered_aspects()
	
	if discovered.is_empty():
		%rtl_aspect_list.append_text("[center]No notable aspects found in this parcel.[/center]")
		return
	
	%rtl_aspect_list.append_text("[b]Discovered Aspects:[/b]\n")
	
	for aspect_id in discovered.keys():
		var aspect_def = Library.get_land_aspect_by_id(aspect_id)
		var amount_text = ""
		
		# Check if aspect is finite and show amount if it is
		for method in aspect_def.get("extraction_methods", []):
			if method.get("is_finite", true):
				amount_text = " (%d remaining)" % _current_parcel.get_aspect_amount(aspect_id)
				break
		
		%rtl_aspect_list.append_text("• %s%s\n" % [aspect_def.get("f_name", "Unknown"), amount_text])


## Updates the aspect info panel with details about an aspect
## @param aspect_id: The ID of the aspect to display
func _update_aspect_info(aspect_id: String) -> void:
	%rtl_aspect_info.clear()
	
	var aspect_def = Library.get_land_aspect_by_id(aspect_id)
	
	if aspect_def.is_empty():
		return
	
	%rtl_aspect_info.append_text("[b]%s[/b]\n\n" % aspect_def.get("f_name", "Unknown"))
	%rtl_aspect_info.append_text("%s\n\n" % aspect_def.get("description", ""))
	
	%rtl_aspect_info.append_text("[b]Extraction Methods:[/b]\n")
	
	for method in aspect_def.get("extraction_methods", []):
		var building = method.get("building", "Unknown")
		var good = method.get("extracted_good", "Unknown")
		var finite_text = "finite" if method.get("is_finite", true) else "infinite"
		
		%rtl_aspect_info.append_text("• %s can extract %s (%s)\n" % [building, good, finite_text])


## Called when the land grid is updated
func _on_land_grid_updated() -> void:
	if _current_parcel:
		update_for_parcel(_current_parcel)


## Called when an aspect is discovered
## @param x: X coordinate of the parcel
## @param y: Y coordinate of the parcel
## @param aspect_id: ID of the discovered aspect
## @param aspect_data: Data about the discovered aspect
func _on_aspect_discovered(x: int, y: int, aspect_id: String, aspect_data: Dictionary) -> void:
	if _current_parcel and _current_parcel.x == x and _current_parcel.y == y:
		_update_aspect_list()


## Called when a survey is completed
## @param x: X coordinate of the parcel
## @param y: Y coordinate of the parcel
## @param discovered_aspects: Array of discovered aspect IDs
func _on_survey_completed(x: int, y: int, discovered_aspects: Array) -> void:
	if _current_parcel and _current_parcel.x == x and _current_parcel.y == y:
		_update_aspect_list()
		%btn_survey.disabled = true


## Called when the survey button is pressed
func _on_survey_button_pressed() -> void:
	if not _current_parcel:
		return
	
	if _current_parcel.is_surveyed:
		return
	
	var coords = _current_parcel.get_coordinates()
	World.complete_survey(coords.x, coords.y)
#endregion


#region VARS
## Currently displayed parcel
var _current_parcel: DataLandParcel = null
#endregion 