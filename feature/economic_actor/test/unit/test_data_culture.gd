## Unit tests for DataCulture
## Last Updated: 2025-05-05
extends Node

var _test_culture: DataCulture

func _ready() -> void:
	test_constructor()
	test_json_loading()

func test_constructor() -> void:
	var prefs = {"food": 1.2, "entertainment": 0.8}
	_test_culture = DataCulture.new("northern", prefs, 0.25, "hoard")
	assert(_test_culture.id == "northern")
	assert(_test_culture.base_preferences == prefs)
	assert(_test_culture.savings_rate == 0.25)
	assert(_test_culture.shock_response == "hoard")

func test_json_loading() -> void:
	var cultures = Library.get_all_cultures_data()
	assert(typeof(cultures) == TYPE_ARRAY)
	assert(cultures.size() > 0)
	for culture in cultures:
		assert(culture is DataCulture) 