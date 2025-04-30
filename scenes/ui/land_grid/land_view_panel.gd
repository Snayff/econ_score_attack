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
	# Get references to WorldViewPanel, TileInfoPanel, and TileInteractionPanel
	var world_view_panel = $MiddleRightSplit/WorldViewPanel
	var tile_info_panel = $MiddleRightSplit/TileInfoPanel
	var tile_interaction_panel: TileInteractionPanelUI = $TileInteractionPanel
	assert(world_view_panel != null)
	assert(tile_info_panel != null)
	assert(tile_interaction_panel != null)
	# Connect signal (expects two arguments: tile_id, tile_data)
	world_view_panel.tile_selected.connect(_on_tile_selected)
	if tile_interaction_panel is TileInteractionPanelUI:
		tile_interaction_panel.survey_requested.connect(_on_survey_requested)
	else:
		push_error("TileInteractionPanel does not have the correct script attached!")
	# Store for later use if needed
	self._world_view_panel = world_view_panel
	self._tile_info_panel = tile_info_panel
	self._tile_interaction_panel = tile_interaction_panel
	EventBusGame.land_grid_updated.connect(_on_land_grid_updated)
	EventBusUI.survey_completed.connect(_on_survey_completed)
	EventBusGame.parcel_surveyed.connect(_on_parcel_surveyed)
#endregion


#region EXPORTS
#endregion


#region VARS
var _world_view_panel
var _tile_info_panel
var _tile_interaction_panel
var _demesne: Node = null
#endregion


#region PUBLIC FUNCTIONS
## Sets the grid dimensions and demesne reference, then passes to WorldViewPanel.
## @param width: int
## @param height: int
## @param demesne: Node
func set_grid_and_demesne(width: int, height: int, demesne: Node) -> void:
	_demesne = demesne
	if _world_view_panel:
		_world_view_panel.set_grid_and_demesne(width, height, demesne)
#endregion


#region PRIVATE FUNCTIONS
## Handles tile selection signal from WorldViewPanel.
## @param tile_id: int, the selected tile's id
## @param tile_data: DataLandParcel, the selected tile's data
func _on_tile_selected(tile_id: int, tile_data) -> void:
	if _tile_info_panel:
		_tile_info_panel.update_tile_info(tile_data, _demesne)
	if _tile_interaction_panel:
		_tile_interaction_panel.update_for_tile(tile_data, _demesne)
	else:
		push_error("LandViewPanel: _tile_info_panel is null!")

func _on_survey_requested(x: int, y: int) -> void:
	if _demesne:
		if _demesne.request_survey(x, y):
			EventBusGame.land_grid_updated.emit()
			# Optionally, update panels immediately
			var tile_data = _demesne.get_parcel(x, y)
			if _tile_info_panel:
				_tile_info_panel.update_tile_info(tile_data, _demesne)
			if _tile_interaction_panel:
				_tile_interaction_panel.update_for_tile(tile_data, _demesne)
			# Do NOT emit survey_completed here; wait for actual completion

func _on_land_grid_updated() -> void:
	if _world_view_panel:
		_world_view_panel._update_grid()

func _on_survey_completed(x: int, y: int) -> void:
	# Show notification and visual feedback
	EventBusUI.show_notification.emit("Survey completed for parcel (%d, %d)" % [x, y], "success")
	# Find the tile's screen position for feedback (approximate: centre of WorldViewPanel)
	if _world_view_panel and _world_view_panel.has_method("get_tile_screen_position"):
		var pos = _world_view_panel.get_tile_screen_position(Vector2i(x, y))
		EventBusUI.show_visual_feedback.emit("Surveyed!", pos)
	else:
		# Fallback: centre of WorldViewPanel
		var panel_rect = _world_view_panel.get_global_rect() if _world_view_panel else Rect2(Vector2.ZERO, Vector2(100, 100))
		EventBusUI.show_visual_feedback.emit("Surveyed!", panel_rect.position + panel_rect.size / 2)

func _on_parcel_surveyed(x: int, y: int, discovered_resources: Array) -> void:
	# Now the survey is truly complete; emit UI feedback
	EventBusUI.survey_completed.emit(x, y)
	# If the surveyed tile is currently selected, update the info panel
	if _world_view_panel and _tile_info_panel:
		var selected_coords = _world_view_panel._selected_tile_coords
		if selected_coords == Vector2i(x, y):
			var tile_data = _demesne.get_parcel(x, y) if _demesne else null
			_tile_info_panel.update_tile_info(tile_data, _demesne)

func _exit_tree() -> void:
	# Disconnect signals
	if EventBusUI.survey_completed.is_connected(_on_survey_completed):
		EventBusUI.survey_completed.disconnect(_on_survey_completed)
	if EventBusGame.parcel_surveyed.is_connected(_on_parcel_surveyed):
		EventBusGame.parcel_surveyed.disconnect(_on_parcel_surveyed)
#endregion
