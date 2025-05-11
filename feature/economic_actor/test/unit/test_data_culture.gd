## Unit tests for DataCulture
## Last Updated: 2025-05-05
extends Node

var _test_culture: DataCulture

func _ready() -> void:
	test_constructor()
	test_json_loading()

func test_constructor() -> void:
	var possible_names = ["alfred", "edith"]
	var savings_rate_range = [0.05, 0.15]
	var decision_profiles = ["risk_averse"]
	var shock_response = "hoard"
	var consumption_rule_ids = ["grain_basic"]
	_test_culture = DataCulture.new(
		"northern",
		possible_names,
		savings_rate_range,
		decision_profiles,
		shock_response,
		consumption_rule_ids
	)
	assert(_test_culture.id == "northern")
	assert(_test_culture.possible_names == possible_names)
	assert(_test_culture.savings_rate_range == savings_rate_range)
	assert(_test_culture.decision_profiles == decision_profiles)
	assert(_test_culture.shock_response == shock_response)
	assert(_test_culture.consumption_rule_ids == consumption_rule_ids)

func test_json_loading() -> void:
	var cultures = Library.get_all_cultures_data()
	assert(typeof(cultures) == TYPE_ARRAY)
	assert(cultures.size() > 0)
	for culture in cultures:
		assert(culture is DataCulture) 