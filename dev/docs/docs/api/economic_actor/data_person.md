# DataPerson

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
Represents a person in the simulation, holding all relevant state for decision-making, including savings rate and disposable income. Each person has a culture, ancestry, needs, and a decision profile that influences their economic behavior.

## Class Hierarchy
- **Extends:** Resource
- **Extended by:** None
- **Used by:** Person, ComponentConsumer, ComponentGoodUtility

## Properties
| Name | Type | Description |
|------|------|-------------|
| id | String | Unique string ID for the person |
| f_name | String | Friendly name for person |
| culture_id | String | The culture ID this person belongs to |
| ancestry_id | String | The ancestry ID this person belongs to |
| needs | Dictionary | Dictionary of needs (e.g., hunger, comfort) |
| savings_rate | float | Proportion of income reserved as savings (0-1) |
| disposable_income | float | Money available for spending after savings are set aside |
| decision_profile | String | String describing decision logic profile |

## Methods
### _init(id_: String, f_name_: String, culture_id_: String, ancestry_id_: String, needs_: Dictionary, savings_rate_: float, disposable_income_: float, decision_profile_: String) -> void
Constructs a new DataPerson instance.

**Parameters:**
- `id_`: Unique string ID for the person
- `f_name_`: Friendly name for person
- `culture_id_`: The culture ID this person belongs to
- `ancestry_id_`: The ancestry ID this person belongs to
- `needs_`: Dictionary of needs (e.g., hunger, comfort)
- `savings_rate_`: Proportion of income reserved as savings
- `disposable_income_`: Money available for spending
- `decision_profile_`: String describing decision logic profile

### update_disposable_income(total_money: float) -> float
Updates disposable_income based on total_money and savings_rate.

**Parameters:**
- `total_money`: The actor's total money

**Returns:** The updated disposable_income

## Usage Examples
```gdscript
# Create a new person with basic needs
var person = DataPerson.new(
    "1", 
    "John Smith", 
    "northern", 
    "ancestral_1", 
    {"hunger": 0.5, "comfort": 0.3}, 
    0.25,  # 25% savings rate
    100.0, 
    "greedy"
)

# Update their disposable income when they receive money
var new_total_money = 200.0
var disposable = person.update_disposable_income(new_total_money)
print("Disposable income: %s" % disposable)  # Should print 150.0
```

## See Also

- [DataCulture](./data_culture.md)
- [DataAncestry](./data_ancestry.md)
- [ComponentGoodUtility](./component_good_utility.md)
- [Economic Actor Decision System](../systems/economic_actor_decision_system.md)
