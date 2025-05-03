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
	# Get references to WorldViewPanel, TileInfoPanelNew, and TileInteractionPanel
	var world_view_panel = $MiddleRightSplit/WorldViewPanel
	var tile_info_panel = $MiddleRightSplit/TileInfoPanel
	var tile_interaction_panel: TileInteractionPanelUI = $TileInteractionPanel

	assert(world_view_panel != null)
	assert(tile_info_panel != null)
	assert(tile_interaction_panel != null)

	# Connect signals
	world_view_panel.tile_selected.connect(_on_tile_selected)
	EventBusGame.request_survey.connect(_on_survey_requested)
	EventBusGame.land_grid_updated.connect(_on_land_grid_updated)
	EventBusUI.survey_completed.connect(_on_survey_completed)
	EventBusGame.parcel_surveyed.connect(_on_parcel_surveyed)

	# Store for later use if needed
	self._world_view_panel = world_view_panel
	self._tile_info_panel = tile_info_panel
	self._tile_interaction_panel = tile_interaction_panel
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

## Call this when the panel is activated to select the centre tile in view.
func on_panel_activated() -> void:
	if _world_view_panel and _world_view_panel.has_method("get_visible_tile_region") and _world_view_panel.has_method("set_selected_tile"):
		var region = _world_view_panel.get_visible_tile_region()
		var top_left: Vector2i = region["top_left"]
		var bottom_right: Vector2i = region["bottom_right"]
		var centre_x = int((top_left.x + bottom_right.x) / 2)
		var centre_y = int((top_left.y + bottom_right.y) / 2)
		_world_view_panel.set_selected_tile(Vector2i(centre_x, centre_y))
#endregion


#region PRIVATE FUNCTIONS
## Handles tile selection signal from WorldViewPanel.
## @param tile_id: int, the selected tile's id
## @param tile_data: DataLandParcel, the selected tile's data
func _on_tile_selected(tile_id: int, tile_data) -> void:
	if _tile_info_panel:
		# Use to_tile_info() if available, otherwise build DataTileInfo with correct structure
		var data_tile_info = tile_data.to_tile_info() if tile_data and tile_data.has_method("to_tile_info") else null
		if not data_tile_info and tile_data:
			var location: Vector2i = tile_data.get_coordinates()
			var is_surveyed: bool = tile_data.is_surveyed
			var aspects: Array = []
			var discovered = tile_data.get_discovered_aspects()
			for aspect_id in discovered.keys():
				var amount = discovered[aspect_id]
				var aspect_meta = Library.get_land_aspect_by_id(aspect_id)
				aspects.append({
					"f_name": aspect_meta.get("f_name", aspect_id) if aspect_meta else aspect_id,
					"description": aspect_meta.get("description", "") if aspect_meta else "",
					"amount": amount
				})
			data_tile_info = DataTileInfo.new(location, is_surveyed, aspects)
		elif not data_tile_info:
			data_tile_info = DataTileInfo.new(Vector2i.ZERO, false, [])
		_tile_info_panel.update_info(data_tile_info)
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
				var data_tile_info = tile_data.to_tile_info() if tile_data and tile_data.has_method("to_tile_info") else null
				if not data_tile_info and tile_data:
					var location: Vector2i = tile_data.get_coordinates()
					var is_surveyed: bool = tile_data.is_surveyed
					var aspects: Array = []
					var discovered = tile_data.get_discovered_aspects()
					for aspect_id in discovered.keys():
						var amount = discovered[aspect_id]
						var aspect_meta = Library.get_land_aspect_by_id(aspect_id)
						aspects.append({
							"f_name": aspect_meta.get("f_name", aspect_id) if aspect_meta else aspect_id,
							"description": aspect_meta.get("description", "") if aspect_meta else "",
							"amount": amount
						})
					data_tile_info = DataTileInfo.new(location, is_surveyed, aspects)
				elif not data_tile_info:
					data_tile_info = DataTileInfo.new(Vector2i.ZERO, false, [])
				_tile_info_panel.update_info(data_tile_info)
			if _tile_interaction_panel:
				_tile_interaction_panel.update_for_tile(tile_data, _demesne)


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
			# Fetch the latest tile data after survey from World singleton
			var tile_data = World.get_parcel(x, y)
			if tile_data:
				var data_tile_info = tile_data.to_tile_info() if tile_data and tile_data.has_method("to_tile_info") else null
				if not data_tile_info and tile_data:
					var location: Vector2i = tile_data.get_coordinates()
					var is_surveyed: bool = tile_data.is_surveyed
					var aspects: Array = []
					var discovered = tile_data.get_discovered_aspects()
					for aspect_id in discovered.keys():
						var amount = discovered[aspect_id]
						var aspect_meta = Library.get_land_aspect_by_id(aspect_id)
						aspects.append({
							"f_name": aspect_meta.get("f_name", aspect_id) if aspect_meta else aspect_id,
							"description": aspect_meta.get("description", "") if aspect_meta else "",
							"amount": amount
						})
					data_tile_info = DataTileInfo.new(location, is_surveyed, aspects)
				elif not data_tile_info:
					data_tile_info = DataTileInfo.new(Vector2i.ZERO, false, [])
				_tile_info_panel.update_info(data_tile_info)


func _exit_tree() -> void:
	# Disconnect signals
	if EventBusUI.survey_completed.is_connected(_on_survey_completed):
		EventBusUI.survey_completed.disconnect(_on_survey_completed)
	if EventBusGame.parcel_surveyed.is_connected(_on_parcel_surveyed):
		EventBusGame.parcel_surveyed.disconnect(_on_parcel_surveyed)
	if EventBusGame.request_survey.is_connected(_on_survey_requested):
		EventBusGame.request_survey.disconnect(_on_survey_requested)
	if EventBusGame.land_grid_updated.is_connected(_on_land_grid_updated):
		EventBusGame.land_grid_updated.disconnect(_on_land_grid_updated)
#endregion

# Import DataTileInfo for static typing
const DataTileInfo = preload("res://scripts/data/data_tile_info.gd")
