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
	"people": "people_config.json"
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
	}
}
#endregion


#region PUBLIC FUNCS
## Loads and caches JSON data from a file
## @param file_path: Path to the JSON file relative to DATA_PATH
## @return: Dictionary containing the parsed JSON data
func load_json(file_path: String) -> Dictionary:
	if _config_cache.has(file_path):
		emit_signal("config_loaded", file_path)
		return _config_cache[file_path]

	var full_path: String = DATA_PATH + file_path
	var file: FileAccess = FileAccess.open(full_path, FileAccess.READ)
	if not file:
		var error_msg: String = "Failed to open file: " + full_path
		emit_signal("err_config_load_failed", file_path, error_msg)
		push_error(error_msg)
		return {}

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(file.get_as_text())
	file.close()

	if parse_result != OK:
		var error_msg: String = "Failed to parse JSON file: " + full_path
		emit_signal("err_config_load_failed", file_path, error_msg)
		push_error(error_msg)
		return {}

	var data: Dictionary = json.get_data()
	_config_cache[file_path] = data
	emit_signal("config_loaded", file_path)
	return data

## Clears the configuration cache
func clear_cache() -> void:
	_config_cache.clear()
	emit_signal("cache_cleared")
#endregion
