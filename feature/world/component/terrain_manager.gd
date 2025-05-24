## TerrainManager: Handles loading and querying of terrain types for the World.
##
## Purpose and Intent:
## - Centralised Terrain Management: Acts as the single source of truth for all terrain type definitions in the game. Terrains are the base physical types for parcels (e.g., plains, forest, mountains).
## - Data Loading and Validation: Loads terrain definitions from the external data source (via the Library autoload, which handles JSON/static data), ensuring all terrain data is consistent and up-to-date.
## - Terrain Querying: Offers methods to retrieve all terrain types, a specific terrain definition by its unique ID, and to pick a random terrain type for procedural world generation.
## - Error Handling and Logging: Includes error handling (e.g., warnings if no terrain types are found) and logs events for debugging and monitoring.
##
## Example Usage:
##   var tm = TerrainManager.new()
##   tm.initialise_from_config(config)
##   var terrain = tm.get_random_terrain_type()
##   var all_terrains = tm.get_all_terrain_types()
##   var terrain_def = tm.get_terrain_definition("plains")
##
## Last Updated: 2025-05-18
class_name TerrainManager
extends Node

#region VARS
var _terrain_types: Dictionary = {}
var _terrain_loader: Callable = Callable()
#endregion

#region PUBLIC FUNCTIONS
## Initialises the TerrainManager from the provided config dictionary.
## Loads terrain types from config if present, otherwise from Library.
## @param config (Dictionary): The configuration dictionary passed from World.
## @return void
func initialise_from_config(config: Dictionary) -> void:
	if config.has("terrain_types"):
		_terrain_types = config["terrain_types"]
		Logger.log_event("terrain_types_loaded", {"count": _terrain_types.size(), "source": "config"}, "TerrainManager")
	elif not _terrain_loader.is_null():
		_terrain_types = _terrain_loader.call()
		Logger.log_event("terrain_types_loaded", {"count": _terrain_types.size(), "source": "custom_loader"}, "TerrainManager")
	else:
		_terrain_types = Library.get_all_terrain_type_data()
		Logger.log_event("terrain_types_loaded", {"count": _terrain_types.size(), "source": "library"}, "TerrainManager")
	if _terrain_types.is_empty():
		push_warning("No terrain types found in config, Library, or via loader")
		_terrain_types = {}

## Gets a terrain definition by ID.
## @param terrain_id (String): The ID of the terrain to get.
## @return Dictionary: The terrain definition, or empty dictionary if not found.
func get_terrain_definition(terrain_id: String) -> Dictionary:
	return _terrain_types.get(terrain_id, {})

## Gets all terrain types.
## @return Dictionary: All terrain types currently loaded.
func get_all_terrain_types() -> Dictionary:
	return _terrain_types.duplicate()

## Picks a random terrain type ID from the loaded terrain types.
## @return String: The ID of a random terrain type, or empty string if none loaded.
func get_random_terrain_type() -> String:
	var keys = _terrain_types.keys()
	if keys.is_empty():
		return ""
	return keys[randi() % keys.size()]

## Sets the terrain loader function.
## @param loader_func (Callable): Callable that returns a Dictionary of terrain types.
## @return void
func set_terrain_loader(loader_func: Callable) -> void:
	_terrain_loader = loader_func
	# Optionally reload terrain types
	initialise_from_config({})
#endregion
