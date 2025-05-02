## AspectManager
## Global autoload for managing land aspects.
## Handles aspect definitions, generation, and validation.
## Example:
## ```gdscript
## AspectManager.generate_aspects_for_parcel(parcel)
## ```

extends Node


#region CONSTANTS
#endregion


#region SIGNALS
#endregion


#region ON READY
#endregion


#region EXPORTS
#endregion


#region VARS
## Array of aspect definitions loaded from Library
static var _aspect_definitions: Array = []
#endregion


#region PUBLIC FUNCTIONS
func _init() -> void:
	_aspect_definitions = []
	_load_aspect_definitions()


func _ready() -> void:
	_load_aspect_definitions()


## Generates aspects for a land parcel based on terrain type
## @param parcel: The land parcel to generate aspects for
static func generate_aspects_for_parcel(parcel: DataLandParcel) -> void:
	var generated_aspects: Array = []
	var aspect_definitions = Library.get_land_aspects()

	for aspect_def in aspect_definitions:
		var aspect: DataLandAspect = DataLandAspect.new(aspect_def)
		if randf() < aspect.generation_chance:
			var instances: int = 1 if aspect.max_instances <= 1 else randi_range(1, aspect.max_instances)

			for i in range(instances):
				var amount: int = 0
				var method: Dictionary = aspect.get_extraction_methods()[0] if not aspect.get_extraction_methods().is_empty() else {}

				if method.get("is_finite", true):
					amount = randi_range(
						method.get("min_amount", 0),
						method.get("max_amount", 100)
					)

				parcel.add_aspect(aspect.aspect_id, amount)
				generated_aspects.append(aspect.aspect_id)


## Gets an aspect definition by ID
## @param aspect_id: The ID of the aspect to get
## @return: Dictionary containing the aspect definition or empty dictionary if not found
static func get_aspect_definition(aspect_id: String) -> Dictionary:
	if not is_instance_valid(AspectManager):
		return {}

	return _get_aspect_definition_internal(aspect_id)


## Gets all aspect definitions
## @return: Array of aspect definitions
static func get_all_aspect_definitions() -> Array:
	if not is_instance_valid(AspectManager):
		return []

	return _get_all_aspect_definitions_internal()
#endregion


#region PRIVATE FUNCTIONS
## Internal implementation of get_aspect_definition
static func _get_aspect_definition_internal(aspect_id: String) -> Dictionary:
	for aspect in _aspect_definitions:
		if aspect.get("aspect_id") == aspect_id:
			return aspect
	return {}


## Internal implementation of get_all_aspect_definitions
static func _get_all_aspect_definitions_internal() -> Array:
	return _aspect_definitions.duplicate()


## Loads aspect definitions from Library
static func _load_aspect_definitions() -> void:
	_aspect_definitions = Library.get_land_aspects()

	if _aspect_definitions.is_empty():
		push_warning("No land aspects found in Library")
		_aspect_definitions = []

	Logger.log_event("aspect_definitions_loaded", {
		"count": _aspect_definitions.size(),
		"timestamp": Time.get_unix_time_from_system()
	}, "AspectManager")
#endregion
