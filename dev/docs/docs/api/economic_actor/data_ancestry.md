# DataAncestry

## Last Updated: 2025-06-25

## Table of Contents
- [Overview](#overview)
- [Class Hierarchy](#class-hierarchy)
- [Properties](#properties)
- [Methods](#methods)
- [Usage Examples](#usage-examples)
- [See Also](#see-also)

## Overview
`DataAncestry` is a data class representing hereditary characteristics that influence economic actors' behavior. It defines possible names, savings rate ranges, decision profiles, responses to economic shocks, and consumption rule preferences that are passed down through ancestry lines.

## Class Hierarchy
- **Extends:** Resource
- **Extended by:** None
- **Used by:** Library, Person, ComponentGoodUtility

## Properties
| Name | Type | Description |
|------|------|-------------|
| id | String | Unique string ID for the ancestry |
| possible_names | Array | Array of possible names for this ancestry |
| savings_rate_range | Array | Array [min, max] savings rate for this ancestry |
| decision_profiles | Array | Array of decision profile strings |
| shock_response | String | String describing response to economic shocks |
| consumption_rule_ids | Array | Array of consumption rule IDs |

## Methods
### _init(id_: String, possible_names_: Array, savings_rate_range_: Array, decision_profiles_: Array, shock_response_: String, consumption_rule_ids_: Array) -> void
Constructs a new DataAncestry instance.

**Parameters:**
- `id_`: Unique string ID for the ancestry
- `possible_names_`: Array of possible names for this ancestry
- `savings_rate_range_`: Array [min, max] savings rate for this ancestry
- `decision_profiles_`: Array of decision profile strings
- `shock_response_`: String describing response to economic shocks
- `consumption_rule_ids_`: Array of consumption rule IDs

## Usage Examples
```gdscript
# Create a new ancestry
var ancestry = DataAncestry.new(
    "northern", 
    ["Alfred", "Edith", "Harold"], 
    [0.03, 0.12],  # 3-12% savings rate range
    ["risk_taker", "opportunistic"], 
    "adapt", 
    ["meat_basic", "grain_basic"]
)

# Access ancestry properties
print("Ancestry ID: %s" % ancestry.id)
print("Possible names: %s" % ancestry.possible_names)
print("Savings rate range: %s" % ancestry.savings_rate_range)
print("Decision profiles: %s" % ancestry.decision_profiles)

# Use with Library to get ancestry data
var northern_ancestry = Library.get_ancestry_by_id("northern")
if northern_ancestry:
    print("Found ancestry: %s" % northern_ancestry.id)
    print("Shock response: %s" % northern_ancestry.shock_response)
```

## See Also
- [DataPerson](./data_person.md)
- [DataCulture](./data_culture.md)
- [Person](./person.md)
- [Library](../shared/library.md)
- [Economic Actor Decision System](../systems/economic_actor_decision_system.md)
