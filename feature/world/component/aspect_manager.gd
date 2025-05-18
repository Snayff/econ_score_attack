## AspectManager: Handles aspect generation and management for parcels in a World.
##
## Purpose and Intent:
## - Centralised Aspect Management: Acts as the single source of truth for all land aspect definitions in the game. Land aspects are properties or features (such as resources, terrain features, or special characteristics) that can be assigned to parcels of land within the simulation.
## - Data Loading and Validation: Loads aspect definitions from the external data source (via the Library autoload, which handles JSON/static data), ensuring all aspect data is consistent and up-to-date.
## - Aspect Generation: Provides logic to procedurally generate aspects for a given land parcel, based on definitions and randomised rules (such as generation chance, number of instances, and resource amounts). This supports dynamic and data-driven world-building.
## - Aspect Querying: Offers methods to retrieve all aspect definitions or a specific aspect definition by its unique ID, making it easy for other systems to access this data without duplicating logic.
##
## Example Usage:
##   var am = AspectManager.new()
##   am.initialise_from_config(config)
##   am.generate_aspects_for_parcel(parcel)
##   var all_aspects = am.get_all_aspect_definitions()
##   var aspect_def = am.get_aspect_definition("fertile_soil")
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
## Array of aspect definitions loaded from config or Library
enum Source { CONFIG, LIBRARY }
var _aspect_definitions: Array = []
var _aspect_source: int = Source.LIBRARY
## Callable for loading aspect definitions (can be overridden for testing/modding)
var _aspect_loader: Callable = Callable()
#endregion


#region PUBLIC FUNCTIONS
func _init() -> void:
	_aspect_definitions = []
	_load_aspect_definitions()


func _ready() -> void:
	_load_aspect_definitions()


## Initialises the AspectManager from the provided config dictionary.
## Loads aspect definitions from config if present, otherwise from Library.
## @param config (Dictionary): The configuration dictionary passed from World.
## @return void
func initialise_from_config(config: Dictionary) -> void:
	if config.has("land_aspects"):
		_aspect_definitions = config["land_aspects"]
		_aspect_source = Source.CONFIG
		Logger.log_event("aspect_definitions_loaded", {
			"count": _aspect_definitions.size(),
			"source": "config"
		}, "AspectManager")
	elif not _aspect_loader.is_null():
		_aspect_definitions = _aspect_loader.call()
		_aspect_source = Source.LIBRARY
		Logger.log_event("aspect_definitions_loaded", {
			"count": _aspect_definitions.size(),
			"source": "custom_loader"
		}, "AspectManager")
	else:
		_aspect_definitions = Library.get_all_land_aspects_data()
		_aspect_source = Source.LIBRARY
		Logger.log_event("aspect_definitions_loaded", {
			"count": _aspect_definitions.size(),
			"source": "library"
		}, "AspectManager")
	if _aspect_definitions.is_empty():
		push_warning("No land aspects found in config, Library, or via loader")
		_aspect_definitions = []


## Generates aspects for a land parcel based on terrain type.
## @param parcel (DataLandParcel): The land parcel to generate aspects for.
## @return void
func generate_aspects_for_parcel(parcel: DataLandParcel) -> void:
	var generated_aspects: Array = []
	for aspect in get_all_aspect_definitions():
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


## Gets an aspect definition by ID.
## @param aspect_id (String): The ID of the aspect to get.
## @return Dictionary: The aspect definition, or empty dictionary if not found.
func get_aspect_definition(aspect_id: String) -> DataLandAspect:
	for aspect in _aspect_definitions:
		if aspect.aspect_id == aspect_id:
			return aspect
	return null


## Gets all aspect definitions.
## @return Array: All aspect definitions currently loaded.
func get_all_aspect_definitions() -> Array[DataLandAspect]:
	return _aspect_definitions.duplicate()


## Sets the aspect loader function.
## @param loader_func (Callable): Callable that returns an Array of aspect definitions.
## @return void
func set_aspect_loader(loader_func: Callable) -> void:
	_aspect_loader = loader_func
	# Optionally reload aspect definitions
	initialise_from_config({})
#endregion


#region PRIVATE FUNCTIONS
## Loads aspect definitions from the set loader or Library
func _load_aspect_definitions() -> void:
	if not _aspect_loader.is_null():
		_aspect_definitions = _aspect_loader.call()
	else:
		_aspect_definitions = Library.get_all_land_aspects_data()

	if _aspect_definitions.is_empty():
		push_warning("No land aspects found in Library or via loader")
		_aspect_definitions = []

	Logger.log_event("aspect_definitions_loaded", {
		"count": _aspect_definitions.size(),
	}, "AspectManager")
#endregion
