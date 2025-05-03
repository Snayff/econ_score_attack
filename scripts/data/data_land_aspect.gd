## DataLandAspect
## Represents a land aspect that can be found on parcels
## Aspects are natural features of land that can be discovered through surveying
## Example:
## ```gdscript
## var aspect = DataLandAspect.new({
##   "aspect_id": "iron_deposit",
##   "f_name": "Iron Deposit",
##   "description": "A rich vein of iron ore.",
##   "generation_chance": 0.3,
##   "max_instances": 1,
##   "extraction_methods": [
##     {
##       "building": "mine",
##       "is_finite": true,
##       "min_amount": 100,
##       "max_amount": 300,
##       "extracted_good": "iron_ore"
##     }
##   ]
## })
## ```
class_name DataLandAspect
extends RefCounted


#region CONSTANTS
#endregion


#region SIGNALS
#endregion


#region ON READY
#endregion


#region EXPORTS
#endregion


#region PUBLIC FUNCTIONS
## Initializes a new land aspect from a dictionary
## @param data: Dictionary containing the aspect's properties
func _init(data: Dictionary) -> void:
	_validate_data(data)
	aspect_id = data.get("aspect_id", "")
	f_name = data.get("f_name", "Unknown Aspect")
	description = data.get("description", "")
	generation_chance = data.get("generation_chance", 0.0)
	max_instances = data.get("max_instances", 1)

	for method_data in data.get("extraction_methods", []):
		var method = {
			"building": method_data.get("building", ""),
			"is_finite": method_data.get("is_finite", true),
			"min_amount": method_data.get("min_amount", 0),
			"max_amount": method_data.get("max_amount", 0),
			"extracted_good": method_data.get("extracted_good", "")
		}
		extraction_methods.append(method)


## Gets all extraction methods for this aspect
## @return: Array of extraction method dictionaries
func get_extraction_methods() -> Array:
	return extraction_methods.duplicate()


## Gets the first extraction method that matches the given building type
## @param building_type: The building type to check for
## @return: Dictionary containing the extraction method or empty dictionary if not found
func get_extraction_method_for_building(building_type: String) -> Dictionary:
	for method in extraction_methods:
		if method.building == building_type:
			return method
	return {}


## Gets a dictionary containing all aspect properties
## @return: Dictionary with the aspect's properties
func to_dict() -> Dictionary:
	return {
		"aspect_id": aspect_id,
		"f_name": f_name,
		"description": description,
		"generation_chance": generation_chance,
		"max_instances": max_instances,
		"extraction_methods": extraction_methods.duplicate()
	}
#endregion


#region PRIVATE FUNCTIONS
## Validates the input data for required fields
## @param data: Dictionary containing the aspect's properties
func _validate_data(data: Dictionary) -> void:
	assert(data.has("aspect_id"), "Land aspect must have an aspect_id")
	assert(data.has("f_name"), "Land aspect must have a f_name")
	assert(data.has("extraction_methods"), "Land aspect must have extraction_methods")

	for method in data.get("extraction_methods", []):
		assert(method.has("building"), "Extraction method must have a building type")
		assert(method.has("extracted_good"), "Extraction method must have an extracted_good")

		if method.get("is_finite", true):
			assert(method.has("min_amount"), "Finite extraction method must have min_amount")
			assert(method.has("max_amount"), "Finite extraction method must have max_amount")
#endregion


#region VARS
## Unique identifier for this aspect
var aspect_id: String:
	get:
		return aspect_id
	set(value):
		aspect_id = value

## Display name for this aspect
var f_name: String:
	get:
		return f_name
	set(value):
		f_name = value

## Description of this aspect
var description: String:
	get:
		return description
	set(value):
		description = value

## Chance (0-1) of this aspect being generated on a parcel
var generation_chance: float:
	get:
		return generation_chance
	set(value):
		generation_chance = clamp(value, 0.0, 1.0)

## Maximum number of instances of this aspect on a single parcel
var max_instances: int:
	get:
		return max_instances
	set(value):
		max_instances = max(1, value)

## List of methods to extract resources from this aspect
var extraction_methods: Array = []
#endregion
