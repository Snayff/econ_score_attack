
# DataCulture

## Last Updated: 
2025-06-23

## Table of Contents
- [Overview](#overview)
- [Class Hierarchy](#class-hierarchy)
- [Properties](#properties)
- [Methods](#methods)
- [Usage Examples](#usage-examples)
- [See Also](#see-also)

## Overview
Represents a culture in the simulation, defining characteristics that influence economic actors' behavior, including possible names, savings rate ranges, decision profiles, responses to economic shocks, and consumption rules.

## Class Hierarchy
- **Extends:** Resource
- **Extended by:** None
- **Used by:** Library, ComponentGoodUtility

## Properties
| Name | Type | Description |
|------|------|-------------|
| id | String | Unique string ID for the culture |
| possible_names | Array | Array of possible names for this culture |
| savings_rate_range | Array | Array [min, max] savings rate for this culture |
| decision_profiles | Array | Array of decision profile strings |
| shock_response | String | String describing response to economic shocks |
| consumption_rule_ids | Array | Array of consumption rule IDs |

## Methods
### _init(id_: String, possible_names_: Array, savings_rate_range_: Array, decision_profiles_: Array, shock_response_: String, consumption_rule_ids_: Array) -> void
Constructs a new DataCulture instance.

**Parameters:**
- `id_`: Unique string ID for the culture
- `possible_names_`: Array of possible names for this culture
- `savings_rate_range_`: Array [min, max] savings rate for this culture
- `decision_profiles_`: Array of decision profile strings
- `shock_response_`: String describing response to economic shocks
- `consumption_rule_ids_`: Array of consumption rule IDs

## Usage Examples
```gdscript
# Create a new culture
var culture = DataCulture.new(
    "agrarian", 
    ["Sally", "Bob", "Alice"], 
    [0.05, 0.15],  # 5-15% savings rate range
    ["risk_averse"], 
    "hoard", 
    ["grain_basic", "water_basic"]
)

# Access culture properties
print("Culture ID: %s" % culture.id)
print("Possible names: %s" % culture.possible_names)
print("Savings rate range: %s" % culture.savings_rate_range)
```

## See Also

- [DataPerson](./data_person.md)
- [Library](./library.md)
- [Economic Actor Decision System](../systems/economic_actor_decision_system.md)
