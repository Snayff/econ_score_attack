
## AspectManager
##
## Purpose and Intent:
## - Centralised Aspect Management: Acts as the single source of truth for all land aspect definitions in the game. Land aspects are properties or features (such as resources, terrain features, or special characteristics) that can be assigned to parcels of land within the simulation.
## - Data Loading and Validation: Loads aspect definitions from the external data source (via the Library autoload, which handles JSON/static data), ensuring all aspect data is consistent and up-to-date.
## - Aspect Generation: Provides logic to procedurally generate aspects for a given land parcel, based on definitions and randomised rules (such as generation chance, number of instances, and resource amounts). This supports dynamic and data-driven world-building.
## - Aspect Querying: Offers static methods to retrieve all aspect definitions or a specific aspect definition by its unique ID, making it easy for other systems to access this data without duplicating logic.
## - Error Handling and Logging: Includes error handling (e.g., warnings if no aspects are found) and logs events for debugging and monitoring.
##
## Example Usage:
## ```gdscript
## # Generate aspects for a parcel
## AspectManager.generate_aspects_for_parcel(parcel)
##
## # Retrieve all aspect definitions
## var all_aspects = AspectManager.get_all_aspect_definitions()
##
## # Get a specific aspect definition by ID
## var aspect_def = AspectManager.get_aspect_definition("fertile_soil")
## ```
##
## AspectManager: Handles aspect generation and management for parcels in a World.
## Usage:
##   var am = AspectManager.new()
##   am.initialise_from_config(config)
##   am.generate_aspects_for_parcel(parcel)
##
## Last Updated: 2025-05-18
class_name AspectManager
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
## Callable for loading aspect definitions (can be overridden for testing/modding)
static var _aspect_loader: Callable = Callable()
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
	var aspect_definitions = AspectManager.get_all_aspect_definitions()

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


## Sets the aspect loader function.
## @param loader_func: Callable that returns an Array of aspect definitions.
static func set_aspect_loader(loader_func: Callable) -> void:
	_aspect_loader = loader_func
	_load_aspect_definitions()
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


## Loads aspect definitions from the set loader or Library
static func _load_aspect_definitions() -> void:
	if not _aspect_loader.is_null():
		_aspect_definitions = _aspect_loader.call()
	else:
		_aspect_definitions = Library.get_land_aspects()

	if _aspect_definitions.is_empty():
		push_warning("No land aspects found in Library or via loader")
		_aspect_definitions = []

	Logger.log_event("aspect_definitions_loaded", {
		"count": _aspect_definitions.size(),
	}, "AspectManager")
#endregion
