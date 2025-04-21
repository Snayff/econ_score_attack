## DataGoods
## Manages goods-related configuration data
## Handles loading and accessing goods configuration
#@icon("")
class_name DataGoods
extends Node


#region SIGNALS
signal config_loaded
signal err_config_load_failed(error: String)
#endregion


#region VARS
## The loaded configuration data from the JSON file
var _config: Dictionary = {}

## The type of configuration this class handles
const _CONFIG_TYPE: String = "goods"
#endregion


#region FUNCS
func _init() -> void:
	_load_config()

## Loads the goods configuration from the Library
func _load_config() -> void:
	_config = Library.get_config(_CONFIG_TYPE)
	if _config.is_empty():
		emit_signal("err_config_load_failed", "Failed to load goods configuration")
		return
	emit_signal("config_loaded")

## Returns the good prices from the configuration
## @return A dictionary mapping good names to their prices
func get_good_prices() -> Dictionary:
	return _config.get("good_prices", {})
#endregion 