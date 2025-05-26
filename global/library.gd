## Global singleton for managing all external data loading and access
##
## Purpose:
##   This class acts as the centralised data loader and cache for all static, referenced data in the game. It loads JSON configuration files, parses them into internal data class arrays, and provides access to this data for other classes. It ensures that all static data (such as goods, laws, land, people, etc.) is loaded once and made available globally, supporting the closed-loop, data-driven architecture of the game.
##
## Data Handling:
##   - All structured data is loaded from JSON files, parsed into strongly-typed data class arrays, and cached in the `_books` dictionary.
##   - All access to structured data is through cached data class arrays (via `get_all_*` functions) or single-item accessors (via `get_*_by_id` functions).
##   - Flat or config data is stored as dictionaries in `_books`.
##   - Cache is automatically invalidated and rebuilt when the underlying data file is reloaded or the cache is cleared.
##
## Intent:
##   - To provide a single source of truth for all static, referenced data.
##   - To handle loading, parsing, and caching of external JSON data files.
##   - To expose factory methods for instantiating data classes from loaded data.
##   - To emit signals for data load events and errors, supporting decoupled communication.
##   - To support cache clearing and reloading for development and debugging.
##
## Example Usage:
##   var all_goods: Array[DataGood] = Library.get_all_goods_data()
##   var grain: DataGood = Library.get_good_by_id("grain")
##
##   # Listening for data load events:
##   Library.connect("data_loaded", self, "_on_data_loaded")
##
##   # Clearing the cache (e.g., for hot-reloading during development):
##   Library.clear_cache()
##
## Last Updated: 2025-05-24

extends Node


#region CONSTANTS
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
	"terrain": "res://feature/world/data/terrain.json",
	"people_sub_views": "res://feature/economic_actor/data/people_sub_views.json"
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
#endregion


#region PUBLIC FUNCTIONS
# --- Cache Management ---
### Clears the cached data for all data types and emits the cache_cleared signal.
###
### Removes all loaded and parsed data from the _books dictionary. Emits the 'cache_cleared' signal to notify listeners.
### Useful for hot-reloading during development or when a full data refresh is required.
### @return void
func clear_cache() -> void:
	_books.clear()
	Logger.info("Data cache cleared.", "Library")
	emit_signal("cache_cleared")

# --- Data Access: Goods ---
func get_all_goods_data() -> Array[DataGood]:
	if _books.has("goods_data"):
		return _books["goods_data"]
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
	_books["goods_data"] = goods
	return goods

### Returns the icon string for a given good by its ID.
###
### @param good_id String: The unique identifier of the good.
### @return String: The icon associated with the good, or '❓' if not found.
func get_good_icon(good_id: String) -> String:
	for good in get_all_goods_data():
		if good.id == good_id:
			return good.icon
	return "❓"

### Returns the base price for a given good by its ID.
###
### @param good_id String: The unique identifier of the good.
### @return float: The base price of the good, or 0.0 if not found.
func get_good_base_price(good_id: String) -> float:
	for good in get_all_goods_data():
		if good.id == good_id:
			return good.base_price
	return 0.0

### Returns the category for a given good by its ID.
###
### @param good_id String: The unique identifier of the good.
### @return String: The category of the good, or an empty string if not found.
func get_good_category(good_id: String) -> String:
	for good in get_all_goods_data():
		if good.id == good_id:
			return good.category
	return ""

### Returns the DataGood instance for a given good ID.
###
### @param good_id String: The unique identifier of the good.
### @return DataGood: The data class instance for the good, or null if not found.
### @null
func get_good_by_id(good_id: String) -> DataGood:
	for good in get_all_goods_data():
		if good.id == good_id:
			return good
	return null

# --- Data Access: Laws ---
func get_all_laws_data() -> Array[DataLaw]:
	if _books.has("laws_data"):
		return _books["laws_data"]
	var laws: Array[DataLaw] = []
	var config: Dictionary = _get_data("laws")
	for entry in config.get("laws", []):
		laws.append(DataLaw.new(
			entry.get("id", ""),
			entry.get("name", ""),
			entry.get("description", ""),
			entry.get("category", "")
		))
	_books["laws_data"] = laws
	return laws

func get_law_by_id(law_id: String) -> DataLaw:
	for law in get_all_laws_data():
		if law.id == law_id:
			return law
	return null

# --- Data Access: Ancestries ---
func get_all_ancestries_data() -> Array[DataAncestry]:
	if _books.has("ancestries_data"):
		return _books["ancestries_data"]
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
	_books["ancestries_data"] = ancestries
	return ancestries

### Returns the DataAncestry instance for a given ancestry ID.
###
### @param ancestry_id String: The unique identifier of the ancestry.
### @return DataAncestry: The data class instance for the ancestry, or null if not found.
### @null
func get_ancestry_by_id(ancestry_id: String) -> DataAncestry:
	for ancestry in get_all_ancestries_data():
		if ancestry.id == ancestry_id:
			return ancestry
	return null

# --- Data Access: Cultures ---
func get_all_cultures_data() -> Array[DataCulture]:
	if _books.has("cultures_data"):
		return _books["cultures_data"]
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
	_books["cultures_data"] = cultures
	return cultures

### Returns the DataCulture instance for a given culture ID.
###
### @param culture_id String: The unique identifier of the culture.
### @return DataCulture: The data class instance for the culture, or null if not found.
### @null
func get_culture_by_id(culture_id: String) -> DataCulture:
	for culture in get_all_cultures_data():
		if culture.id == culture_id:
			return culture
	return null

# --- Data Access: Land Aspects ---
func get_all_land_aspects_data() -> Array[DataLandAspect]:
	if _books.has("land_aspects_data"):
		return _books["land_aspects_data"]
	var aspects: Array[DataLandAspect] = []
	var config: Variant = _books.get("land_aspects", [])
	var aspect_list: Array = []
	if typeof(config) == TYPE_DICTIONARY and config.has("land_aspects"):
		aspect_list = config["land_aspects"]
	elif typeof(config) == TYPE_ARRAY:
		aspect_list = config
	for entry in aspect_list:
		aspects.append(DataLandAspect.new(entry))
	_books["land_aspects_data"] = aspects
	return aspects


### Returns the DataLandAspect instance for a given aspect ID.
###
### @param aspect_id String: The unique identifier of the land aspect.
### @return DataLandAspect: The data class instance for the land aspect, or null if not found.
### @null
func get_land_aspect_by_id(aspect_id: String) -> DataLandAspect:
	for aspect in get_all_land_aspects_data():
		if aspect.aspect_id == aspect_id:
			return aspect
	return null

### Returns the DataLandAspect instance associated with a given good, if any extraction method matches.
###
### @param good String: The unique identifier of the good to search for.
### @return DataLandAspect: The data class instance for the land aspect that can extract the good, or null if not found.
### @null
func get_land_aspect_by_good(good: String) -> DataLandAspect:
	for aspect in get_all_land_aspects_data():
		for method in aspect.get_extraction_methods():
			if method.get("extracted_good") == good:
				return aspect
	return null

# --- Data Access: Demesne ---
func get_all_demesne_data() -> Dictionary:
	return _get_data("demesne")

# --- Data Access: People ---
func get_all_people_data() -> Dictionary:
	return _get_data("people")

# --- Data Access: Consumption Rules ---
func get_consumption_rule(good_id: String) -> Dictionary:
	var rules: Array = _get_data("consumption_rules").get("consumption_rules", [])
	for rule in rules:
		if rule.get("good_id") == good_id:
			return rule
	return {}

func get_all_consumption_rules() -> Array:
	return _get_data("consumption_rules").get("consumption_rules", [])

# --- Data Access: Land ---
func get_all_land_data() -> Dictionary:
	return _get_data("land")

# --- Data Access: Terrain ---
func get_all_terrain_type_data() -> Dictionary:
	var data: Dictionary = _get_data("terrain")
	if data and data.has("terrain_types"):
		return data["terrain_types"]
	return {}

## Loads and returns all sub view definitions for a given feature.
## @param view_key (Constants.VIEW_KEY): The main view's enum key (e.g., Constants.VIEW_KEY.PEOPLE).
## @return Array[DataSubView]: Array of DataSubView instances for the feature, or empty array on error.
func get_all_sub_views_data(view_key: int) -> Array[DataSubView]:
	var view_key_str = Constants.VIEW_KEY_ENUM_TO_KEY.get(view_key, null)
	if view_key_str == null:
		push_error("Invalid VIEW_KEY enum value: %s" % str(view_key))
		return []
	var cache_key = "sub_views_data_%s" % view_key_str
	if _books.has(cache_key):
		return _books[cache_key]
	var sub_views: Array[DataSubView] = []
	var config: Dictionary = _get_data("%s_sub_views" % view_key_str)
	if not config.has(view_key_str):
		push_error("Sub views config missing '%s' key." % view_key_str)
		return sub_views
	for entry in config[view_key_str]:
		if not entry.has("id") or not entry.has("label") or not entry.has("icon") or not entry.has("tooltip") or not entry.has("scene_path"):
			push_error("Invalid sub view entry: %s" % str(entry))
			continue
		var sub_view_key = Constants.SUB_VIEW_KEY_TO_ENUM.get(entry["id"], null)
		if sub_view_key == null:
			push_error("No enum mapping for sub view id: %s" % entry["id"])
			sub_view_key = -1
		sub_views.append(DataSubView.new(
			entry["id"],
			entry["label"],
			entry["icon"],
			entry["tooltip"],
			entry["scene_path"],
			sub_view_key
		))
	_books[cache_key] = sub_views
	return sub_views
#endregion


#region PRIVATE FUNCTIONS
### Returns the loaded data dictionary for a given data type, loading it if necessary.
###
### @param data_type String: The type of data to retrieve (e.g., 'goods', 'laws').
### @return Dictionary: The loaded data for the requested type, or an empty dictionary if not found or on error.
### @null
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


### Loads and parses the external JSON data file for the specified data type, caching the result.
###
### @param data_type String: The type of data to load (e.g., 'goods', 'laws').
### If the file cannot be opened or parsed, sets default data and emits an error signal. On success, caches the loaded data and emits the 'data_loaded' signal.
### @return void
func _load_data_file(data_type: String) -> void:
	if data_type == "goods":
		_books.erase("goods_data")
	if data_type == "ancestries":
		_books.erase("ancestries_data")
	if data_type == "cultures":
		_books.erase("cultures_data")
	if data_type == "laws":
		_books.erase("laws_data")
	if data_type == "land_aspects":
		_books.erase("land_aspects_data")
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

### Sets the default data for a given data type in the cache, using _DATA_DEFAULT_VALUES if available.
###
### @param data_type String: The type of data to set default values for.
### If no default is found, sets an empty dictionary and logs a warning.
### @return void
func _set_default_data(data_type: String) -> void:
	if _DATA_DEFAULT_VALUES.has(data_type):
		_books[data_type] = _DATA_DEFAULT_VALUES[data_type].duplicate(true)
		Logger.info("Default data set for '%s' from _DATA_DEFAULT_VALUES." % data_type, "Library")
	else:
		_books[data_type] = {}
		Logger.warning("No default data found for '%s'. Set to empty dictionary." % data_type, "Library")
#endregion
