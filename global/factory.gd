##
## Global factory for generating game entities from loaded data
##
## Provides methods to generate people/actors at game start, merging culture and ancestry data as per allocation rules.
## Example usage:
##   var people = GameFactory.generate_starting_people()
extends Node

#region CONSTANTS
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
## Generates the starting people for the game based on people, culture, ancestry, and job allocation configs.
## Jobs are assigned according to the weighted random allocation in people.json's job_allocation.
## @return Array of Person instances
static func generate_starting_people() -> Array:
	var people_data: Dictionary = Library.get_people_data()
	var cultures: Array = Library.get_all_cultures_data()
	var ancestries: Array = Library.get_all_ancestries_data()
	var num_people: int = people_data.get("starting_num_people", 0)
	var starting_goods: Dictionary = people_data.get("starting_goods", {})
	var job_allocation: Dictionary = people_data.get("job_allocation", {})
	var jobs: Array = _generate_job_distribution(job_allocation, num_people)

	var people: Array = []
	for i in num_people:
		var person = _create_person(cultures, ancestries, people_data, starting_goods, jobs[i])
		people.append(person)
	return people

## Generates a strict job distribution array based on allocation and number of people
static func _generate_job_distribution(job_allocation: Dictionary, num_people: int) -> Array:
	var job_counts := {}
	var total_assigned := 0
	var remainders := []

	# Calculate initial job counts and remainders
	for job in job_allocation.keys():
		var exact = float(job_allocation[job]) * float(num_people)
		var count = int(floor(exact))
		job_counts[job] = count
		remainders.append({"job": job, "remainder": exact - float(count)})
		total_assigned += count

	# Distribute remaining slots based on largest remainders
	remainders.sort_custom(func(a, b): return b["remainder"] - a["remainder"])
	var idx := 0
	while total_assigned < num_people:
		var job = remainders[idx % remainders.size()]["job"]
		job_counts[job] += 1
		total_assigned += 1
		idx += 1

	# Build and shuffle the job list
	var jobs := []
	for job in job_counts.keys():
		for i in job_counts[job]:
			jobs.append(job)
	jobs.shuffle()
	return jobs

## Creates a Person instance with the given job and other randomly selected attributes
static func _create_person(cultures: Array, ancestries: Array, people_data: Dictionary, starting_goods: Dictionary, job: String) -> Person:
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

	var needs: Dictionary = {"job": job}
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
	return Person.from_data_person(data_person, starting_goods)
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
