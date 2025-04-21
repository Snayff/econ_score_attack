## PeopleData
## Manages people-related configuration data
## Handles loading and accessing people configuration
#@icon("")
class_name PeopleData
extends Node


#region SIGNALS
signal config_loaded
signal err_config_load_failed(error: String)
#endregion


#region ON READY (for direct children only)
#endregion


#region EXPORTS
# @export_group("Component Links")
#
# @export_group("Details")
#endregion


#region VARS
## The loaded configuration data from the JSON file
var _config: Dictionary = {}

## The type of configuration this class handles
const _CONFIG_TYPE: String = "people"
#endregion


#region FUNCS
func _init() -> void:
	_load_config()

## Loads the people configuration from the Library
func _load_config() -> void:
	_config = Library.get_config(_CONFIG_TYPE)
	if _config.is_empty():
		emit_signal("err_config_load_failed", "Failed to load people configuration")
		return
	emit_signal("config_loaded")

## Returns the number of people from the configuration
## @return The number of people as an integer
func get_num_people() -> int:
	return _config.get("default_num_people", 0)

## Returns the list of people names from the configuration
## @return An array of people names
func get_names() -> Array:
	return _config.get("people_names", [])

## Returns the job allocation dictionary from the configuration
## @return A dictionary mapping job types to the number of people assigned
func get_job_allocation() -> Dictionary:
	return _config.get("job_allocation", {})

## Returns the starting goods configuration
## @return A dictionary of starting goods and their quantities
func get_starting_goods() -> Dictionary:
	return _config.get("starting_goods", {})
#endregion
