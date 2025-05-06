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
	var people: Array = []

	for i in num_people:
		var culture_id: String = _pick_weighted_random(people_data.get("culture_allocation", {}))
		var ancestry_id: String = _pick_weighted_random(people_data.get("ancestry_allocation", {}))
		var culture: Dictionary = _find_by_id(cultures, culture_id)
		var ancestry: Dictionary = _find_by_id(ancestries, ancestry_id)

		var possible_names: Array = (culture.get("possible_names", []) + ancestry.get("possible_names", []))
		var f_name: String = _pick_random(possible_names)

		var min_savings: float = min(culture.get("savings_rate_range", [0.0, 0.0])[0], ancestry.get("savings_rate_range", [0.0, 0.0])[0])
		var max_savings: float = max(culture.get("savings_rate_range", [0.0, 0.0])[1], ancestry.get("savings_rate_range", [0.0, 0.0])[1])
		var savings_rate: float = randf_range(min_savings, max_savings)

		var decision_profiles: Array = (culture.get("decision_profiles", []) + ancestry.get("decision_profiles", []))
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
		var person = Person.from_data_person(data_person)
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

## Finds a dictionary in an array by its 'id' field
static func _find_by_id(array: Array, id_: String) -> Dictionary:
	for entry in array:
		if entry.get("id", "") == id_:
			return entry
	return {}

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
