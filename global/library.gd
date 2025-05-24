## Global singleton for managing all external data loading and access
##
## Purpose:
##   This class acts as the centralised data loader and cache for all static, referenced data in the game. It loads JSON configuration files, parses them into internal data classes, and provides access to this data for other classes. It ensures that all static data (such as goods, laws, land, people, etc.) is loaded once and made available globally, supporting the closed-loop, data-driven architecture of the game.
##
## Intent:
##   - To provide a single source of truth for all static, referenced data.
##   - To handle loading, parsing, and caching of external JSON data files.
##   - To expose factory methods for instantiating data classes from loaded data.
##   - To emit signals for data load events and errors, supporting decoupled communication.
##   - To support cache clearing and reloading for development and debugging.
##
## Example Usage:
##   # Accessing goods data from anywhere in the project:
##   var all_goods: Array[DataGood] = Library.get_all_goods_data()
##   var grain_icon: String = Library.get_good_icon("grain")
##
##   # Listening for data load events:
##   Library.connect("data_loaded", self, "_on_data_loaded")
##
##   # Clearing the cache (e.g., for hot-reloading during development):
##   Library.clear_cache()
##
## Last Updated: 2002-05-18
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
	"land_aspects": "res://feature/world/data/land_aspects.json",
	"terrain": "res://feature/world/data/terrain.json"
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

var _goods_data_cache: Array[DataGood] = []
#endregion


#region PUBLIC FUNCS
## Gets data for a specific type
## @param data_type: String - The type of data to load (e.g., "people")
## @return Dictionary - Dictionary containing the data. Returns an empty dictionary if not found or on error.
func _get_data(data_type: String) -> Dictionary:
	if not _DATA_FILES.has(data_type):
		var error_msg: String = "Unknown data type: " + data_type
		Logger.error("Unknown data type requested: %s" % data_type, "Library")
		emit_signal("err_data_load_failed", data_type, error_msg)
		push_error(error_msg)
		return {}

	if not _books.has(data_type):
		_load_data_file(data_type)

	return _books[data_type]

## Loads data from file for a given data type.
## @param data_type: String - The type of data to load
## @return void
func _load_data_file(data_type: String) -> void:
	var file_path: String = _DATA_FILES[data_type]
	var full_path: String = file_path

	var file: FileAccess = FileAccess.open(full_path, FileAccess.READ)
	if not file:
		var error_msg: String = "Failed to open file: " + full_path
		Logger.error("Failed to open file for data_type '%s': %s" % [data_type, full_path], "Library")
		emit_signal("err_data_load_failed", data_type, error_msg)
		_set_default_data(data_type)
		Logger.warning("Set default data for '%s' due to file open error." % data_type, "Library")
		return

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(file.get_as_text())
	file.close()

	if parse_result != OK:
		var error_msg: String = "Failed to parse JSON file: " + full_path + ". Error: " + json.get_error_message()
		Logger.error("Failed to parse JSON for data_type '%s': %s | Error: %s" % [data_type, full_path, json.get_error_message()], "Library")
		emit_signal("err_data_load_failed", data_type, error_msg)
		_set_default_data(data_type)
		Logger.warning("Set default data for '%s' due to JSON parse error." % data_type, "Library")
		return

	_books[data_type] = json.get_data()
	Logger.info("Successfully loaded data for '%s' from '%s'" % [data_type, full_path], "Library")
	emit_signal("data_loaded", data_type)

## Sets default data values for a type if loading fails or file is missing.
## @param data_type: String - The type of data to set defaults for
## @return void
func _set_default_data(data_type: String) -> void:
	if _DATA_DEFAULT_VALUES.has(data_type):
		_books[data_type] = _DATA_DEFAULT_VALUES[data_type].duplicate(true)
		Logger.info("Default data set for '%s' from _DATA_DEFAULT_VALUES." % data_type, "Library")
	else:
		_books[data_type] = {}
		Logger.warning("No default data found for '%s'. Set to empty dictionary." % data_type, "Library")

## Clears the data cache, removing all loaded data from memory.
## @return void
func clear_cache() -> void:
	_books.clear()
	Logger.info("Data cache cleared.", "Library")
	emit_signal("cache_cleared")

## Gets the icon for a good by its ID.
## @param good_id: String - ID of the good
## @return String - The good's icon or a fallback icon if not found
func get_good_icon(good_id: String) -> String:
	for good in get_all_goods_data():
		if good.id == good_id:
			return good.icon
	return "❓"

## Gets the base price for a good by its ID.
## @param good_id: String - ID of the good
## @return float - The good's base price or 0.0 if not found
func get_good_base_price(good_id: String) -> float:
	for good in get_all_goods_data():
		if good.id == good_id:
			return good.base_price
	return 0.0

## Gets the category for a good by its ID.
## @param good_id: String - ID of the good
## @return String - The good's category or empty string if not found
func get_good_category(good_id: String) -> String:
	for good in get_all_goods_data():
		if good.id == good_id:
			return good.category
	return ""

## Gets the consumption rule for a specific good.
## @param good_id: String - ID of the good to get rules for
## @return Dictionary - Dictionary containing the consumption rules or empty dict if not found
func get_consumption_rule(good_id: String) -> Dictionary:
	var rules: Array = _get_data("consumption_rules").get("consumption_rules", [])
	for rule in rules:
		if rule.get("good_id") == good_id:
			return rule
	return {}

## Gets all consumption rules.
## @return Array - Array of all consumption rules
func get_all_consumption_rules() -> Array:
	return _get_data("consumption_rules").get("consumption_rules", [])

## Gets all land aspects as DataLandAspect instances.
## @return Array[DataLandAspect] - Array of all land aspects
func get_land_aspects() -> Array[DataLandAspect]:
	return get_all_land_aspects_data()

## Gets a land aspect by its ID.
## @param aspect_id: String - The ID of the aspect to get
## @return DataLandAspect - DataLandAspect instance or null if not found
## @null
func get_land_aspect_by_id(aspect_id: String) -> DataLandAspect:
	for aspect in get_all_land_aspects_data():
		if aspect.aspect_id == aspect_id:
			return aspect
	return null

## Gets a land aspect by the good it produces.
## @param good: String - The good to search for
## @return DataLandAspect - DataLandAspect instance or null if not found
## @null
func get_land_aspect_by_good(good: String) -> DataLandAspect:
	for aspect in get_all_land_aspects_data():
		for method in aspect.get_extraction_methods():
			if method.get("extracted_good") == good:
				return aspect
	return null

## Gets all aspect data as DataLandAspect instances.
## @return Array[DataLandAspect] - Array of all land aspects
func get_aspect_data() -> Array[DataLandAspect]:
	return get_all_land_aspects_data()

## Gets data for a specific aspect by ID.
## @param aspect_id: String - The ID of the aspect to get
## @return DataLandAspect - DataLandAspect instance or null if not found
## @null
func get_aspect_by_id(aspect_id: String) -> DataLandAspect:
	return get_land_aspect_by_id(aspect_id)

## Gets demesne data from cache or file.
## @return Dictionary - Dictionary containing the demesne data
func get_demesne_data() -> Dictionary:
	return _get_data("demesne")

## Gets people data from cache or file.
## @return Dictionary - Dictionary containing the people data
func get_people_data() -> Dictionary:
	return _get_data("people")

## Gets laws data from cache or file.
## @return Dictionary - Dictionary containing the laws data
func get_laws_data() -> Dictionary:
	return _get_data("laws")

## Gets all ancestries data as DataAncestry instances.
## @return Array[DataAncestry] - Array of all ancestries
func get_all_ancestries_data() -> Array[DataAncestry]:
	var ancestries: Array[DataAncestry] = []
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


## Gets all laws data as DataLaw instances.
## @return Array[DataLaw] - Array of all laws
func get_all_laws_data() -> Array[DataLaw]:
	var laws: Array[DataLaw] = []
	var config: Dictionary = _get_data("laws")
	for entry in config.get("laws", []):
		laws.append(DataLaw.new(
			entry.get("id", ""),
			entry.get("name", ""),
			entry.get("description", ""),
			entry.get("category", "")
		))
	return laws

## Gets all land aspects data as DataLandAspect instances.
## @return Array[DataLandAspect] - Array of all land aspects
func get_all_land_aspects_data() -> Array[DataLandAspect]:
	var aspects: Array[DataLandAspect] = []
	var config: Variant = _books.get("land_aspects", [])
	var aspect_list: Array = []
	if typeof(config) == TYPE_DICTIONARY and config.has("land_aspects"):
		aspect_list = config["land_aspects"]
	elif typeof(config) == TYPE_ARRAY:
		aspect_list = config
	for entry in aspect_list:
		aspects.append(DataLandAspect.new(entry))
	return aspects

## Gets the land config data from cache or file.
## @return Dictionary - Dictionary containing the land config
func get_land_data() -> Dictionary:
	return _get_data("land")

## Loads terrain types from terrain.json.
## @return Dictionary - terrain_types dictionary or empty if not found
func get_terrain_types() -> Dictionary:
	var data: Dictionary = _get_data("terrain")
	if data and data.has("terrain_types"):
		return data["terrain_types"]
	return {}
#endregion

#region FACTORY METHODS
## Returns an array of DataGood instances from loaded goods config.
## @return Array[DataGood] - Array of all goods as DataGood instances
func get_all_goods_data() -> Array[DataGood]:
	if _goods_data_cache.size() > 0:
		return _goods_data_cache
	var goods: Array[DataGood] = []
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

## Returns an array of DataCulture instances from loaded cultures config.
## @return Array[DataCulture] - Array of all cultures as DataCulture instances
func get_all_cultures_data() -> Array[DataCulture]:
	var cultures: Array[DataCulture] = []
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

#region PRIVATE FUNCTIONS
#endregion
