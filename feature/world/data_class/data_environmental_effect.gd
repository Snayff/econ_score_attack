## Data class representing an environmental effect
##
## Example usage:
## ```gdscript
## var effect = DataEnvironmentalEffect.new()
## effect.effect_id = "flood_damage"
## effect.duration = 30.0
## effect.resource_modifier = 0.5
## ```
class_name DataEnvironmentalEffect
extends Resource


#region CONSTANTS


#endregion


#region EXPORTS

## Unique identifier for this effect
@export var effect_id: String

## How long the effect lasts in seconds (-1 for permanent)
@export var duration: float = -1.0

## Modifier applied to resource generation (1.0 is normal)
@export var resource_modifier: float = 1.0

## Amount of pollution this effect adds per update
@export var pollution_increase: float = 0.0

## Chance for the effect to spread to neighbours (0-1)
@export var spread_chance: float = 0.0

## Coordinates affected by this effect
@export var affected_coords: Array[Vector2i] = []

#endregion


#region PUBLIC VARIABLES


#endregion


#region PRIVATE VARIABLES


#endregion


#region PUBLIC FUNCTIONS

## Creates a new environmental effect from a dictionary
static func from_dict(data: Dictionary) -> DataEnvironmentalEffect:
	var effect := DataEnvironmentalEffect.new()
	effect.effect_id = data.get("effect_id", "")
	effect.duration = data.get("duration", -1.0)
	effect.resource_modifier = data.get("resource_modifier", 1.0)
	effect.pollution_increase = data.get("pollution_increase", 0.0)
	effect.spread_chance = data.get("spread_chance", 0.0)

	if data.has("affected_coords"):
		for coord in data.affected_coords:
			effect.affected_coords.append(Vector2i(coord.x, coord.y))

	return effect

## Converts the effect to a dictionary
func to_dict() -> Dictionary:
	var coords_array := []
	for coord in affected_coords:
		coords_array.append({"x": coord.x, "y": coord.y})

	return {
		"effect_id": effect_id,
		"duration": duration,
		"resource_modifier": resource_modifier,
		"pollution_increase": pollution_increase,
		"spread_chance": spread_chance,
		"affected_coords": coords_array
	}

#endregion


#region PRIVATE FUNCTIONS


#endregion
