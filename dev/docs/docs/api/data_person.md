# DataPerson

## Last Updated: 2025-05-11

## Overview
Represents a person in the simulation, holding all relevant state for decision-making, including savings rate and disposable income.

## Properties
- id: String — Unique string ID for the person.
- f_name: String — Friendly name for person.
- culture_id: String — The culture ID this person belongs to.
- ancestry_id: String — The ancestry ID this person belongs to.
- needs: Dictionary — Dictionary of needs (e.g., hunger, comfort).
- savings_rate: float — Proportion of income reserved as savings (0-1).
- disposable_income: float — Money available for spending after savings are set aside.
- decision_profile: String — String describing decision logic profile.

## Methods
### update_disposable_income(total_money: float) -> float
Updates disposable_income based on total_money and savings_rate.
- total_money: The actor's total money (float).
- Returns: The updated disposable_income (float).

## Example Usage
```gdscript
var person = DataPerson.new("1", "name", "northern", "ancestral_1", {"hunger": 0.5}, 0.25, 100.0, "greedy")
person.update_disposable_income(200.0)
print(person.disposable_income) # Should print 150.0 if savings_rate is 0.25
```

## Methods
- `static func load_all_from_json() -> Array` — Loads all people from the external JSON config using `Library.get_config`. Returns an array of `DataPerson` instances.

## Error Handling
- If the JSON config is missing or invalid, errors are logged and an empty array is returned. 
