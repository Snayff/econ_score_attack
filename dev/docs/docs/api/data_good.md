# DataGood API

## Last Updated: 2025-05-05

## Overview
`DataGood` is a data class representing a static configuration for a good in the economy. It holds the unique ID, display name, base price, and category for a good.

## Usage Example
```gdscript
var good = DataGood.new("food", "Food", 10.0, "basic")
```

## Properties
- `id: String` — Unique string ID for the good.
- `f_name: String` — Display name for the good.
- `base_price: float` — The base price of the good.
- `category: String` — The category of the good (e.g., basic, luxury).

## Methods
- `static func load_all_from_json() -> Array` — Loads all goods from the external JSON config using `Library.get_config`. Returns an array of `DataGood` instances.

## Error Handling
- If the JSON config is missing or invalid, errors are logged and an empty array is returned. 