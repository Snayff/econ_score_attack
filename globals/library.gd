## Global singleton for managing all external data loading and access
## Handles JSON configuration files and provides centralised data access
## @icon("")
extends Node


#region SIGNALS
signal config_loaded(config_type: String)
signal err_config_load_failed(config_type: String, error: String)
signal cache_cleared
#endregion


#region ON READY
func _ready() -> void:
	_load_config("goods")
	_load_config("consumption_rules")
	_load_config("laws")
	_load_config("land")
	_load_config("land_aspects")
#endregion


#region EXPORTS
#endregion


#region VARS
## Cache of loaded configuration data by type
var _config_cache: Dictionary = {}

## Configuration file paths by type
const _CONFIG_FILES: Dictionary = {
	"people": "res://data/people.json",
	"demesne": "res://data/demesne.json",
	"goods": "res://data/goods.json",
	"consumption_rules": "res://data/rules/consumption_rules.json",
	"laws": "res://data/rules/laws.json",
	"land": "res://feature/world_map/data/land_config.json",
	"land_aspects": "res://feature/world_map/data/land_aspects.json"
}

## Default values by config type
const _DEFAULT_CONFIGS: Dictionary = {
	"people": {
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
	},
	"demesne": {
		"default_demesne_name": "Main Demesne",
		"starting_resources": {
			"money": 0,
			"grain": 0,
			"water": 0,
			"wood": 0,
			"bureaucracy": 0
		},
		"job_allocation": {
			"farmer": 1,
			"water collector": 1,
			"woodcutter": 1,
			"bureaucrat": 0
		}
	},
	"goods": {
		"goods": {
			"grain": {
				"base_price": 10,
				"category": "food",
				"icon": "🌾"
			},
			"water": {
				"base_price": 10,
				"category": "resource",
				"icon": "💧"
			},
			"wood": {
				"base_price": 20,
				"category": "material",
				"icon": "🪵"
			},
			"bureaucracy": {
				"base_price": 0,
				"category": "service",
				"icon": "📜"
			}
		}
	},
	"consumption_rules": {
		"consumption_rules": [
			{
				"good_id": "grain",
				"min_consumption_amount": 1,
				"desired_consumption_amount": 2,
				"min_held_before_desired_consumption": 3,
				"amount_to_hold_before_selling": 10,
				"desired_consumption_happiness_increase": 2,
				"consumption_failure_cost": 1
			},
			{
				"good_id": "water",
				"min_consumption_amount": 2,
				"desired_consumption_amount": 4,
				"min_held_before_desired_consumption": 10,
				"amount_to_hold_before_selling": 20,
				"desired_consumption_happiness_increase": 2,
				"consumption_failure_cost": 1
			}
		]
	},
	"land": {
		"terrain_types": {
			"plains": {
				"base_fertility": 1.0,
				"movement_cost": 1.0,
				"resource_modifiers": {
					"grain": 1.0,
					"wood": 0.5
				}
			},
			"forest": {
				"base_fertility": 0.8,
				"movement_cost": 1.5,
				"resource_modifiers": {
					"grain": 0.5,
					"wood": 2.0
				}
			},
			"mountains": {
				"base_fertility": 0.4,
				"movement_cost": 2.0,
				"resource_modifiers": {
					"grain": 0.2,
					"wood": 0.3
				}
			}
		},
		"improvements": {
			"road": {
				"movement_cost_multiplier": 0.75,
				"max_level": 3,
				"cost": {
					"wood": 10,
					"money": 50
				}
			},
			"irrigation": {
				"fertility_multiplier": 1.25,
				"max_level": 2,
				"cost": {
					"wood": 5,
					"money": 30
				}
			}
		},
		"grid": {
			"default_size": {
				"width": 10,
				"height": 10
			},
			"min_size": {
				"width": 5,
				"height": 5
			},
			"max_size": {
				"width": 50,
				"height": 50
			}
		}
	}
}

const _LAND_ASPECTS_FILE: String = "land_aspects.json"
var _land_aspects: Array = []
#endregion


#region PUBLIC FUNCS
## Gets configuration data for a specific type
## @param config_type: The type of configuration to load (e.g., "people")
## @return: Dictionary containing the configuration data
func get_config(config_type: String) -> Dictionary:
	if not _CONFIG_FILES.has(config_type):
		var error_msg: String = "Unknown config type: " + config_type
		emit_signal("err_config_load_failed", config_type, error_msg)
		push_error(error_msg)
		return {}

	if not _config_cache.has(config_type):
		_load_config(config_type)

	return _config_cache[config_type]

## Loads configuration data from file
## @param config_type: The type of configuration to load
func _load_config(config_type: String) -> void:
	var file_path: String = _CONFIG_FILES[config_type]
	var full_path: String = file_path

	var file: FileAccess = FileAccess.open(full_path, FileAccess.READ)
	if not file:
		var error_msg: String = "Failed to open file: " + full_path
		emit_signal("err_config_load_failed", config_type, error_msg)
		push_error(error_msg)
		_set_default_config(config_type)
		return

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(file.get_as_text())
	file.close()

	if parse_result != OK:
		var error_msg: String = "Failed to parse JSON file: " + full_path
		emit_signal("err_config_load_failed", config_type, error_msg)
		push_error(error_msg)
		_set_default_config(config_type)
		return

	_config_cache[config_type] = json.get_data()
	emit_signal("config_loaded", config_type)

## Sets default configuration values for a type
## @param config_type: The type of configuration to set defaults for
func _set_default_config(config_type: String) -> void:
	if _DEFAULT_CONFIGS.has(config_type):
		_config_cache[config_type] = _DEFAULT_CONFIGS[config_type].duplicate(true)
	else:
		_config_cache[config_type] = {}

## Clears the configuration cache
func clear_cache() -> void:
	_config_cache.clear()
	emit_signal("cache_cleared")

## Get a good's icon
## @param good_name: Name of the good
## @return: The good's icon or a fallback icon if not found
func get_good_icon(good_name: String) -> String:
	var goods_data = get_config("goods").get("goods", {})
	return goods_data.get(good_name, {}).get("icon", "❓")

## Get a good's base price
## @param good_name: Name of the good
## @return: The good's base price or 0 if not found
func get_good_base_price(good_name: String) -> int:
	var goods_data = get_config("goods").get("goods", {})
	return goods_data.get(good_name, {}).get("base_price", 0)

## Get a good's category
## @param good_name: Name of the good
## @return: The good's category or empty string if not found
func get_good_category(good_name: String) -> String:
	var goods_data = get_config("goods").get("goods", {})
	return goods_data.get(good_name, {}).get("category", "")

## Get consumption rules for a specific good
## @param good_id: ID of the good to get rules for
## @return: Dictionary containing the consumption rules or empty dict if not found
func get_consumption_rule(good_id: String) -> Dictionary:
	var rules = get_config("consumption_rules").get("consumption_rules", [])
	for rule in rules:
		if rule.get("good_id") == good_id:
			return rule
	return {}

## Get all consumption rules
## @return: Array of all consumption rules
func get_all_consumption_rules() -> Array:
	return get_config("consumption_rules").get("consumption_rules", [])

func get_land_aspects() -> Array:
	var data = _config_cache.get("land_aspects", [])
	if typeof(data) == TYPE_DICTIONARY and data.has("land_aspects"):
		return data["land_aspects"]
	elif typeof(data) == TYPE_ARRAY:
		return data
	else:
		return []

func get_land_aspect_by_id(aspect_id: String) -> Dictionary:
	for aspect in get_land_aspects():
		if aspect.get("aspect_id") == aspect_id:
			return aspect
	return {}

func get_land_aspect_by_good(good: String) -> Dictionary:
	for aspect in get_land_aspects():
		for method in aspect.get("extraction_methods", []):
			if method.get("extracted_good") == good:
				return aspect
	return {}

## Gets all aspect data
## @return Array containing all aspect data
func get_aspect_data() -> Array:
	return get_land_aspects()

## Gets data for a specific aspect by ID
## @param aspect_id: The ID of the aspect to get
## @return Dictionary containing the aspect data, or empty if not found
func get_aspect_by_id(aspect_id: String) -> Dictionary:
	return get_land_aspect_by_id(aspect_id)
#endregion
