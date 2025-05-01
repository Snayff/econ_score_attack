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
#endregion

#region PUBLIC FUNCTIONS
## Gets the parcel at (x, y)
## @param x: int
## @param y: int
## @return: DataLandParcel
func get_parcel(x: int, y: int) -> DataLandParcel:
	if x < 0 or y < 0 or x >= grid_width or y >= grid_height:
		Logger.log_event("parcel_access_failed", {"x": x, "y": y, "reason": "out_of_bounds", "timestamp": Time.get_unix_time_from_system()}, "World")
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
	Logger.log_event("world_grid_initialised", {"width": grid_width, "height": grid_height, "timestamp": Time.get_unix_time_from_system()}, "World")
	for x in range(grid_width):
		var column: Array = []
		for y in range(grid_height):
			var terrain_type = "plains" # TODO: randomise or load from config
			var parcel = DataLandParcel.new(x, y, terrain_type)
			Logger.log_event("parcel_created", {"x": x, "y": y, "terrain_type": terrain_type, "timestamp": Time.get_unix_time_from_system()}, "World")
			column.append(parcel)
		land_grid.append(column)
	emit_signal("world_grid_updated")
#endregion

#region PRIVATE FUNCTIONS
#endregion
