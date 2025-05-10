# DataPerson API

## Last Updated: 2025-05-06

## Overview
`DataPerson` is a data class representing an economic actor (person) in the simulation. It holds all relevant state for decision-making, including unique ID, culture, ancestry, needs, savings rate, disposable income, and decision profile.

## Usage Example
```gdscript
var person = DataPerson.new(1, "northern", "ancestral_1", {"hunger": 0.5}, 0.25, 100.0, "greedy")
```

## Properties
- `id: int` — Unique integer ID for the person.
- `culture_id: String` — The culture ID this person belongs to.
- `ancestry_id: String` — The ancestry ID this person belongs to.
- `needs: Dictionary` — Dictionary of needs (e.g., hunger, comfort).
- `savings_rate: float` — Proportion of income reserved as savings.
- `disposable_income: float` — Money available for spending.
- `decision_profile: String` — String describing decision logic profile.

## Methods
- `static func load_all_from_json() -> Array` — Loads all people from the external JSON config using `Library.get_config`. Returns an array of `DataPerson` instances.

## Error Handling
- If the JSON config is missing or invalid, errors are logged and an empty array is returned. 
