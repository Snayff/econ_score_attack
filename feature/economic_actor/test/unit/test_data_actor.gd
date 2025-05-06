## Unit tests for DataActor
## Last Updated: 2025-05-05
# Requires Factory to be set as an autoload (singleton)
extends Node

var _test_actor: DataActor

func _ready() -> void:
	test_constructor()
	test_json_loading()

func test_constructor() -> void:
	var needs = {"hunger": 0.5, "comfort": 0.8}
	_test_actor = DataActor.new("test_id_1", "test_name", "northern", "ancestral_1", needs, 0.25, 100.0, "greedy")
	assert(_test_actor.id == "test_id_1")
	assert(_test_actor.culture_id == "northern")
	assert(_test_actor.ancestry_id == "ancestral_1")
	assert(_test_actor.needs == needs)
	assert(_test_actor.savings_rate == 0.25)
	assert(_test_actor.disposable_income == 100.0)
	assert(_test_actor.decision_profile == "greedy")

func test_json_loading() -> void:
	var actors = Factory.generate_starting_people()
	assert(typeof(actors) == TYPE_ARRAY)
	# If people.json is missing, should return empty array
	if actors.size() == 0:
		print("No actors loaded (expected if people.json missing)")
	else:
		for actor in actors:
			assert(actor is DataActor)
