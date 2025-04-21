## DataDemesne
## Manages demesne-related configuration data
## Handles loading and accessing demesne configuration
#@icon("")
class_name DataDemesne
extends Node


#region SIGNALS
signal config_loaded
signal err_config_load_failed(error: String)
#endregion


#region VARS
## The loaded configuration data from the JSON file
var _config: Dictionary = {}

## The type of configuration this class handles
const _CONFIG_TYPE: String = "demesne"
#endregion


#region FUNCS
func _init() -> void:
	_load_config()

## Loads the demesne configuration from the Library
func _load_config() -> void:
	_config = Library.get_config(_CONFIG_TYPE)
	if _config.is_empty():
		emit_signal("err_config_load_failed", "Failed to load demesne configuration")
		return
	emit_signal("config_loaded")

## Returns the default demesne name from the configuration
## @return The default demesne name as a string
func get_default_demesne_name() -> String:
	return _config.get("default_demesne_name", "Main Demesne")

## Returns the starting resources from the configuration
## @return A dictionary of starting resources and their quantities
func get_starting_resources() -> Dictionary:
	return _config.get("starting_resources", {})

## Returns the job allocation dictionary from the configuration
## @return A dictionary mapping job types to the number of people assigned
func get_job_allocation() -> Dictionary:
	return _config.get("job_allocation", {})
#endregion 