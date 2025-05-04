## DataParcelAspectStorage
## Manages the storage of aspect data for a land parcel
## Tracks which aspects are discovered and their amounts
## Example:
## ```gdscript
## var aspect_storage = DataParcelAspectStorage.new()
## aspect_storage.add_aspect("iron_deposit", 250)
## aspect_storage.discover_aspect("iron_deposit")
## ```
class_name DataParcelAspectStorage
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
## Initializes a new, empty aspect storage
func _init() -> void:
	aspects = {}


## Adds an aspect to the storage
## @param aspect_id: The unique identifier of the aspect
## @param amount: The amount for finite aspects (0 for infinite)
## @param discovered: Whether the aspect has been discovered
func add_aspect(aspect_id: String, amount: int = 0, discovered: bool = false) -> void:
	aspects[aspect_id] = {
		"discovered": discovered,
		"amount": amount
	}


## Discovers an aspect that was previously hidden
## @param aspect_id: The unique identifier of the aspect to discover
## @return: True if the aspect was discovered, false if already discovered or not present
func discover_aspect(aspect_id: String) -> bool:
	if not has_aspect(aspect_id) or is_aspect_discovered(aspect_id):
		return false

	aspects[aspect_id].discovered = true
	return true


## Discovers all aspects in storage
## @return: Array of aspect IDs that were newly discovered
func discover_all_aspects() -> Array:
	var newly_discovered = []

	Logger.log_event("diagnostic_discover_all_aspects_start", {
		"aspect_count": aspects.size(),
		"aspects": aspects.keys(),
		"timestamp": Time.get_unix_time_from_system()
	}, "AspectStorage")

	for aspect_id in aspects.keys():
		if not aspects[aspect_id].discovered:
			aspects[aspect_id].discovered = true
			newly_discovered.append(aspect_id)

	Logger.log_event("diagnostic_discover_all_aspects_end", {
		"newly_discovered": newly_discovered,
		"timestamp": Time.get_unix_time_from_system()
	}, "AspectStorage")

	return newly_discovered


## Checks if an aspect exists in the storage
## @param aspect_id: The unique identifier of the aspect to check
## @return: True if the aspect exists, false otherwise
func has_aspect(aspect_id: String) -> bool:
	return aspects.has(aspect_id)


## Checks if an aspect has been discovered
## @param aspect_id: The unique identifier of the aspect to check
## @return: True if the aspect has been discovered, false otherwise
func is_aspect_discovered(aspect_id: String) -> bool:
	if not has_aspect(aspect_id):
		return false

	return aspects[aspect_id].discovered


## Gets the amount of a specific aspect
## @param aspect_id: The unique identifier of the aspect
## @return: The amount of the aspect, or 0 if not present
func get_aspect_amount(aspect_id: String) -> int:
	if not has_aspect(aspect_id):
		return 0

	return aspects[aspect_id].amount


## Sets the amount of a specific aspect
## @param aspect_id: The unique identifier of the aspect
## @param amount: The new amount for the aspect
## @return: True if successful, false if aspect doesn't exist
func set_aspect_amount(aspect_id: String, amount: int) -> bool:
	if not has_aspect(aspect_id):
		return false

	aspects[aspect_id].amount = amount
	return true


## Gets all discovered aspects
## @return: Dictionary with aspect_id as key and aspect data as value
func get_discovered_aspects() -> Dictionary:
	var discovered = {}

	for aspect_id in aspects.keys():
		if aspects[aspect_id].discovered:
			discovered[aspect_id] = aspects[aspect_id].duplicate()

	Logger.log_event("diagnostic_get_discovered_aspects", {
		"discovered_count": discovered.size(),
		"discovered_ids": discovered.keys(),
		"timestamp": Time.get_unix_time_from_system()
	}, "AspectStorage")

	return discovered


## Gets all aspects, including undiscovered ones
## @return: Dictionary with aspect_id as key and aspect data as value
func get_all_aspects() -> Dictionary:
	return aspects.duplicate()


## Gets a list of all discovered aspect IDs
## @return: Array of discovered aspect IDs
func get_discovered_aspect_ids() -> Array:
	var discovered = []

	for aspect_id in aspects.keys():
		if aspects[aspect_id].discovered:
			discovered.append(aspect_id)

	return discovered


## Converts the storage to a dictionary for serialization
## @return: Dictionary representation of this storage
func to_dict() -> Dictionary:
	return {
		"aspects": aspects.duplicate()
	}


## Creates a new storage from a dictionary
## @param data: Dictionary containing the storage data
## @return: New DataParcelAspectStorage instance
static func from_dict(data: Dictionary) -> DataParcelAspectStorage:
	var storage = DataParcelAspectStorage.new()

	for aspect_id in data.get("aspects", {}).keys():
		var aspect_data = data.aspects[aspect_id]
		storage.add_aspect(
			aspect_id,
			aspect_data.get("amount", 0),
			aspect_data.get("discovered", false)
		)

	return storage
#endregion


#region PRIVATE FUNCTIONS
#endregion


#region VARS
## Dictionary mapping aspect_id to aspect data
var aspects: Dictionary:
	get:
		return aspects
	set(value):
		aspects = value
#endregion
