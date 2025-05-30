# Library System Documentation

## Purpose and Intent

The `Library` system is a global autoload singleton responsible for loading, caching, and providing access to all static, external data used throughout the game. It centralises the management of configuration files (such as goods, laws, land, and aspects), ensuring that all data-driven systems have a single, authoritative source for their configuration and reference data. This supports the game's data-driven architecture, modularity, and scalability.

## Design

- **Centralised Data Access:** Implemented as an autoload singleton (`globals/library.gd`), the Library ensures all static data is loaded once and made available to any system or feature that requires it.
- **External JSON Files:** All static data is stored in external JSON files, referenced by type. The Library loads these files at runtime and caches their contents for efficient access.
- **Signal-Based Error Handling:** Emits signals when configuration files are loaded or if loading fails, allowing other systems to respond to data availability or errors.
- **Default Fallbacks:** If a configuration file cannot be loaded, the Library provides sensible default values to ensure the game remains functional.
- **Data Caching:** Loaded data is cached in memory to avoid repeated file I/O and improve performance.

## Architecture

The Library acts as the central data provider for all systems that require static configuration or reference data. All external JSON files are loaded and cached by the Library, which then serves this data to other systems via its API and signals. No other system should load config files directly.

```
+-------------------+         +-------------------+
|  goods.json       |         |  laws.json        |
|  land.json        |         |  ...etc           |
+-------------------+         +-------------------+
         |                             |
         |   (loads at startup)        |
         +-------------+---------------+
                       |
                       v
              +----------------+
              |    Library     |
              |  (autoload)    |
              +----------------+
                       |
         +-------------+-------------+-------------+
         |             |             |             |
         v             v             v             v
   LandManager   AspectManager   UI Systems   Other Systems
```

The diagram above shows how the Library loads all static data from external files and provides it to all other systems in the game. All data-driven systems must access configuration and reference data exclusively through the Library.

## Usage

- Access the Library via the autoload singleton `Library`.
- Retrieve configuration data using:
  - `Library.get_config(config_type: String) -> Dictionary`
- Listen for signals:
  - `config_loaded(config_type: String)` — Emitted when a config is successfully loaded.
  - `err_config_load_failed(config_type: String, error: String)` — Emitted when loading fails.
  - `cache_cleared` — Emitted when the cache is cleared.
- Example:

```gdscript
var goods_data = Library.get_config("goods")
if goods_data.has("grain"):
    var grain_info = goods_data["grain"]
```

## Data Schema

- **Config Types:**
  - `people`, `demesne`, `goods`, `consumption_rules`, `laws`, `land`, `land_aspects`
- **File Paths:**
  - Each config type maps to a file path, e.g., `feature/economy/data/goods.json` for goods.
- **Cache:**
  - All loaded configs are stored in a cache dictionary, keyed by config type.
- **Default Values:**
  - If a config cannot be loaded, default values are provided for core types (e.g., land grid size, terrain types).

## Extending the System

- To add a new config type, update the `_CONFIG_FILES` dictionary in `library.gd` with the new type and file path.
- Ensure the corresponding JSON file exists and follows the expected schema.
- Use the Library's public methods to access new data types throughout the project.

## Example

```gdscript
# Get the icon for a good
var icon = Library.get_good_icon("grain")

# Get the base price for a good
var price = Library.get_good_base_price("wood")

# Listen for config loaded signal
Library.connect("config_loaded", Callable(self, "_on_config_loaded"))
```

## Developer Notes

- The Library should be the only source for static, referenced data in the game. Do not load config files directly elsewhere.
- All data-driven systems (e.g., land, goods, laws) should use the Library for their configuration needs.
- The Library is designed to be stateless beyond its cache; it does not modify or persist data.
- Error handling is robust: failures to load config files are signalled and logged, and default values are provided where possible.
- The Library supports future extensibility by allowing new config types and schemas to be added with minimal changes.

## Associated File
- `globals/library.gd` (autoload singleton)

## Last Updated
2025-05-04 