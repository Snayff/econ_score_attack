## World
## Global autoload for the world grid and terrain/resource data.
## Provides access to all parcels and grid dimensions.
## Example usage:
##   var parcel = World.get_parcel(2, 3)
extends Node

#region CONSTANTS
#endregion

#region SIGNALS
## Emitted when the world grid is updated (e.g., after terrain/resource changes)
@warning_ignore("unused_signal")
signal world_grid_updated()
#endregion

#region ON READY
#endregion

#region EXPORTS
#endregion

#region VARS
var land_grid: Array = [] # 2D array [x][y] of DataLandParcel
var grid_width: int = 0
var grid_height: int = 0
var _aspect_manager: AspectManager = AspectManager.new()
var _surveys_in_progress: Dictionary = {} # Dictionary[Vector2i, bool]
#endregion

#region PUBLIC FUNCTIONS
## Gets the parcel at (x, y)
## @param x: int
## @param y: int
## @return: DataLandParcel
func get_parcel(x: int, y: int) -> DataLandParcel:
	if x < 0 or y < 0 or x >= grid_width or y >= grid_height:
		Logger.log_event("parcel_access_failed", {"x": x, "y": y, "reason": "out_of_bounds"}, "World")
		return null
	return land_grid[x][y]

## Gets the grid dimensions
## @return: Vector2i
func get_grid_dimensions() -> Vector2i:
	return Vector2i(grid_width, grid_height)

## Initialises the world grid from config
func initialise_from_config(config: Dictionary) -> void:
	var size = config.get("grid", {}).get("default_size", {"width": 10, "height": 10})
	grid_width = size.width
	grid_height = size.height
	land_grid.clear()
	_surveys_in_progress.clear()
	Logger.log_event("world_grid_initialised", {"width": grid_width, "height": grid_height}, "World")
	for x in range(grid_width):
		var column: Array = []
		for y in range(grid_height):
			var terrain_type = "plains" # TODO: randomise or load from config
			var parcel = DataLandParcel.new(x, y, terrain_type)
			_aspect_manager.generate_aspects_for_parcel(parcel)

			# Get all aspects (including undiscovered) for logging
			var aspect_storage = parcel.get_aspect_storage()
			var all_aspects = aspect_storage.get_all_aspects()
			var aspect_info = {}
			for aspect_id in all_aspects:
				aspect_info[aspect_id] = {
					"amount": aspect_storage.get_aspect_amount(aspect_id),
					"discovered": aspect_storage.is_aspect_discovered(aspect_id)
				}

			Logger.log_event("parcel_created", {
				"x": x,
				"y": y,
				"terrain_type": terrain_type,
				"aspects": aspect_info,
			}, "World")
			column.append(parcel)
		land_grid.append(column)
	emit_signal("world_grid_updated")

## Gets the AspectManager instance for the world
## @return: AspectManager instance
func get_aspect_manager() -> AspectManager:
	return _aspect_manager

## Starts a survey on a parcel at (x, y)
## @param x: int
## @param y: int
## @return: bool - Whether the survey was started successfully
func start_survey(x: int, y: int) -> bool:
	var parcel = get_parcel(x, y)
	if parcel == null:
		return false

	if parcel.is_surveyed:
		return false

	var coords = Vector2i(x, y)
	if _surveys_in_progress.has(coords):
		return false

	_surveys_in_progress[coords] = true
	_aspect_manager.start_survey(parcel)
	EventBusGame.emit_signal("survey_started", x, y)
	return true

## Completes a survey on a parcel at (x, y)
## @param x: int
## @param y: int
## @return: bool - Whether the survey was completed successfully
func complete_survey(x: int, y: int) -> bool:
	var parcel = get_parcel(x, y)
	if parcel == null:
		return false

	var coords = Vector2i(x, y)

	# If already surveyed, just ensure state is consistent
	if parcel.is_surveyed:
		_surveys_in_progress.erase(coords)
		EventBusGame.emit_signal("land_grid_updated")
		return true

	# If survey wasn't started, start it now
	if not _surveys_in_progress.has(coords):
		if not start_survey(x, y):
			return false

	_aspect_manager.complete_survey(parcel)
	_surveys_in_progress.erase(coords)

	# Emit signals in correct order
	EventBusGame.emit_signal("survey_completed", x, y, parcel.get_aspect_storage().get_discovered_aspect_ids())
	EventBusGame.emit_signal("land_grid_updated")
	return true

## Checks if a survey is in progress for the given coordinates
## @param x: int
## @param y: int
## @return: bool - Whether a survey is in progress
func is_survey_in_progress(x: int, y: int) -> bool:
	return _surveys_in_progress.has(Vector2i(x, y))
#endregion

#region PRIVATE FUNCTIONS
#endregion
