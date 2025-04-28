"""
TileInteractionPanelUI

Panel for tile interaction actions (e.g., build button).
Usage: Attach to TileInteractionPanel.tscn root node.
"""

class_name TileInteractionPanelUI
extends PanelContainer

#region CONSTANTS
#endregion


#region SIGNALS
signal survey_requested(x: int, y: int)
#endregion


#region ON READY
func _ready() -> void:
	if has_node("VBoxContainer/btn_survey"):
		$VBoxContainer/btn_survey.pressed.connect(_on_survey_pressed)
	if has_node("VBoxContainer/btn_build"):
		$VBoxContainer/btn_build.tooltip_text = "Construct a building on this parcel."
	if has_node("VBoxContainer/btn_survey"):
		$VBoxContainer/btn_survey.tooltip_text = "Survey this parcel to reveal its details."
#endregion


#region EXPORTS
#endregion


#region VARS
var _tile_data = null
#endregion


#region PUBLIC FUNCTIONS
func update_for_tile(tile_data, demesne = null) -> void:
	self._tile_data = tile_data
	# Show/hide or enable/disable the Survey button based on tile state
	var btn = $VBoxContainer/btn_survey if has_node("VBoxContainer/btn_survey") else null
	if btn and tile_data and demesne:
		var key = Vector2i(tile_data.x, tile_data.y)
		var can_survey = not demesne.is_parcel_surveyed(tile_data.x, tile_data.y) and not demesne.surveys_in_progress.has(key)
		btn.visible = can_survey
		btn.disabled = not can_survey
	else:
		if btn:
			btn.visible = false
#endregion


#region PRIVATE FUNCTIONS
func _on_survey_pressed() -> void:
	# Assume tile_data is stored as self._tile_data
	if self._tile_data:
		emit_signal("survey_requested", self._tile_data.x, self._tile_data.y)
#endregion

func _exit_tree() -> void:
	# Disconnect signals if needed
	if has_node("VBoxContainer/btn_survey"):
		$VBoxContainer/btn_survey.pressed.disconnect(_on_survey_pressed)
