## ResourceGenerator
## Component that handles resource generation and discovery for land parcels
## Example:
## ```gdscript
## var generator = ResourceGenerator.new()
## generator.initialise_resources(parcel)
## generator.update(delta)
## ```
class_name ResourceGenerator
extends Node


#region CONSTANTS
## Base chance for aspect discovery when surveying
const BASE_DISCOVERY_CHANCE: float = 0.2

## Minimum time between resource updates in seconds
const MIN_UPDATE_INTERVAL: float = 1.0
#endregion


#region SIGNALS
## Emitted when an aspect is discovered
signal aspect_discovered(x: int, y: int, aspect_id: String, aspect_data: Dictionary)

## Emitted when aspect amounts are updated
signal aspects_updated(x: int, y: int, aspects: Dictionary)
#endregion


#region ON READY
func _ready() -> void:
	# Connect to event bus for global events if needed
	pass
#endregion


#region EXPORTS
#endregion


#region PUBLIC FUNCTIONS
## Initialises aspects for a land parcel based on terrain type
## @param parcel: The land parcel to initialise aspects for
func initialise_resources(parcel: DataLandParcel) -> void:
	var land_config = Library.get_config("land")
	var terrain_type = land_config.terrain_types[parcel.terrain_type]
	var resource_modifiers = terrain_type.resource_modifiers

	# Load land aspects from Library
	var land_aspects = Library.get_land_aspects()

	for aspect_def in land_aspects:
		var aspect = DataLandAspect.new(aspect_def)
		for method in aspect.get_extraction_methods():
			var good = method.extracted_good
			if resource_modifiers.has(good) and resource_modifiers[good] > 0:
				# Use min_amount if finite, else 0 for infinite
				var amount = method.is_finite and method.min_amount or 0
				parcel.add_aspect(aspect.aspect_id, amount)


## Attempts to discover aspects in a parcel through surveying
## @param parcel: The land parcel to survey
## @return: Array of discovered aspect IDs
func survey_parcel(parcel: DataLandParcel) -> Array[String]:
	if parcel.is_surveyed:
		return []

	# If the parcel isn't already marked as surveyed,
	# discover all aspects and emit signals for them
	var newly_discovered: Array[String] = []
	var aspect_storage = parcel.get_aspect_storage()

	# Get all aspects (discovered and undiscovered)
	var all_aspects = aspect_storage.get_all_aspects()

	# Emit signals for each aspect
	for aspect_id in all_aspects.keys():
		if aspect_storage.is_aspect_discovered(aspect_id):
			# This aspect was already discovered
			var aspect_data = {
				"amount": parcel.get_aspect_amount(aspect_id)
			}
			emit_signal("aspect_discovered", parcel.x, parcel.y, aspect_id, aspect_data)
			newly_discovered.append(aspect_id)

	# Update signal to show all aspects for this parcel
	var all_discovered = parcel.get_discovered_aspects()
	emit_signal("aspects_updated", parcel.x, parcel.y, all_discovered)

	return newly_discovered


## Updates aspect generation for a parcel
## @param parcel: The land parcel to update
## @param delta: Time elapsed since last update
func update(parcel: DataLandParcel, delta: float) -> void:
	if delta < MIN_UPDATE_INTERVAL:
		return

	# For now, aspects don't need updating as they're either finite or infinite
	# This method is kept for future expansion (e.g., seasonal changes, etc.)
	pass
#endregion


#region PRIVATE FUNCTIONS
## Calculates the chance of discovering a specific aspect
## @param parcel: The land parcel being surveyed
## @param aspect_id: The aspect being checked
## @return: Float between 0 and 1 representing discovery chance
func _calculate_discovery_chance(parcel: DataLandParcel, aspect_id: String) -> float:
	var land_config = Library.get_config("land")
	var terrain_type = land_config.terrain_types[parcel.terrain_type]

	# Get the aspect definition
	var aspect_def = Library.get_land_aspect_by_id(aspect_id)
	if aspect_def.is_empty():
		return 0.0

	# Check if any of the aspect's extraction methods match terrain modifiers
	for method in aspect_def.get("extraction_methods", []):
		var good = method.get("extracted_good", "")
		var terrain_modifier = terrain_type.resource_modifiers.get(good, 0.0)

		# Higher terrain modifiers increase discovery chance
		if terrain_modifier > 0:
			return BASE_DISCOVERY_CHANCE * terrain_modifier

	return 0.0
#endregion
