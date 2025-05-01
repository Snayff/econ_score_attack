## AspectManager
## Manages the generation and discovery of land aspects
## Handles aspect data validation and logging
## Example:
## ```gdscript
## var manager = AspectManager.new()
## manager.generate_aspects_for_parcel(parcel)
## ```
class_name AspectManager
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
## Initializes the AspectManager with default settings
func _init() -> void:
	# Load aspect definitions from Library when created
	_load_aspect_definitions()


## Generates aspects for a land parcel based on terrain type
## @param parcel: The land parcel to generate aspects for
func generate_aspects_for_parcel(parcel: DataLandParcel) -> void:
	var generated_aspects = []

	for aspect_def in _aspect_definitions:
		var aspect = DataLandAspect.new(aspect_def)
		if _should_generate_aspect(aspect, parcel.terrain_type):
			var instances = _get_random_instances(aspect)

			for i in range(instances):
				var amount = 0
				var method = aspect.get_extraction_methods()[0] if not aspect.get_extraction_methods().is_empty() else {}

				if method.get("is_finite", true):
					amount = _get_random_amount(
						method.get("min_amount", 0),
						method.get("max_amount", 100)
					)

				parcel.add_aspect(aspect.aspect_id, amount)

				generated_aspects.append(aspect.aspect_id)


## Starts a survey on a land parcel
## @param parcel: The land parcel to survey
func start_survey(parcel: DataLandParcel) -> void:
	if parcel.is_surveyed:
		Logger.log_event("survey_start_failed", {
			"x": parcel.x,
			"y": parcel.y,
			"reason": "already_surveyed",
		}, "AspectManager")
		return

	Logger.log_event("survey_start", {
		"x": parcel.x,
		"y": parcel.y,
		"has_aspects": not parcel.get_aspect_storage().get_all_aspects().is_empty(),
	}, "AspectManager")


## Completes a survey on a land parcel, revealing all aspects
## @param parcel: The land parcel to complete survey on
func complete_survey(parcel: DataLandParcel) -> void:
	if parcel.is_surveyed:
		Logger.log_event("survey_complete_failed", {
			"x": parcel.x,
			"y": parcel.y,
			"reason": "already_surveyed",
		}, "AspectManager")
		return

	Logger.log_event("survey_complete_started", {
		"x": parcel.x,
		"y": parcel.y,
		"has_aspects": not parcel.get_aspect_storage().get_all_aspects().is_empty(),
	}, "AspectManager")

	# First discover all aspects
	var discovered_aspects = parcel.complete_survey()

	Logger.log_event("survey_complete_discovery", {
		"x": parcel.x,
		"y": parcel.y,
		"discovered_count": discovered_aspects.size(),
		"discovered_aspects": discovered_aspects,
	}, "AspectManager")

	# Then emit individual aspect discoveries
	for aspect_id in discovered_aspects:
		var aspect_data = {
			"amount": parcel.get_aspect_amount(aspect_id),
			"discovered": true
		}

		EventBusGame.emit_signal("aspect_discovered", parcel.x, parcel.y, aspect_id, aspect_data)

		Logger.log_event("aspect_discovered", {
			"x": parcel.x,
			"y": parcel.y,
			"aspect_id": aspect_id,
			"amount": aspect_data.amount,
		}, "AspectManager")

	# Finally mark the parcel as surveyed and emit completion
	parcel.is_surveyed = true

	EventBusGame.emit_signal("survey_completed", parcel.x, parcel.y, discovered_aspects)


## Gets an aspect definition by ID
## @param aspect_id: The ID of the aspect to get
## @return: Dictionary containing the aspect definition or empty dictionary if not found
func get_aspect_definition(aspect_id: String) -> Dictionary:
	for aspect in _aspect_definitions:
		if aspect.get("aspect_id") == aspect_id:
			return aspect
	return {}


## Gets all aspect definitions
## @return: Array of aspect definitions
func get_all_aspect_definitions() -> Array:
	return _aspect_definitions.duplicate()
#endregion


#region PRIVATE FUNCTIONS
## Loads aspect definitions from Library
func _load_aspect_definitions() -> void:
	_aspect_definitions = Library.get_land_aspects()

	if _aspect_definitions.is_empty():
		push_warning("No land aspects found in Library")
		_aspect_definitions = []

	Logger.log_event("aspect_definitions_loaded", {
		"count": _aspect_definitions.size(),
		"timestamp": Time.get_unix_time_from_system()
	}, "AspectManager")


## Determines if an aspect should be generated for a parcel based on chance
## @param aspect: The aspect to check
## @param terrain_type: The terrain type of the parcel
## @return: True if the aspect should be generated, false otherwise
func _should_generate_aspect(aspect: DataLandAspect, terrain_type: String) -> bool:
	# TODO: Consider terrain type modifiers for generation chance

	var chance = aspect.generation_chance

	# Apply random check based on chance
	return randf() < chance


## Gets a random number of instances for an aspect, up to the max
## @param aspect: The aspect to get instances for
## @return: Number of instances to generate
func _get_random_instances(aspect: DataLandAspect) -> int:
	if aspect.max_instances <= 1:
		return 1

	return randi_range(1, aspect.max_instances)


## Gets a random amount for a finite aspect
## @param min_amount: The minimum amount
## @param max_amount: The maximum amount
## @return: A random amount between min and max
func _get_random_amount(min_amount: int, max_amount: int) -> int:
	return randi_range(min_amount, max_amount)
#endregion


#region VARS
## Array of aspect definitions loaded from Library
var _aspect_definitions: Array = []
#endregion
