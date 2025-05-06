## Unit tests for GoodUtilityComponent
## Last Updated: DATE
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
var _test_actor: DataActor
var _test_goods: Array
var _test_cultures: Dictionary
var _test_ancestries: Dictionary
var _test_prices: Dictionary
#endregion


#region PUBLIC FUNCTIONS
func _ready() -> void:
	test_utility_basic()
	test_utility_culture_influence()
	test_utility_edge_cases()
	test_select_best_affordable_good()

func test_utility_basic() -> void:
	# Actor with hunger need, one good
	_test_actor = DataActor.new("1", "name", "northern", "ancestral_1", {"food": 1.0}, 0.2, 100.0, "greedy")
	var good = DataGood.new("food", "Food", 1.0, "basic", "")
	_test_goods = [good]
	_test_cultures = {"northern": DataCulture.new("northern", {"food": 1.5}, 0.2, "hoard")}
	_test_ancestries = {"ancestral_1": {"base_preferences": {"food": 1.0}, "shock_response": "share"}}
	_test_prices = {"food": 10.0}
	var util_dict = GoodUtilityComponent.calculate_good_utility(_test_actor, _test_goods, _test_cultures, _test_ancestries, _test_prices)
	assert(util_dict.has("food"))
	assert(util_dict["food"] > 0.0)

func test_utility_culture_influence() -> void:
	# Actor with different culture, higher preference for entertainment
	_test_actor = DataActor.new("2", "name", "southern", "ancestral_2", {"entertainment": 1.0}, 0.2, 100.0, "greedy")
	var good = DataGood.new("entertainment", "Entertainment", 1.0, "luxury", "")
	_test_goods = [good]
	_test_cultures = {"southern": DataCulture.new("southern", {"entertainment": 2.0}, 0.2, "share")}
	_test_ancestries = {"ancestral_2": {"base_preferences": {"entertainment": 1.0}, "shock_response": "share"}}
	_test_prices = {"entertainment": 15.0}
	var util_dict = GoodUtilityComponent.calculate_good_utility(_test_actor, _test_goods, _test_cultures, _test_ancestries, _test_prices)
	assert(util_dict["entertainment"] > 0.0)

func test_utility_edge_cases() -> void:
	# No affordable goods
	_test_actor = DataActor.new("3", "name", "northern", "ancestral_1", {"food": 1.0}, 0.2, 5.0, "greedy")
	var good = DataGood.new("food", "Food", 1.0, "basic", "")
	_test_goods = [good]
	_test_cultures = {"northern": DataCulture.new("northern", {"food": 1.5}, 0.2, "hoard")}
	_test_ancestries = {"ancestral_1": {"base_preferences": {"food": 1.0}, "shock_response": "share"}}
	_test_prices = {"food": 10.0}
	var best_good = GoodUtilityComponent.select_best_affordable_good(_test_actor, _test_goods, _test_cultures, _test_ancestries, _test_prices)
	assert(best_good == "")
	# Zero needs
	_test_actor = DataActor.new("4", "name", "northern", "ancestral_1", {"food": 0.0}, 0.2, 100.0, "greedy")
	var util_dict = GoodUtilityComponent.calculate_good_utility(_test_actor, _test_goods, _test_cultures, _test_ancestries, _test_prices)
	assert(util_dict["food"] <= 0.05)

func test_select_best_affordable_good() -> void:
	# Multiple goods, select highest utility affordable
	_test_actor = DataActor.new("5", "name", "northern", "ancestral_1", {"food": 1.0, "luxury": 0.5}, 0.2, 20.0, "greedy")
	var good1 = DataGood.new("food", "Food", 1.0, "basic", "")
	var good2 = DataGood.new("luxury", "Luxury", 1.0, "luxury", "")
	_test_goods = [good1, good2]
	_test_cultures = {"northern": DataCulture.new("northern", {"food": 1.5, "luxury": 0.5}, 0.2, "hoard")}
	_test_ancestries = {"ancestral_1": {"base_preferences": {"food": 1.0, "luxury": 0.7}, "shock_response": "share"}}
	_test_prices = {"food": 10.0, "luxury": 15.0}
	var best_good = GoodUtilityComponent.select_best_affordable_good(_test_actor, _test_goods, _test_cultures, _test_ancestries, _test_prices)
	assert(best_good in ["food", "luxury"])
#endregion


#region PRIVATE FUNCTIONS
#endregion 