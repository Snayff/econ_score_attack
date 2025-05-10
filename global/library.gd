## Global singleton for managing all external data loading and access
## Handles JSON configuration files and provides centralised data access
## @icon("")
extends Node


#region SIGNALS
signal data_loaded(data_type: String)
signal err_data_load_failed(data_type: String, error: String)
signal cache_cleared
#endregion


#region ON READY
func _ready() -> void:
	_load_data_file("goods")
	_load_data_file("consumption_rules")
	_load_data_file("laws")
	_load_data_file("land")
	_load_data_file("land_aspects")
#endregion


#region EXPORTS
#endregion


#region VARS
## Cache of loaded data by type. Each data file is a "book".
var _books: Dictionary = {}

## Data file paths by type
const _DATA_FILES: Dictionary = {
	"people": "res://feature/economic_actor/data/people.json",
	"cultures": "res://feature/economic_actor/data/cultures.json",
	"ancestries": "res://feature/economic_actor/data/ancestries.json",
	"demesne": "res://feature/demesne/data/demesne.json",
	"goods": "res://feature/economy/market/data/goods.json",
	"consumption_rules": "res://feature/economic_actor/data/consumption_rules.json",
	"laws": "res://feature/law/data/laws.json",
	"land": "res://feature/world/data/land_config.json",
	"land_aspects": "res://feature/world/data/land_aspects.json"
}

## Default values by data type
const _DATA_DEFAULT_VALUES: Dictionary = {
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


#endregion


#region PUBLIC FUNCS
## Gets data for a specific type
## @param data_type: The type of data to load (e.g., "people")
## @return: Dictionary containing the data
func _get_data(data_type: String) -> Dictionary:
	if not _DATA_FILES.has(data_type):
		var error_msg: String = "Unknown data type: " + data_type
		emit_signal("err_data_load_failed", data_type, error_msg)
		push_error(error_msg)
		return {}

	if not _books.has(data_type):
		_load_data_file(data_type)

	return _books[data_type]

## Loads data from file
## @param data_type: The type of data to load
func _load_data_file(data_type: String) -> void:
	var file_path: String = _DATA_FILES[data_type]
	var full_path: String = file_path

	var file: FileAccess = FileAccess.open(full_path, FileAccess.READ)
	if not file:
		var error_msg: String = "Failed to open file: " + full_path
		emit_signal("err_data_load_failed", data_type, error_msg)
		push_error(error_msg)
		_set_default_data(data_type)
		return

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(file.get_as_text())
	file.close()

	if parse_result != OK:
		var error_msg: String = "Failed to parse JSON file: " + full_path
		emit_signal("err_data_load_failed", data_type, error_msg)
		push_error(error_msg)
		_set_default_data(data_type)
		return

	_books[data_type] = json.get_data()
	emit_signal("data_loaded", data_type)

## Sets default data values for a type
## @param data_type: The type of data to set defaults for
func _set_default_data(data_type: String) -> void:
	if _DATA_DEFAULT_VALUES.has(data_type):
		_books[data_type] = _DATA_DEFAULT_VALUES[data_type].duplicate(true)
	else:
		_books[data_type] = {}

## Clears the data cache
func clear_cache() -> void:
	_books.clear()
	emit_signal("cache_cleared")

## Get a good's icon
## @param good_id: ID of the good
## @return: The good's icon or a fallback icon if not found
func get_good_icon(good_id: String) -> String:
	for good in get_all_goods_data():
		if good.id == good_id:
			return good.icon
	return "❓"

## Get a good's base price
## @param good_id: ID of the good
## @return: The good's base price or 0 if not found
func get_good_base_price(good_id: String) -> float:
	for good in get_all_goods_data():
		if good.id == good_id:
			return good.base_price
	return 0.0

## Get a good's category
## @param good_id: ID of the good
## @return: The good's category or empty string if not found
func get_good_category(good_id: String) -> String:
	for good in get_all_goods_data():
		if good.id == good_id:
			return good.category
	return ""

## Get consumption rules for a specific good
## @param good_id: ID of the good to get rules for
## @return: Dictionary containing the consumption rules or empty dict if not found
func get_consumption_rule(good_id: String) -> Dictionary:
	var rules = _get_data("consumption_rules").get("consumption_rules", [])
	for rule in rules:
		if rule.get("good_id") == good_id:
			return rule
	return {}

## Get all consumption rules
## @return: Array of all consumption rules
func get_all_consumption_rules() -> Array:
	return _get_data("consumption_rules").get("consumption_rules", [])

func get_land_aspects() -> Array:
	var data = _books.get("land_aspects", [])
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

## Gets demesne data
## @return Dictionary containing the demesne data
func get_demesne_data() -> Dictionary:
	return _get_data("demesne")

## Gets people data
## @return Dictionary containing the people data
func get_people_data() -> Dictionary:
	return _get_data("people")

## Gets laws data
## @return Dictionary containing the laws data
func get_laws_data() -> Dictionary:
	return _get_data("laws")

## Gets all ancestries data
## @return Array of all ancestries
func get_all_ancestries_data() -> Array:
	var ancestries: Array = []
	var config: Dictionary = _get_data("ancestries")
	if not config.has("ancestries"):
		push_error("Ancestries config missing 'ancestries' key.")
		return ancestries
	for entry in config["ancestries"]:
		if not entry.has("id") or not entry.has("possible_names") or not entry.has("savings_rate_range") or not entry.has("decision_profiles") or not entry.has("shock_response") or not entry.has("consumption_rule_ids"):
			push_error("Invalid ancestry entry: " + str(entry))
			continue
		ancestries.append(DataAncestry.new(
			entry["id"],
			entry["possible_names"],
			entry["savings_rate_range"],
			entry["decision_profiles"],
			entry["shock_response"],
			entry["consumption_rule_ids"]
		))
	return ancestries

## Gets the land config data
## @return Dictionary containing the land config
func get_land_data() -> Dictionary:
	return _get_data("land")
#endregion

#region FACTORY METHODS
var _goods_data_cache: Array = []

## Returns an array of DataGood instances from loaded goods config
## @return Array[DataGood]
func get_all_goods_data() -> Array:
	if _goods_data_cache.size() > 0:
		return _goods_data_cache
	var goods: Array = []
	var config: Dictionary = _get_data("goods")
	if not config.has("goods"):
		push_error("Goods config missing 'goods' key.")
		return goods
	for entry in config["goods"]:
		if not entry.has("id") or not entry.has("f_name") or not entry.has("base_price") or not entry.has("category"):
			push_error("Invalid good entry: " + str(entry))
			continue
		goods.append(DataGood.new(
			entry["id"],
			entry["f_name"],
			entry["base_price"],
			entry["category"],
			entry.get("icon", "❓")
		))
	_goods_data_cache = goods
	return goods

## Returns an array of DataCulture instances from loaded cultures config
## @return Array[DataCulture]
func get_all_cultures_data() -> Array:
	var cultures: Array = []
	var config: Dictionary = _get_data("cultures")
	if not config.has("cultures"):
		push_error("Culture config missing 'cultures' key.")
		return cultures
	for entry in config["cultures"]:
		if not entry.has("id") or not entry.has("possible_names") or not entry.has("savings_rate_range") or not entry.has("decision_profiles") or not entry.has("shock_response") or not entry.has("consumption_rule_ids"):
			push_error("Invalid culture entry: " + str(entry))
			continue
		cultures.append(DataCulture.new(
			entry["id"],
			entry["possible_names"],
			entry["savings_rate_range"],
			entry["decision_profiles"],
			entry["shock_response"],
			entry["consumption_rule_ids"]
		))
	return cultures
#endregion
