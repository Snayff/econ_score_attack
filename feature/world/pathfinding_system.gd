## PathfindingSystem
## Implements A* pathfinding for the land system with movement cost calculations
## and path optimization.
##
## Example usage:
## ```gdscript
## var pathfinder = PathfindingSystem.new()
## pathfinder.initialize(demesne.land_grid)
## var path = pathfinder.find_path(Vector2i(0, 0), Vector2i(5, 5))
## ```
class_name PathfindingSystem
extends Node


#region CONSTANTS

## Diagonal movement cost multiplier
const DIAGONAL_COST_MULTIPLIER := 1.4142  # sqrt(2)

## Maximum path length to consider
const MAX_PATH_LENGTH := 1000

## Movement directions (including diagonals)
const DIRECTIONS := [
	Vector2i(1, 0),   # Right
	Vector2i(-1, 0),  # Left
	Vector2i(0, 1),   # Down
	Vector2i(0, -1),  # Up
	Vector2i(1, 1),   # Down-Right
	Vector2i(-1, 1),  # Down-Left
	Vector2i(1, -1),  # Up-Right
	Vector2i(-1, -1)  # Up-Left
]

#endregion


#region SIGNALS

## Emitted when a path is found
signal path_found(start: Vector2i, end: Vector2i, path: Array[Vector2i])

## Emitted when path finding fails
signal path_failed(start: Vector2i, end: Vector2i, reason: String)

#endregion


#region EXPORTS

## Whether to allow diagonal movement
@export var allow_diagonal_movement := true

## Whether to use cached movement costs
@export var use_movement_cost_cache := true

#endregion


#region PUBLIC VARIABLES

## The land grid being used for pathfinding
var land_grid: Array[Array]

#endregion


#region PRIVATE VARIABLES

## Cache of movement costs between adjacent tiles
var _movement_cost_cache: Dictionary = {}

## Cache of recently calculated paths
var _path_cache: Dictionary = {}

#endregion


#region ON READY

func _ready() -> void:
	# Clear caches when data changes
	Library.data_loaded.connect(_on_data_loaded)

#endregion


#region PUBLIC FUNCTIONS

## Initializes the pathfinding system with a reference to the land grid
## @param grid: The land grid to use for pathfinding
func initialize(grid: Array[Array]) -> void:
	land_grid = grid
	_clear_caches()


## Finds the optimal path between two points using A* pathfinding
## @param start: Starting coordinates
## @param end: Target coordinates
## @return: Array of Vector2i coordinates representing the path, or empty array if no path found
func find_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	# Check cache first
	var cache_key: String = _get_path_cache_key(start, end)
	if _path_cache.has(cache_key):
		return _path_cache[cache_key].duplicate()
	
	# Validate coordinates
	if not _are_coordinates_valid(start) or not _are_coordinates_valid(end):
		path_failed.emit(start, end, "Invalid coordinates")
		return []
	
	# Initialize A* data structures
	var open_set: Dictionary = {}
	var closed_set: Dictionary = {}
	var came_from: Dictionary = {}
	var g_score: Dictionary = {}
	var f_score: Dictionary = {}
	
	# Set up starting node
	open_set[start] = true
	g_score[start] = 0.0
	f_score[start] = _heuristic_cost_estimate(start, end)
	
	var path_length: int = 0
	
	# Main A* loop
	while not open_set.is_empty() and path_length < MAX_PATH_LENGTH:
		var current: Vector2i = _get_lowest_f_score_node(open_set, f_score)
		
		# Check if we've reached the goal
		if current == end:
			var path: Array[Vector2i] = _reconstruct_path(came_from, current)
			_cache_path(start, end, path)
			path_found.emit(start, end, path)
			return path
		
		open_set.erase(current)
		closed_set[current] = true
		
		# Check all neighbours
		for direction in DIRECTIONS:
			if not allow_diagonal_movement and abs(direction.x) + abs(direction.y) == 2:
				continue
			
			var neighbour: Vector2i = current + direction
			if not _are_coordinates_valid(neighbour) or closed_set.has(neighbour):
				continue
			
			var tentative_g_score: float = g_score[current] + _get_movement_cost(current, neighbour)
			
			if not open_set.has(neighbour) or tentative_g_score < g_score[neighbour]:
				came_from[neighbour] = current
				g_score[neighbour] = tentative_g_score
				f_score[neighbour] = g_score[neighbour] + _heuristic_cost_estimate(neighbour, end)
				open_set[neighbour] = true
		
		path_length += 1
	
	# No path found
	path_failed.emit(start, end, "No path found or path too long")
	return []


## Gets the movement cost between two adjacent tiles
## @param from: Starting coordinates
## @param to: Target coordinates
## @return: Movement cost between the tiles
func get_movement_cost(from: Vector2i, to: Vector2i) -> float:
	return _get_movement_cost(from, to)


## Clears the movement cost and path caches
func clear_caches() -> void:
	_clear_caches()

#endregion


#region PRIVATE FUNCTIONS

## Calculates the heuristic cost estimate between two points
## @param from: Starting coordinates
## @param to: Target coordinates
## @return: Estimated cost to reach target
func _heuristic_cost_estimate(from: Vector2i, to: Vector2i) -> float:
	# Using diagonal distance as heuristic
	var dx: int = abs(to.x - from.x)
	var dy: int = abs(to.y - from.y)
	return (dx + dy) + (DIAGONAL_COST_MULTIPLIER - 2) * min(dx, dy)


## Gets the movement cost between two adjacent tiles
## @param from: Starting coordinates
## @param to: Target coordinates
## @return: Movement cost between the tiles
func _get_movement_cost(from: Vector2i, to: Vector2i) -> float:
	var cache_key: String = _get_movement_cost_cache_key(from, to)
	if use_movement_cost_cache and _movement_cost_cache.has(cache_key):
		return _movement_cost_cache[cache_key]
	
	var from_parcel: DataLandParcel = land_grid[from.y][from.x]
	var to_parcel: DataLandParcel = land_grid[to.y][to.x]
	
	# Get base movement costs from terrain
	var land_data: Dictionary = Library.get_data("land")
	var from_cost: float = land_data.terrain_types[from_parcel.terrain_type].movement_cost
	var to_cost: float = land_data.terrain_types[to_parcel.terrain_type].movement_cost
	
	# Average the costs of both tiles
	var base_cost: float = (from_cost + to_cost) / 2.0
	
	# Apply road improvement modifiers
	var road_multiplier: float = 1.0
	if from_parcel.improvements.has("road"):
		road_multiplier *= land_data.improvements.road.movement_cost_multiplier
	if to_parcel.improvements.has("road"):
		road_multiplier *= land_data.improvements.road.movement_cost_multiplier
	
	# Apply diagonal movement multiplier if needed
	var is_diagonal: bool = from.x != to.x and from.y != to.y
	var diagonal_multiplier: float = DIAGONAL_COST_MULTIPLIER if is_diagonal else 1.0
	
	var final_cost: float = base_cost * road_multiplier * diagonal_multiplier
	
	if use_movement_cost_cache:
		_movement_cost_cache[cache_key] = final_cost
	
	return final_cost


## Gets the node with the lowest f_score from the open set
## @param open_set: Set of nodes to check
## @param f_score: Dictionary of f_scores for nodes
## @return: Node with lowest f_score
func _get_lowest_f_score_node(open_set: Dictionary, f_score: Dictionary) -> Vector2i:
	var lowest_score: float = INF
	var lowest_node: Vector2i
	
	for node in open_set:
		if f_score[node] < lowest_score:
			lowest_score = f_score[node]
			lowest_node = node
	
	return lowest_node


## Reconstructs the path from the came_from map
## @param came_from: Dictionary mapping nodes to their predecessors
## @param current: Current node to start from
## @return: Array of coordinates representing the path
func _reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = [current]
	
	while came_from.has(current):
		current = came_from[current]
		path.push_front(current)
	
	return path


## Checks if coordinates are within the grid bounds
## @param coords: Coordinates to check
## @return: Whether the coordinates are valid
func _are_coordinates_valid(coords: Vector2i) -> bool:
	return coords.x >= 0 and coords.x < land_grid[0].size() and \
		   coords.y >= 0 and coords.y < land_grid.size()


## Gets a cache key for movement costs between two tiles
## @param from: Starting coordinates
## @param to: Target coordinates
## @return: String cache key
func _get_movement_cost_cache_key(from: Vector2i, to: Vector2i) -> String:
	return "%d,%d-%d,%d" % [from.x, from.y, to.x, to.y]


## Gets a cache key for paths between two points
## @param start: Starting coordinates
## @param end: Target coordinates
## @return: String cache key
func _get_path_cache_key(start: Vector2i, end: Vector2i) -> String:
	return "%d,%d-%d,%d" % [start.x, start.y, end.x, end.y]


## Caches a calculated path
## @param start: Starting coordinates
## @param end: Target coordinates
## @param path: Path to cache
func _cache_path(start: Vector2i, end: Vector2i, path: Array[Vector2i]) -> void:
	var cache_key: String = _get_path_cache_key(start, end)
	_path_cache[cache_key] = path.duplicate()


## Clears all caches
func _clear_caches() -> void:
	_movement_cost_cache.clear()
	_path_cache.clear()


## Handles data reloading
## @param data_type: Type of data that was reloaded
func _on_data_loaded(data_type: String) -> void:
	if data_type == "land":
		_clear_caches()

#endregion 