## Unit tests for the PathfindingSystem
## Tests pathfinding functionality and movement cost calculations
class_name TestPathfindingSystem
extends ABCTest


#region CONSTANTS


#endregion


#region SIGNALS
#endregion


#region ON READY
#endregion


#region EXPORTS
#endregion


#region PUBLIC VARIABLES

var _pathfinding: PathfindingSystem
var _test_grid: Array[Array]

#endregion


#region PRIVATE VARIABLES
#endregion


#region PUBLIC FUNCTIONS

func before_each() -> void:
	_setup_test_grid()
	_pathfinding = PathfindingSystem.new()
	_pathfinding.initialize(_test_grid)


func after_each() -> void:
	_pathfinding.queue_free()
	_pathfinding = null
	_test_grid.clear()


func test_path_between_adjacent_tiles() -> void:
	var start := Vector2i(0, 0)
	var end := Vector2i(1, 0)
	var path := _pathfinding.find_path(start, end)

	assert_eq(
		path.size(),
		2,
		"Path between adjacent tiles should have length 2"
	)
	assert_eq(
		path[0],
		start,
		"Path should start at start position"
	)
	assert_eq(
		path[1],
		end,
		"Path should end at end position"
	)


func test_path_with_diagonal_movement() -> void:
	_pathfinding.allow_diagonal_movement = true
	var start := Vector2i(0, 0)
	var end := Vector2i(1, 1)
	var path := _pathfinding.find_path(start, end)

	assert_eq(
		path.size(),
		2,
		"Diagonal path should have length 2"
	)
	assert_eq(
		path[0],
		start,
		"Path should start at start position"
	)
	assert_eq(
		path[1],
		end,
		"Path should end at end position"
	)


func test_path_without_diagonal_movement() -> void:
	_pathfinding.allow_diagonal_movement = false
	var start := Vector2i(0, 0)
	var end := Vector2i(1, 1)
	var path := _pathfinding.find_path(start, end)

	assert_eq(
		path.size(),
		3,
		"Non-diagonal path should have length 3"
	)
	assert_eq(
		path[0],
		start,
		"Path should start at start position"
	)
	assert_eq(
		path[-1],
		end,
		"Path should end at end position"
	)


func test_path_with_road_improvement() -> void:
	# Add road to (0,0) -> (1,0)
	var parcel1: DataLandParcel = _test_grid[0][0]
	var parcel2: DataLandParcel = _test_grid[0][1]
	parcel1.improvements["road"] = 1
	parcel2.improvements["road"] = 1

	var start := Vector2i(0, 0)
	var end := Vector2i(1, 0)
	var cost := _pathfinding.get_movement_cost(start, end)

	# Road should reduce movement cost
	var land_config := Library.get_config("land")
	var expected_cost: float = land_config.terrain_types["plains"].movement_cost * \
							  land_config.improvements.road.movement_cost_multiplier * \
							  land_config.improvements.road.movement_cost_multiplier

	assert_eq(
		cost,
		expected_cost,
		"Road should reduce movement cost"
	)


func test_invalid_coordinates() -> void:
	var start := Vector2i(-1, 0)
	var end := Vector2i(0, 0)
	var path := _pathfinding.find_path(start, end)

	assert_eq(
		path.size(),
		0,
		"Path with invalid coordinates should be empty"
	)


func test_path_caching() -> void:
	var start := Vector2i(0, 0)
	var end := Vector2i(2, 2)

	# First path finding should calculate
	var path1 := _pathfinding.find_path(start, end)

	# Second path finding should use cache
	var path2 := _pathfinding.find_path(start, end)

	assert_eq(
		path1,
		path2,
		"Cached path should be identical to original"
	)


func test_movement_cost_caching() -> void:
	var start := Vector2i(0, 0)
	var end := Vector2i(1, 0)

	# First cost calculation
	var cost1 := _pathfinding.get_movement_cost(start, end)

	# Second cost calculation should use cache
	var cost2 := _pathfinding.get_movement_cost(start, end)

	assert_eq(
		cost1,
		cost2,
		"Cached movement cost should be identical to original"
	)

#endregion


#region PRIVATE FUNCTIONS

## Sets up a test grid with known terrain and properties
func _setup_test_grid() -> void:
	_test_grid = []

	# Create a 3x3 grid of plains
	for x in range(3):
		var column: Array[DataLandParcel] = []
		for y in range(3):
			column.append(DataLandParcel.new(x, y, "plains"))
		_test_grid.append(column)

#endregion
