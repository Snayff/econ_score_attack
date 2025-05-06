## DataPeople
## Manages people-related configuration data
## Handles loading and accessing people configuration
#@icon("")
class_name DataPeople
extends Node


#region SIGNALS
signal data_loaded
signal err_data_load_failed(error: String)
#endregion


#region ON READY (for direct children only)
#endregion


#region EXPORTS
# @export_group("Component Links")
#
# @export_group("Details")
#endregion


#region VARS
## The loaded data from the JSON file
var _data: Dictionary = {}

## The type of data this class handles
const _DATA_TYPE: String = "people"
#endregion


#region FUNCS
func _init() -> void:
	_load_data_file()

## Loads the people data from the Library
func _load_data_file() -> void:
	_data = Library.get_people_data()
	if _data.is_empty():
		emit_signal("err_data_load_failed", "Failed to load people data")
		return
	emit_signal("data_loaded")

## Returns the number of people from the data
## @return The number of people as an integer
func get_num_people() -> int:
	return _data.get("default_num_people", 0)

## Returns the list of people names from the data
## @return An array of people names
func get_names() -> Array:
	return _data.get("people_names", [])

## Returns the job allocation dictionary from the data
## @return A dictionary mapping job types to the number of people assigned
func get_job_allocation() -> Dictionary:
	return _data.get("job_allocation", {})

## Returns the starting goods data
## @return A dictionary of starting goods and their quantities
func get_starting_goods() -> Dictionary:
	return _data.get("starting_goods", {})
#endregion
