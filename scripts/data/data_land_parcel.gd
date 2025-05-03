## DataLandParcel
## Represents a single parcel of land in the demesne's grid
## Manages the basic properties and state of a land parcel
## Example:
## ```gdscript
## var parcel = DataLandParcel.new(5, 3, "plains")
## print("Terrain at (%d, %d): %s" % [parcel.x, parcel.y, parcel.terrain_type])
## ```
class_name DataLandParcel
extends RefCounted


#region CONSTANTS
## Default resource generation rate multiplier
const DEFAULT_GENERATION_RATE: float = 1.0

## Default resource amount when discovered
const DEFAULT_RESOURCE_AMOUNT: float = 100.0
#endregion


#region SIGNALS
#endregion


#region ON READY
#endregion


#region EXPORTS
#endregion


#region PUBLIC FUNCTIONS
## Creates a new land parcel with the specified coordinates and terrain type
## @param x_: The x-coordinate of the parcel in the grid
## @param y_: The y-coordinate of the parcel in the grid
## @param terrain_type_: The type of terrain for this parcel
func _init(x_: int, y_: int, terrain_type_: String) -> void:
	x = x_
	y = y_
	terrain_type = terrain_type_
	_initialise_properties()


## Gets the coordinates of this parcel as a Vector2i
## @return: Vector2i containing the parcel's coordinates
func get_coordinates() -> Vector2i:
	return Vector2i(x, y)


## Gets a dictionary containing all parcel properties
## @return: Dictionary with the parcel's current state
func get_properties() -> Dictionary:
	return {
		"x": x,
		"y": y,
		"terrain_type": terrain_type,
		"building_id": building_id,
		"improvements": improvements.duplicate(),
		"fertility": fertility,
		"pollution_level": pollution_level,
		"is_surveyed": is_surveyed,
		"aspects": aspect_storage.to_dict()
	}


## Adds an aspect to the parcel
## @param aspect_id: The identifier of the aspect
## @param amount: The amount of the aspect (for finite aspects)
## @param discovered: Whether the aspect is already discovered
func add_aspect(aspect_id: String, amount: int = 0, discovered: bool = false) -> void:
	aspect_storage.add_aspect(aspect_id, amount, discovered)


## Gets the amount of a specific aspect
## @param aspect_id: The identifier of the aspect
## @return: The amount of the aspect, or 0 if not present
func get_aspect_amount(aspect_id: String) -> int:
	return aspect_storage.get_aspect_amount(aspect_id)


## Checks if a specific aspect is discovered
## @param aspect_id: The identifier of the aspect
## @return: Whether the aspect is discovered
func is_aspect_discovered(aspect_id: String) -> bool:
	return aspect_storage.is_aspect_discovered(aspect_id)


## Discovers an aspect on the parcel
## @param aspect_id: The identifier of the aspect to discover
## @return: Whether the aspect was discovered (false if already discovered or not present)
func discover_aspect(aspect_id: String) -> bool:
	return aspect_storage.discover_aspect(aspect_id)


## Gets all discovered aspects
## @return: Dictionary with aspect_id as key and aspect data as value
func get_discovered_aspects() -> Dictionary:
	return aspect_storage.get_discovered_aspects()


## Completes a survey of the parcel, revealing all aspects
## @return: Array of aspect IDs that were newly discovered
func complete_survey() -> Array:
	Logger.log_event("diagnostic_parcel_complete_survey_start", {
		"x": x,
		"y": y,
		"is_surveyed": is_surveyed,
		"has_aspects": not aspect_storage.get_all_aspects().is_empty(),
	}, "DataLandParcel")

	if is_surveyed:
		Logger.log_event("diagnostic_parcel_already_surveyed", {
			"x": x,
			"y": y,
		}, "DataLandParcel")
		return []

	is_surveyed = true
	var discovered = aspect_storage.discover_all_aspects()

	Logger.log_event("diagnostic_parcel_survey_completed", {
		"x": x,
		"y": y,
		"discovered": discovered,
		"all_aspects": aspect_storage.get_all_aspects(),
		"discovered_aspects": aspect_storage.get_discovered_aspects(),
	}, "DataLandParcel")

	return discovered


## Gets the parcel's aspect storage
## @return: DataParcelAspectStorage instance
func get_aspect_storage() -> DataParcelAspectStorage:
	return aspect_storage


## Converts this DataLandParcel to a DataTileInfo instance for UI display.
## @return: DataTileInfo - Contains location (Vector2i), is_surveyed, and discovered aspects (Array of dictionaries).
func to_tile_info() -> Variant:
	# Gather discovered aspects with metadata for UI
	var aspects: Array = []
	var discovered: Dictionary = get_discovered_aspects()
	for aspect_id in discovered.keys():
		var amount = discovered[aspect_id]
		var aspect_meta = Library.get_land_aspect_by_id(aspect_id)
		if aspect_meta:
			aspects.append({
				"f_name": aspect_meta.get("f_name", aspect_id),
				"description": aspect_meta.get("description", ""),
				"amount": amount
			})
		else:
			aspects.append({
				"f_name": aspect_id,
				"description": "",
				"amount": amount
			})
	return DataTileInfo.new(get_coordinates(), is_surveyed, aspects)
#endregion


#region PRIVATE FUNCTIONS
## Initialises the default values for parcel properties
func _initialise_properties() -> void:
	building_id = ""
	improvements = {}
	fertility = 1.0
	pollution_level = 0.0
	is_surveyed = false
	aspect_storage = DataParcelAspectStorage.new()
	resource_generation_rate = DEFAULT_GENERATION_RATE
#endregion


#region VARS
## X-coordinate in the grid
var x: int:
	get:
		return x
	set(value):
		x = value

## Y-coordinate in the grid
var y: int:
	get:
		return y
	set(value):
		y = value

## Type of terrain in this parcel
var terrain_type: String:
	get:
		return terrain_type
	set(value):
		terrain_type = value

## ID of the building placed on this parcel (empty string if none)
var building_id: String:
	get:
		return building_id
	set(value):
		building_id = value

## Dictionary of improvements and their levels
var improvements: Dictionary:
	get:
		return improvements
	set(value):
		improvements = value

## Base fertility of the parcel (1.0 is normal)
var fertility: float:
	get:
		return fertility
	set(value):
		fertility = value

## Current pollution level (0.0 is unpolluted)
var pollution_level: float:
	get:
		return pollution_level
	set(value):
		pollution_level = value

## Whether this parcel has been surveyed
var is_surveyed: bool:
	get:
		return is_surveyed
	set(value):
		is_surveyed = value

## Storage for aspects and their properties
var aspect_storage: DataParcelAspectStorage

## Base rate at which resources generate
var resource_generation_rate: float:
	get:
		return resource_generation_rate
	set(value):
		resource_generation_rate = value
#endregion
