## An environmental system that manages seasonal changes, natural disasters, and pollution
## in the land system.
##
## Example usage:
## ```gdscript
## var env_system = EnvironmentalSystem.new()
## env_system.update_season(Season.SUMMER)
## env_system.apply_disaster(DisasterType.FLOOD, Vector2i(5, 5))
## ```
class_name EnvironmentalSystem
extends Node


#region CONSTANTS

## The different seasons in the game
enum Season {
	SPRING,
	SUMMER,
	AUTUMN,
	WINTER
}

## Types of natural disasters that can occur
enum DisasterType {
	FLOOD,
	DROUGHT,
	FIRE,
	STORM
}

## How far pollution spreads each update
const POLLUTION_SPREAD_RADIUS := 1

## Base pollution decay rate per update
const BASE_POLLUTION_DECAY := 0.05

## Minimum pollution level before decay stops
const MIN_POLLUTION_LEVEL := 0.01

#endregion


#region SIGNALS

## Emitted when a season changes
signal season_changed(new_season: Season)

## Emitted when a natural disaster occurs
signal disaster_occurred(disaster_type: DisasterType, origin: Vector2i, affected_coords: Array[Vector2i])

## Emitted when pollution levels are updated
signal pollution_updated(coords: Vector2i, new_level: float)

## Emitted when an environmental effect is applied
signal effect_applied(effect_id: String, coords: Vector2i, duration: float)

#endregion


#region EXPORTS

## How quickly pollution spreads to neighbouring tiles (0-1)
@export var pollution_spread_rate := 0.2

## How much seasonal changes affect resource generation (0-1)
@export var seasonal_impact := 0.5

#endregion


#region PUBLIC VARIABLES

## The current season
var current_season: Season:
	get:
		return current_season
	set(value):
		if current_season != value:
			current_season = value
			season_changed.emit(current_season)

## Active environmental effects
var active_effects: Dictionary = {}

#endregion


#region PRIVATE VARIABLES

## Reference to the land grid
var _land_grid: Array[Array]

## Currently active disasters
var _active_disasters: Array[Dictionary] = []

## Cache of affected coordinates for quick lookup
var _affected_coords: Dictionary = {}

#endregion


#region ON READY

func _ready() -> void:
	# Initialize with default season
	current_season = Season.SPRING

#endregion


#region PUBLIC FUNCTIONS

## Initializes the environmental system with a reference to the land grid
func initialize(land_grid: Array[Array]) -> void:
	_land_grid = land_grid

## Updates the current season and applies seasonal effects
func update_season(new_season: Season) -> void:
	current_season = new_season
	_apply_seasonal_effects()

## Applies a natural disaster at the given coordinates
func apply_disaster(disaster_type: DisasterType, origin: Vector2i) -> void:
	var affected_coords := _calculate_disaster_spread(disaster_type, origin)
	_active_disasters.append({
		"type": disaster_type,
		"origin": origin,
		"affected_coords": affected_coords,
		"duration": _get_disaster_duration(disaster_type)
	})

	disaster_occurred.emit(disaster_type, origin, affected_coords)

	for coord in affected_coords:
		_apply_disaster_effects(disaster_type, coord)

## Updates pollution levels and spread
func update_pollution() -> void:
	var pollution_changes: Dictionary = {}

	# Calculate pollution spread
	for y in range(_land_grid.size()):
		for x in range(_land_grid[y].size()):
			var coords: Vector2i = Vector2i(x, y)
			var parcel: DataLandParcel = _land_grid[y][x]

			if parcel.pollution_level > MIN_POLLUTION_LEVEL:
				# Calculate pollution decay
				var decay: float = min(parcel.pollution_level, BASE_POLLUTION_DECAY)
				pollution_changes[coords] = pollution_changes.get(coords, 0.0) - decay

				# Calculate spread to neighbours
				var spread_amount: float = parcel.pollution_level * pollution_spread_rate
				var neighbours: Array[Vector2i] = _get_neighbours(coords)

				for neighbour in neighbours:
					pollution_changes[neighbour] = pollution_changes.get(neighbour, 0.0) + (spread_amount / neighbours.size())

	# Apply changes
	for coords in pollution_changes:
		var parcel: DataLandParcel = _land_grid[coords.y][coords.x]
		var new_level: float = maxf(0.0, parcel.pollution_level + pollution_changes[coords])
		parcel.pollution_level = new_level
		pollution_updated.emit(coords, new_level)

## Gets the current resource generation modifier for a given coordinate
func get_resource_modifier(coords: Vector2i) -> float:
	var base_modifier := 1.0

	# Apply seasonal effects
	base_modifier *= _get_seasonal_modifier(coords)

	# Apply disaster effects
	for disaster in _active_disasters:
		if coords in disaster.affected_coords:
			base_modifier *= _get_disaster_modifier(disaster.type)

	# Apply pollution effects
	var parcel: DataLandParcel = _land_grid[coords.y][coords.x]
	base_modifier *= maxf(0.0, 1.0 - parcel.pollution_level)

	return base_modifier

## Updates all active effects and removes expired ones
func update_effects(delta: float) -> void:
	var expired_effects := []

	for effect_id in active_effects:
		var effect = active_effects[effect_id]
		effect.duration -= delta

		if effect.duration <= 0:
			expired_effects.append(effect_id)

	for effect_id in expired_effects:
		active_effects.erase(effect_id)

#endregion


#region PRIVATE FUNCTIONS

## Applies effects based on the current season
func _apply_seasonal_effects() -> void:
	for y in range(_land_grid.size()):
		for x in range(_land_grid[y].size()):
			var coords := Vector2i(x, y)
			var modifier := _get_seasonal_modifier(coords)

			if modifier != 1.0:
				effect_applied.emit("season_%s" % Season.keys()[current_season], coords, -1.0)

## Calculates which coordinates are affected by a disaster
func _calculate_disaster_spread(disaster_type: DisasterType, origin: Vector2i) -> Array[Vector2i]:
	var affected: Array[Vector2i] = []
	affected.append(origin)
	var radius := _get_disaster_radius(disaster_type)

	for y in range(origin.y - radius, origin.y + radius + 1):
		for x in range(origin.x - radius, origin.x + radius + 1):
			if y >= 0 and y < _land_grid.size() and x >= 0 and x < _land_grid[y].size():
				var coords := Vector2i(x, y)
				if coords != origin and coords.distance_to(origin) <= radius:
					affected.append(coords)

	return affected

## Gets the radius of effect for a disaster type
func _get_disaster_radius(disaster_type: DisasterType) -> int:
	match disaster_type:
		DisasterType.FLOOD:
			return 3
		DisasterType.FIRE:
			return 2
		DisasterType.STORM:
			return 4
		DisasterType.DROUGHT:
			return 5
		_:
			return 1

## Gets how long a disaster type lasts
func _get_disaster_duration(disaster_type: DisasterType) -> float:
	match disaster_type:
		DisasterType.FLOOD:
			return 30.0
		DisasterType.FIRE:
			return 15.0
		DisasterType.STORM:
			return 10.0
		DisasterType.DROUGHT:
			return 60.0
		_:
			return 20.0

## Gets the resource generation modifier for a disaster type
func _get_disaster_modifier(disaster_type: DisasterType) -> float:
	match disaster_type:
		DisasterType.FLOOD:
			return 0.5
		DisasterType.FIRE:
			return 0.2
		DisasterType.STORM:
			return 0.7
		DisasterType.DROUGHT:
			return 0.4
		_:
			return 0.8

## Gets the seasonal modifier for resource generation
func _get_seasonal_modifier(coords: Vector2i) -> float:
	var parcel: DataLandParcel = _land_grid[coords.y][coords.x]

	match current_season:
		Season.SPRING:
			return 1.2  # Bonus to growth
		Season.SUMMER:
			return 1.0  # Normal conditions
		Season.AUTUMN:
			return 0.8  # Slight reduction
		Season.WINTER:
			return 0.5  # Major reduction
		_:
			return 1.0

## Gets valid neighbouring coordinates
func _get_neighbours(coords: Vector2i) -> Array[Vector2i]:
	var neighbours: Array[Vector2i] = []
	var directions := [
		Vector2i(0, 1),   # North
		Vector2i(1, 0),   # East
		Vector2i(0, -1),  # South
		Vector2i(-1, 0)   # West
	]

	for dir in directions:
		var new_coords: Vector2i = coords + dir
		if new_coords.y >= 0 and new_coords.y < _land_grid.size() and \
		   new_coords.x >= 0 and new_coords.x < _land_grid[new_coords.y].size():
			neighbours.append(new_coords)

	return neighbours

## Applies the effects of a disaster to a specific coordinate
func _apply_disaster_effects(disaster_type: DisasterType, coords: Vector2i) -> void:
	var parcel: DataLandParcel = _land_grid[coords.y][coords.x]

	match disaster_type:
		DisasterType.FLOOD:
			parcel.pollution_level += 0.2
		DisasterType.FIRE:
			parcel.pollution_level += 0.4
		DisasterType.STORM:
			parcel.pollution_level += 0.1
		DisasterType.DROUGHT:
			# Drought doesn't directly cause pollution
			pass

	if parcel.pollution_level > 0.0:
		pollution_updated.emit(coords, parcel.pollution_level)

#endregion
