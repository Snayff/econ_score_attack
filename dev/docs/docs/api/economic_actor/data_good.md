# DataGood

## Last Updated: 2025-06-25

## Table of Contents
- [Overview](#overview)
- [Class Hierarchy](#class-hierarchy)
- [Properties](#properties)
- [Methods](#methods)
- [Usage Examples](#usage-examples)
- [Error Handling](#error-handling)
- [See Also](#see-also)

## Overview
The `DataGood` class is a data class representing a static configuration for a good in the economy. It holds the unique ID, display name, base price, and category for a good.

## Class Hierarchy
- **Extends:** Reference
- **Extended by:** None
- **Used by:** GoodsManager, Market system

## Properties
| Name | Type | Description |
|------|------|-------------|
| id | String | Unique string ID for the good |
| f_name | String | Display name for the good |
| base_price | float | The base price of the good |
| category | String | The category of the good (e.g., basic, luxury) |

## Methods
### static load_all_from_json() -> Array
Loads all goods from the external JSON config using `Library.get_config`.

**Returns:** Array of `DataGood` instances

## Usage Examples
```gdscript
# Create a new good configuration
var good = DataGood.new("food", "Food", 10.0, "basic")
print("Good: %s, Price: %.2f" % [good.f_name, good.base_price])

# Load all goods from JSON configuration
var all_goods = DataGood.load_all_from_json()
for good in all_goods:
    print("Loaded good: %s (%s), Base price: %.2f, Category: %s" % [
        good.f_name,
        good.id,
        good.base_price,
        good.category
    ])
```

## Error Handling
- If the JSON config is missing or invalid, errors are logged and an empty array is returned.

## See Also
- [Good](../economy/market/good.md)
- [GoodsManager](../economy/market/goods_manager.md)
- [Library](../shared/library.md)
- [Market System](../systems/market_system.md)
