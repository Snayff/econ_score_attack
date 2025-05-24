## DataDemesne
## Manages demesne-related configuration data
## Handles loading and accessing demesne configuration
#@icon("")
class_name DataDemesne
extends Node


#region SIGNALS
signal data_loaded
signal err_data_load_failed(error: String)
#endregion


#region VARS
## The loaded data from the JSON file
var _data: Dictionary = {}

## The type of data this class handles
const _DATA_TYPE: String = "demesne"
#endregion


#region FUNCS
func _init() -> void:
	_load_data_file()

## Loads the demesne data from the Library
func _load_data_file() -> void:
	_data = Library.get_all_demesne_data()
	if _data.is_empty():
		emit_signal("err_data_load_failed", "Failed to load demesne data")
		return
	emit_signal("data_loaded")

## Returns the default demesne name from the data
## @return The default demesne name as a string
func get_default_demesne_name() -> String:
	return _data.get("default_demesne_name", "Main Demesne")

## Returns the starting resources from the data
## @return A dictionary of starting resources and their quantities
func get_starting_resources() -> Dictionary:
	return _data.get("starting_resources", {})

## Returns the job allocation dictionary from the data
## @return A dictionary mapping job types to the number of people assigned
func get_job_allocation() -> Dictionary:
	return _data.get("job_allocation", {})
#endregion
