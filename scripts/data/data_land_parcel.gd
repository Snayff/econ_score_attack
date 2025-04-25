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


#region SIGNALS


#region ON READY


#region EXPORTS


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
        "is_surveyed": is_surveyed
    }
#endregion


#region PRIVATE FUNCTIONS
## Initialises the default values for parcel properties
func _initialise_properties() -> void:
    building_id = ""
    improvements = {}
    fertility = 1.0
    pollution_level = 0.0
    is_surveyed = false
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
#endregion 