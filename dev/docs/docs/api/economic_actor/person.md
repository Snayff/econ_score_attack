# Person

## Last Updated: 2025-06-25

## Table of Contents
- [Overview](#overview)
- [Class Hierarchy](#class-hierarchy)
- [Properties](#properties)
- [Methods](#methods)
- [Usage Examples](#usage-examples)
- [See Also](#see-also)

## Overview
The `Person` class represents an individual actor in the simulation that can produce and consume goods. Each person has a culture, ancestry, needs, and a decision profile that influences their economic behavior. People can produce goods based on their job, consume goods according to consumption rules, and make economic decisions.

## Class Hierarchy
- **Extends:** Node
- **Extended by:** None
- **Uses:** ComponentConsumer
- **Used by:** Demesne, SubViewPopulation, SubViewDecisions

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
| is_alive | bool | Whether the person is alive |
| health | int | Health points (death occurs at 0) |
| happiness | int | Happiness level |
| job | String | The job assigned to the person |
| stockpile | Dictionary | Dictionary of goods and their quantities owned by the person |
| consumer | ComponentConsumer | Component that handles consumption of goods |
| last_turn_decisions | Array | Array of decisions made in the last turn |

## Methods
### _init(id_: String, f_name_: String, culture_id_: String, ancestry_id_: String, needs_: Dictionary, savings_rate_: float, disposable_income_: float, decision_profile_: String, job_: String, starting_goods: Dictionary) -> void
Constructs a new Person node.

**Parameters:**
- `id_`: Unique string ID for the person. If empty, a unique id will be generated.
- `f_name_`: Friendly name for person.
- `culture_id_`: The culture ID this person belongs to.
- `ancestry_id_`: The ancestry ID this person belongs to.
- `needs_`: Dictionary of needs (e.g., hunger, comfort).
- `savings_rate_`: Proportion of income reserved as savings.
- `disposable_income_`: Money available for spending.
- `decision_profile_`: String describing decision logic profile.
- `job_`: The job assigned to the person.
- `starting_goods`: Dictionary of starting goods.

### produce() -> void
Produces goods based on the person's job. Different jobs produce different goods:
- Farmer: Produces grain
- Water collector: Produces water
- Gold miner: Produces money
- Woodcutter: Produces wood
- Bureaucrat: Produces bureaucracy for the demesne

### consume() -> void
Attempts to consume goods according to consumption rules. Successful consumption increases happiness, while failed consumption decreases health and can lead to death.

### get_goods_for_sale() -> Dictionary
Determines which goods the person has in excess and can sell.

**Returns:** Dictionary mapping good_id to quantity available for sale

### get_goods_to_buy() -> Dictionary
Determines which goods the person needs to buy.

**Returns:** Dictionary mapping good_id to quantity needed

### static from_data_person(data_person: DataPerson, starting_goods: Dictionary = {}) -> Person
Creates a Person node from a DataPerson data class.

**Parameters:**
- `data_person`: The data class instance to convert
- `starting_goods`: The starting goods for the person

**Returns:** A new Person node with fields mapped from the DataPerson

### log_decision(action: String, inputs: Dictionary, reasoning: String, alternatives: Array) -> void
Logs a decision made by the person in the last turn.

**Parameters:**
- `action`: The action taken (e.g., 'Purchased 3 grain from Bob')
- `inputs`: The input factors considered
- `reasoning`: The reasoning or utility calculation
- `alternatives`: Array of alternative actions considered, each as a Dictionary

### clear_last_turn_decisions() -> void
Clears the last turn's decision log.

## Usage Examples
```gdscript
# Create a new person with a job and starting goods
var person = Person.new(
    "person_1", 
    "John Smith", 
    "northern", 
    "ancestral_1", 
    {"hunger": 0.5, "comfort": 0.3}, 
    0.25,  # 25% savings rate
    100.0, 
    "risk_averse",
    "farmer",
    {"money": 50, "grain": 5, "water": 3}
)

# Have the person produce goods based on their job
person.produce()
print("After production, grain: %d" % person.stockpile["grain"])

# Have the person consume goods
person.consume()
print("After consumption, health: %d, happiness: %d" % [person.health, person.happiness])

# Check what goods the person wants to sell
var goods_for_sale = person.get_goods_for_sale()
print("Goods for sale: %s" % goods_for_sale)

# Check what goods the person wants to buy
var goods_to_buy = person.get_goods_to_buy()
print("Goods to buy: %s" % goods_to_buy)

# Log a decision made by the person
person.log_decision(
    "Purchased 3 grain from Market",
    {"price": 10, "need_level": 0.8},
    "High hunger level and affordable price",
    [{"action": "Purchase water", "utility": 0.6}]
)
```

## See Also
- [DataPerson](./data_person.md)
- [DataCulture](./data_culture.md)
- [DataAncestry](./data_ancestry.md)
- [ComponentConsumer](./component_consumer.md)
- [ComponentGoodUtility](./component_good_utility.md)
- [Economic Actor Decision System](../systems/economic_actor_decision_system.md)
