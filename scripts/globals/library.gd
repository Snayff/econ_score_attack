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
#endregion


#region EXPORTS
#endregion


#region VARS
## Cache of loaded configuration data by type
var _config_cache: Dictionary = {}

## Base path for all data files
const DATA_PATH: String = "res://data/"

## Configuration file paths by type
const _CONFIG_FILES: Dictionary = {
	"people": "people_config.json",
	"demesne": "demesne_config.json"
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
	}
}
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
	var full_path: String = DATA_PATH + file_path

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
#endregion
