## AspectInfoPanel
## A UI panel for displaying detailed land aspect information for a selected parcel.
## Shows all discovered aspects, extraction methods, and resource status.
extends Panel

#region CONSTANTS
const COLOUR_FINITE := Color(1, 0.5, 0.5)
const COLOUR_INFINITE := Color(0.5, 1, 0.5)
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
	# Keyboard shortcut for toggling panel
	InputMap.add_action("toggle_aspect_panel")
	InputMap.action_erase_events("toggle_aspect_panel")
	var key_event := InputEventKey.new()
	key_event.keycode = Key.KEY_I
	InputMap.action_add_event("toggle_aspect_panel", key_event)
	# Connect meta_clicked only once
	if not %rtl_aspect_list.is_connected("meta_clicked", Callable(self, "_on_aspect_clicked")):
		%rtl_aspect_list.connect("meta_clicked", Callable(self, "_on_aspect_clicked"))
#endregion

#region EXPORTS
#endregion

#region PUBLIC FUNCTIONS
## Updates the panel to show information for a specific parcel
## @param parcel: The parcel to display information for
func update_for_parcel(parcel: DataLandParcel) -> void:
	_current_parcel = parcel
	var coords = parcel.get_coordinates() if parcel else Vector2i(-1, -1)
	%lbl_parcel_coords.text = "Parcel (%d, %d)" % [coords.x, coords.y]
	%btn_survey.disabled = parcel.is_surveyed if parcel else true
	_update_aspect_list()
	_update_aspect_info("")
#endregion

#region PRIVATE FUNCTIONS
func _input(event):
	if event.is_action_pressed("toggle_aspect_panel"):
		visible = not visible

## Updates the aspect list display
func _update_aspect_list() -> void:
	%rtl_aspect_list.clear()
	if not _current_parcel:
		%rtl_aspect_list.append_text("[center][i]No parcel selected.[/i][/center]")
		return
	if not _current_parcel.is_surveyed:
		%rtl_aspect_list.append_text("[center][i]This parcel has not been surveyed yet.[/i][/center]")
		return
	var discovered = _current_parcel.get_discovered_aspects()
	if discovered.is_empty():
		%rtl_aspect_list.append_text("[center][i]No notable aspects found in this parcel.[/i][/center]")
		return
	%rtl_aspect_list.append_text("[b]Discovered Aspects:[/b]\n")
	for aspect_id in discovered.keys():
		var aspect_def = Library.get_land_aspect_by_id(aspect_id)
		var amount_text = ""
		var is_finite = false
		for method in aspect_def.get("extraction_methods", []):
			if method.get("is_finite", true):
				amount_text = " (%d remaining)" % _current_parcel.get_aspect_amount(aspect_id)
				is_finite = true
				break
		var colour = COLOUR_FINITE if is_finite else COLOUR_INFINITE
		%rtl_aspect_list.append_text("[color=%s][url=%s]%s[/url]%s[/color]\n" % [colour.to_html(), aspect_id, aspect_def.get("f_name", "Unknown"), amount_text])
	%rtl_aspect_list.tooltip_text = "Click an aspect for details. Green = infinite, Red = finite."

## Updates the aspect info panel with details about an aspect
## @param aspect_id: The ID of the aspect to display, or null for placeholder
func _update_aspect_info(aspect_id: String) -> void:
	%rtl_aspect_info.clear()
	if not aspect_id:
		%rtl_aspect_info.append_text("[i]Select an aspect to see details.[/i]")
		return
	var aspect_def = Library.get_land_aspect_by_id(aspect_id)
	if aspect_def.is_empty():
		%rtl_aspect_info.append_text("[color=red][b]Error:[/b] Aspect data missing.[/color]")
		return
	%rtl_aspect_info.append_text("[b]%s[/b]\n\n" % aspect_def.get("f_name", "Unknown"))
	%rtl_aspect_info.append_text("%s\n\n" % aspect_def.get("description", ""))
	%rtl_aspect_info.append_text("[b]Extraction Methods:[/b]\n")
	for method in aspect_def.get("extraction_methods", []):
		var building = method.get("building", "Unknown")
		var good = method.get("extracted_good", "Unknown")
		var finite_text = "finite" if method.get("is_finite", true) else "infinite"
		var amount_text = ""
		if method.get("is_finite", true):
			amount_text = " (remaining: %d)" % _current_parcel.get_aspect_amount(aspect_id)
		%rtl_aspect_info.append_text("• [b]%s[/b] extracts [b]%s[/b] ([color=%s]%s[/color])%s\n" % [building, good, COLOUR_FINITE.to_html() if method.get("is_finite", true) else COLOUR_INFINITE.to_html(), finite_text, amount_text])
	%rtl_aspect_info.tooltip_text = "Shows extraction methods. Red = finite, Green = infinite."

func _on_aspect_clicked(meta):
	_update_aspect_info(meta)

func _on_land_grid_updated() -> void:
	if _current_parcel:
		update_for_parcel(_current_parcel)

func _on_aspect_discovered(x: int, y: int, aspect_id: String, aspect_data: Dictionary) -> void:
	if _current_parcel and _current_parcel.x == x and _current_parcel.y == y:
		_update_aspect_list()

func _on_survey_completed(x: int, y: int, discovered_aspects: Array) -> void:
	if _current_parcel and _current_parcel.x == x and _current_parcel.y == y:
		_update_aspect_list()
		%btn_survey.disabled = true

func _on_survey_button_pressed() -> void:
	if not _current_parcel:
		return
	if _current_parcel.is_surveyed:
		return
	var coords = _current_parcel.get_coordinates()
	World.complete_survey(coords.x, coords.y)
#endregion

#region VARS
var _current_parcel: DataLandParcel = null
#endregion
