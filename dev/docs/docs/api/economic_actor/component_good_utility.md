# ComponentGoodUtility

## Last Updated: 
2025-06-23

## Table of Contents
- [Overview](#overview)
- [Class Hierarchy](#class-hierarchy)
- [Methods](#methods)
- [Usage Examples](#usage-examples)
- [See Also](#see-also)

## Overview
Calculates utility values for goods for a given actor, and selects the best affordable good based on actor preferences, needs, and economic factors. This component is central to the economic decision-making system.

## Class Hierarchy
- **Extends:** Node
- **Extended by:** None
- **Used by:** Person, Economic Actor System

## Methods
### static calculate_good_utility(actor: DataPerson, goods: Array, cultures: Dictionary, ancestries: Dictionary, prices: Dictionary) -> Dictionary
Calculates the utility value for each good for the given actor.

**Parameters:**
- `actor`: The actor evaluating goods
- `goods`: Array of DataGood
- `cultures`: Dictionary mapping culture_id to DataCulture
- `ancestries`: Dictionary mapping ancestry_id to ancestry Dictionary
- `prices`: Dictionary mapping good_id to price (float)

**Returns:** Dictionary mapping good_id to utility (float)

### static select_best_affordable_good(actor: DataPerson, goods: Array, cultures: Dictionary, ancestries: Dictionary, prices: Dictionary) -> String
Selects the best affordable good for the actor based on calculated utility.

**Parameters:**
- `actor`: The actor evaluating goods
- `goods`: Array of DataGood
- `cultures`: Dictionary mapping culture_id to DataCulture
- `ancestries`: Dictionary mapping ancestry_id to ancestry Dictionary
- `prices`: Dictionary mapping good_id to price (float)

**Returns:** good_id of the best affordable good, or "" if none

### static handle_purchase(actor: DataPerson, good_id: String, price: float) -> void
Handles the purchase of a good, updates savings and disposable income, and logs the purchase decision.

**Parameters:**
- `actor`: DataPerson making the purchase
- `good_id`: String ID of the good being purchased
- `price`: Price of the good (float)

## Usage Examples
```gdscript
# Calculate utility values for available goods
var actor = get_person()  # Get a DataPerson instance
var goods = Library.get_all_goods_data()
var cultures = {"northern": get_northern_culture()}  # Dictionary of cultures
var ancestries = {"ancestral_1": get_ancestry_data()}  # Dictionary of ancestries
var prices = {"grain": 10.0, "water": 5.0}  # Current market prices

var utilities = ComponentGoodUtility.calculate_good_utility(
    actor, goods, cultures, ancestries, prices
)
print("Utility values: %s" % utilities)

# Select the best affordable good
var best_good_id = ComponentGoodUtility.select_best_affordable_good(
    actor, goods, cultures, ancestries, prices
)
print("Best good to purchase: %s" % best_good_id)
```

## See Also

- [DataPerson](./data_person.md)
- [DataGood](./data_good.md)
- [ComponentConsumer](./component_consumer.md)
- [Market System](../systems/market_system.md)
- [Economic Actor Decision System](../systems/economic_actor_decision_system.md)
