# GoodsManager

## Last Updated: 2025-06-25

## Table of Contents
- [Overview](#overview)
- [Class Hierarchy](#class-hierarchy)
- [Methods](#methods)
- [Usage Examples](#usage-examples)
- [See Also](#see-also)

## Overview
The `GoodsManager` class manages all goods in the economy, providing access to loaded `DataGood` instances and utility functions. It handles loading and accessing goods configuration via the Library.

## Class Hierarchy
- **Extends:** Node
- **Extended by:** None
- **Used by:** Economic actors, Market system, UI components

## Methods
### static get_goods() -> Array
Returns all DataGood instances from the Library.

**Returns:** Array of DataGood instances

### static get_good_prices() -> Dictionary
Returns a dictionary mapping good ids to their prices.

**Returns:** A dictionary mapping good ids to their base prices

## Usage Examples
```gdscript
# Get all goods data
var goods = GoodsManager.get_goods()
for good in goods:
    print("Good: %s, Base Price: %.2f" % [good.id, good.base_price])

# Get a dictionary of good prices
var prices = GoodsManager.get_good_prices()
for good_id in prices:
    print("Good: %s, Price: %.2f" % [good_id, prices[good_id]])

# Use with UI components
func update_prices_display():
    var prices = GoodsManager.get_good_prices()
    for good_id in prices:
        var price_label = get_node("PriceLabels/" + good_id)
        if price_label:
            price_label.text = "%.2f" % prices[good_id]
```

## See Also
- [Good](./good.md)
- [DataGood](../../economic_actor/data_good.md)
- [Library](../../shared/library.md)
- [Market System](../../systems/market_system.md)
