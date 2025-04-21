## class desc
#@icon("")
class_name PeopleData
extends Node

var config: Dictionary

func _init() -> void:
	load_config()

func load_config() -> void:
	var file = FileAccess.open("res://data/people_config.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
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

func get_num_people() -> int:
	return config.get("default_num_people", 3)

func get_names() -> Array:
	return config.get("people_names", [])

func get_job_allocation() -> Dictionary:
	return config.get("job_allocation", {})

func get_starting_goods() -> Dictionary:
	return config.get("starting_goods", {}) 