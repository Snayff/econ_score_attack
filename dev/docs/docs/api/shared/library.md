# Library

## Last Updated
2025-06-23

## Table of Contents
- [Overview](#overview)
- [Class Hierarchy](#class-hierarchy)
- [Constants](#constants)
- [Signals](#signals)
- [Methods](#methods)
- [Usage Examples](#usage-examples)
- [See Also](#see-also)

## Overview
Global singleton for managing all external data loading and access. This class acts as the centralized data loader and cache for all static, referenced data in the game. It loads JSON configuration files, parses them into internal data class arrays, and provides access to this data for other classes.

## Class Hierarchy
- **Extends:** Node
- **Extended by:** None
- **Used by:** All systems requiring access to configuration data

## Constants
| Name | Description |
|------|-------------|
| _DATA_FILES | Dictionary mapping data types to file paths |
| _DATA_DEFAULT_VALUES | Dictionary of default values by data type |

## Signals
| Name | Parameters | Description |
|------|------------|-------------|
| data_loaded | data_type: String | Emitted when data is successfully loaded |
| err_data_load_failed | data_type: String, error: String | Emitted when data loading fails |
| cache_cleared | None | Emitted when the cache is cleared |

## Methods
### clear_cache() -> void
Clears the cached data for all data types and emits the cache_cleared signal.

### get_all_goods_data() -> Array[DataGood]
Returns an array of all goods data.

**Returns:** Array of DataGood instances

### get_good_icon(good_id: String) -> String
Returns the icon string for a given good by its ID.

**Parameters:**
- `good_id`: The unique identifier of the good

**Returns:** The icon associated with the good, or '❓' if not found

### get_good_base_price(good_id: String) -> float
Returns the base price for a given good by its ID.

**Parameters:**
- `good_id`: The unique identifier of the good

**Returns:** The base price of the good, or 0.0 if not found

### get_good_category(good_id: String) -> String
Returns the category for a given good by its ID.

**Parameters:**
- `good_id`: The unique identifier of the good

**Returns:** The category of the good, or an empty string if not found

### get_good_by_id(good_id: String) -> DataGood
Returns the DataGood instance for a given good ID.

**Parameters:**
- `good_id`: The unique identifier of the good

**Returns:** The data class instance for the good, or null if not found

### get_all_laws_data() -> Array[DataLaw]
Returns an array of all laws data.

**Returns:** Array of DataLaw instances

### get_law_by_id(law_id: String) -> DataLaw
Returns the DataLaw instance for a given law ID.

**Parameters:**
- `law_id`: The unique identifier of the law

**Returns:** The data class instance for the law, or null if not found

### get_all_ancestries_data() -> Array[DataAncestry]
Returns an array of all ancestries data.

**Returns:** Array of DataAncestry instances

### get_ancestry_by_id(ancestry_id: String) -> DataAncestry
Returns the DataAncestry instance for a given ancestry ID.

**Parameters:**
- `ancestry_id`: The unique identifier of the ancestry

**Returns:** The data class instance for the ancestry, or null if not found

### get_all_cultures_data() -> Array[DataCulture]
Returns an array of all cultures data.

**Returns:** Array of DataCulture instances

### get_culture_by_id(culture_id: String) -> DataCulture
Returns the DataCulture instance for a given culture ID.

**Parameters:**
- `culture_id`: The unique identifier of the culture

**Returns:** The data class instance for the culture, or null if not found

### get_all_land_aspects_data() -> Array[DataLandAspect]
Returns an array of all land aspects data.

**Returns:** Array of DataLandAspect instances

### get_land_aspect_by_id(aspect_id: String) -> DataLandAspect
Returns the DataLandAspect instance for a given aspect ID.

**Parameters:**
- `aspect_id`: The unique identifier of the land aspect

**Returns:** The data class instance for the land aspect, or null if not found

### get_land_aspect_by_good(good: String) -> DataLandAspect
Returns the DataLandAspect instance associated with a given good, if any extraction method matches.

**Parameters:**
- `good`: The unique identifier of the good to search for

**Returns:** The data class instance for the land aspect that can extract the good, or null if not found

### get_all_demesne_data() -> Dictionary
Returns all demesne configuration data.

**Returns:** Dictionary containing demesne configuration

### get_all_people_data() -> Dictionary
Returns all people configuration data.

**Returns:** Dictionary containing people configuration

### get_consumption_rule(good_id: String) -> Dictionary
Returns the consumption rule for a specific good.

**Parameters:**
- `good_id`: The unique identifier of the good

**Returns:** Dictionary containing the consumption rule, or empty dictionary if not found

### get_all_consumption_rules() -> Array
Returns all consumption rules.

**Returns:** Array of consumption rule dictionaries

### get_all_land_data() -> Dictionary
Returns all land configuration data.

**Returns:** Dictionary containing land configuration

### get_all_terrain_type_data() -> Dictionary
Returns all terrain type data.

**Returns:** Dictionary mapping terrain type IDs to their configuration

### get_all_sub_views_data(view_key: int) -> Array[DataSubView]
Loads and returns all sub view definitions for a given feature.

**Parameters:**
- `view_key`: The main view's enum key (e.g., Constants.VIEW_KEY.PEOPLE)

**Returns:** Array of DataSubView instances for the feature, or empty array on error

## Usage Examples
```gdscript
# Get all goods data
var goods = Library.get_all_goods_data()
print("Number of goods: %d" % goods.size())

# Get a specific good by ID
var grain = Library.get_good_by_id("grain")
if grain:
    print("Grain base price: %f" % grain.base_price)

# Get all consumption rules
var rules = Library.get_all_consumption_rules()
for rule in rules:
    print("Consumption rule for %s: min=%d, desired=%d" % [
        rule.good_id, 
        rule.min_consumption_amount, 
        rule.desired_consumption_amount
    ])

# Listen for data loading events
Library.connect("data_loaded", self, "_on_data_loaded")

# Clear the cache (e.g., for hot-reloading during development)
Library.clear_cache()
```
## See Also

- [DataGood](./data_good.md)
- [DataCulture](./data_culture.md)
- [DataAncestry](./data_ancestry.md)
- [DataLaw](./data_law.md)
- [DataLandAspect](./data_land_aspect.md)
- [Economic Actor Decision System](../systems/economic_actor_decision_system.md)
- [Market System](../systems/market_system.md)
