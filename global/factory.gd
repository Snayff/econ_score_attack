##
## Global factory for generating game entities from loaded data
##
## Provides methods to generate people/actors at game start, merging culture and ancestry data as per allocation rules.
## Example usage:
##   var people = Factory.generate_starting_people()
extends Node

#region CONSTANTS
const Person = preload("res://feature/economic_actor/people/person.gd")
const DataPerson = preload("res://feature/economic_actor/data_class/data_person.gd")
const DataCulture = preload("res://feature/economic_actor/data_class/data_culture.gd")
const DataAncestry = preload("res://feature/economic_actor/data_class/data_ancestry.gd")
#endregion


#region SIGNALS
#endregion


#region ON READY
#endregion


#region EXPORTS
#endregion


#region VARS
#endregion


#region PUBLIC FUNCTIONS
## Generates the starting people for the game based on people, culture, and ancestry configs.
## @return Array of Person instances
static func generate_starting_people() -> Array:
	var people_data: Dictionary = Library.get_people_data()
	var cultures: Array = Library.get_all_cultures_data()
	var ancestries: Array = Library.get_all_ancestries_data()
	var num_people: int = people_data.get("starting_num_people", 0)
	var starting_goods: Dictionary = people_data.get("starting_goods", {})
	var people: Array = []

	for i in num_people:
		var culture_id: String = _pick_weighted_random(people_data.get("culture_allocation", {}))
		var ancestry_id: String = _pick_weighted_random(people_data.get("ancestry_allocation", {}))
		var culture: DataCulture = _find_by_id(cultures, culture_id)
		var ancestry: DataAncestry = _find_by_id(ancestries, ancestry_id)

		var possible_names: Array = (culture.possible_names if culture.possible_names else []) + (ancestry.possible_names if ancestry.possible_names else [])
		var f_name: String = _pick_random(possible_names)

		var min_savings: float = min(culture.savings_rate_range[0] if culture.savings_rate_range else 0.0, ancestry.savings_rate_range[0] if ancestry.savings_rate_range else 0.0)
		var max_savings: float = max(culture.savings_rate_range[1] if culture.savings_rate_range else 0.0, ancestry.savings_rate_range[1] if ancestry.savings_rate_range else 0.0)
		var savings_rate: float = randf_range(min_savings, max_savings)

		var decision_profiles: Array = (culture.decision_profiles if culture.decision_profiles else []) + (ancestry.decision_profiles if ancestry.decision_profiles else [])
		var decision_profile: String = _pick_random(decision_profiles)

		# For now, use an empty dictionary for needs and 0.0 for disposable_income
		var needs: Dictionary = {}
		var disposable_income: float = 0.0

		var data_person = DataPerson.new(
			IDGenerator.generate_id("ACT"),
			f_name,
			culture_id,
			ancestry_id,
			needs,
			savings_rate,
			disposable_income,
			decision_profile
		)
		var person = Person.from_data_person(data_person, starting_goods)
		people.append(person)
	return people
#endregion


#region PRIVATE FUNCTIONS
## Picks a key from a dictionary based on weighted (percentage) allocation
static func _pick_weighted_random(allocation: Dictionary) -> String:
	var total: float = 0.0
	for v in allocation.values():
		total += float(v)
	var r: float = randf()
	var cumulative: float = 0.0
	for k in allocation.keys():
		cumulative += float(allocation[k]) / total
		if r <= cumulative:
			return k
	return allocation.keys()[0] if allocation.size() > 0 else ""

## Finds a Resource in an array by its 'id' property
## @nullable
static func _find_by_id(array: Array, id_: String) -> Variant: # Will update this to be generic, but note in docstring that it returns DataCulture or DataAncestry or null
	for entry in array:
		if entry.id == id_:
			return entry
	return null

## Removes duplicates from an array
static func _deduplicate(array: Array) -> Array:
	var seen := {}
	var result: Array = []
	for item in array:
		if not seen.has(item):
			seen[item] = true
			result.append(item)
	return result

## Picks a random element from an array
static func _pick_random(array: Array) -> Variant:
	if array.size() == 0:
		return ""
	return array[randi() % array.size()]
#endregion
