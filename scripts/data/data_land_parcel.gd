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
        "resources": resources.duplicate(),
        "resource_generation_rate": resource_generation_rate
    }


## Adds a resource to the parcel
## @param resource_id: The identifier of the resource
## @param amount: The amount of resource to add
## @param discovered: Whether the resource is discovered
func add_resource(resource_id: String, amount: float = DEFAULT_RESOURCE_AMOUNT, discovered: bool = false) -> void:
    resources[resource_id] = {
        "amount": amount,
        "discovered": discovered
    }


## Gets the amount of a specific resource
## @param resource_id: The identifier of the resource
## @return: The amount of the resource, or 0 if not present
func get_resource_amount(resource_id: String) -> float:
    if not resources.has(resource_id):
        return 0.0
    return resources[resource_id].amount


## Checks if a specific resource is discovered
## @param resource_id: The identifier of the resource
## @return: Whether the resource is discovered
func is_resource_discovered(resource_id: String) -> bool:
    if not resources.has(resource_id):
        return false
    return resources[resource_id].discovered


## Discovers a resource on the parcel
## @param resource_id: The identifier of the resource to discover
## @return: Whether the resource was discovered (false if already discovered or not present)
func discover_resource(resource_id: String) -> bool:
    if not resources.has(resource_id) or resources[resource_id].discovered:
        return false
    resources[resource_id].discovered = true
    return true


## Updates resource amounts based on generation rate
## @param delta: Time elapsed since last update
func update_resources(delta: float) -> void:
    for resource_id in resources:
        if not resources[resource_id].discovered:
            continue
        var base_rate = resource_generation_rate * DEFAULT_GENERATION_RATE
        var terrain_modifiers = Library.get_config("land").terrain_types[terrain_type].resource_modifiers
        var modifier = terrain_modifiers.get(resource_id, 1.0)
        resources[resource_id].amount += base_rate * modifier * delta
#endregion


#region PRIVATE FUNCTIONS
## Initialises the default values for parcel properties
func _initialise_properties() -> void:
    building_id = ""
    improvements = {}
    fertility = 1.0
    pollution_level = 0.0
    is_surveyed = false
    resources = {}
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

## Dictionary of resources and their properties
var resources: Dictionary:
    get:
        return resources
    set(value):
        resources = value

## Base rate at which resources generate
var resource_generation_rate: float:
    get:
        return resource_generation_rate
    set(value):
        resource_generation_rate = value
#endregion 