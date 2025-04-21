## PeopleData
## A class that manages the configuration data for people in the simulation.
## It loads data from a JSON file and provides access to people-related configuration.
#@icon("")
class_name PeopleData
extends Node

#region VARS
## The loaded configuration data from the JSON file
var config: Dictionary = {}
#endregion

#region FUNCS
## Initializes the PeopleData class and loads the configuration
func _init() -> void:
	load_config()

## Loads the people configuration from the JSON file
## If the file cannot be loaded, it sets default values
func load_config() -> void:
	var file: FileAccess = FileAccess.open("res://data/people_config.json", FileAccess.READ)
	if file:
		var json: JSON = JSON.new()
		var parse_result: Error = json.parse(file.get_as_text())
		if parse_result == OK:
			config = json.get_data()
		file.close()
	else:
		push_error("Failed to load people configuration file")
		# Fallback default values
		config = {
			"default_num_people": 3,
			"people_names": ["sally", "reginald", "estaban"],
			"job_allocation": {
				"farmer": 1,
				"water collector": 1,
				"woodcutter": 1
			},
			"starting_goods": {
				"money": 100,
				"grain": 3,
				"water": 3,
				"wood": 0
			}
		}

## Returns the default number of people in the simulation
## @return The number of people as an integer
func get_num_people() -> int:
	return config.get("default_num_people", 3)

## Returns the list of people names from the configuration
## @return An array of people names
func get_names() -> Array:
	return config.get("people_names", [])

## Returns the job allocation dictionary from the configuration
## @return A dictionary mapping job types to the number of people assigned
func get_job_allocation() -> Dictionary:
	return config.get("job_allocation", {})

## Returns the starting goods configuration
## @return A dictionary of starting goods and their quantities
func get_starting_goods() -> Dictionary:
	return config.get("starting_goods", {})
#endregion 