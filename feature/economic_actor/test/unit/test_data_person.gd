## Unit tests for DataPerson
## Last Updated: 2024-06-09
# Requires Factory to be set as an autoload (singleton)
extends Node

const GameFactory = preload("res://global/game_factory.gd")

var _test_person: DataPerson

func _ready() -> void:
	test_constructor()
	test_json_loading()

func test_constructor() -> void:
	var needs = {"hunger": 0.5, "comfort": 0.8}
	_test_person = DataPerson.new("test_id_1", "test_name", "northern", "ancestral_1", needs, 0.25, 100.0, "greedy")
	assert(_test_person.id == "test_id_1")
	assert(_test_person.culture_id == "northern")
	assert(_test_person.ancestry_id == "ancestral_1")
	assert(_test_person.needs == needs)
	assert(_test_person.savings_rate == 0.25)
	assert(_test_person.disposable_income == 100.0)
	assert(_test_person.decision_profile == "greedy")

func test_json_loading() -> void:
	var people = GameFactory.generate_starting_people()
	assert(typeof(people) == TYPE_ARRAY)
	# If people.json is missing, should return empty array
	if people.size() == 0:
		print("No people loaded (expected if people.json missing)")
	else:
		for person in people:
			assert(person is DataPerson)
