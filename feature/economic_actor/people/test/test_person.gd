## Unit tests for the Person class
class_name TestPerson
extends ABCTest

var _person: Person

func before_each() -> void:
	_person = Person.new(
		"Test Person",
		"farmer",
		{
			"grain": 0,
			"water": 10,
			"money": 100
		}
	)

func after_each() -> void:
	_person = null

func test_initial_state() -> void:
	assert_eq(_person.f_name, "Test Person", "Name should be set correctly")
	assert_eq(_person.job, "farmer", "Job should be set correctly")
	assert_eq(_person.stockpile["water"], 10, "Initial stockpile should be set")
	assert_true(_person.is_alive, "Person should start alive")

func test_farmer_production() -> void:
	var initial_grain = _person.stockpile.get("grain", 0)
	_person.produce()
	assert_eq(
		_person.stockpile["grain"],
		initial_grain + 10,
		"Farmer should produce 10 grain"
	)

func test_water_collector_production() -> void:
	_person.job = "water collector"
	var initial_water = _person.stockpile.get("water", 0)
	_person.produce()
	assert_eq(
		_person.stockpile["water"],
		initial_water + 20,
		"Water collector should produce 20 water"
	)

func test_woodcutter_production() -> void:
	_person.job = "woodcutter"
	var initial_wood = _person.stockpile.get("wood", 0)
	_person.produce()
	assert_eq(
		_person.stockpile["wood"],
		initial_wood + 10,
		"Woodcutter should produce 10 wood"
	)

func test_gold_miner_production() -> void:
	_person.job = "gold miner"
	var initial_money = _person.stockpile.get("money", 0)
	_person.produce()
	assert_eq(
		_person.stockpile["money"],
		initial_money + 5,
		"Gold miner should produce 5 money"
	)

func test_people_culture_allocation_matches_cultures() -> void:
	## Ensures all culture ids in people.json's culture_allocation exist in cultures.json
	var people_data: Dictionary = Library.get_all_people_data()
	var culture_allocation: Dictionary = people_data.get("culture_allocation", {})
	var allocated_cultures: Array = culture_allocation.keys()

	var cultures: Array = Library.get_all_cultures_data()
	var culture_ids: Array = []
	for culture in cultures:
		culture_ids.append(culture.id)

	for allocated_id in allocated_cultures:
		assert_true(
			allocated_id in culture_ids,
			"Culture id '%s' in people.json's culture_allocation is missing from cultures.json" % allocated_id
		)

func test_people_ancestry_allocation_matches_ancestries() -> void:
	## Ensures all ancestry ids in people.json's ancestry_allocation exist in ancestries.json
	var people_data: Dictionary = Library.get_all_people_data()
	var ancestry_allocation: Dictionary = people_data.get("ancestry_allocation", {})
	var allocated_ancestries: Array = ancestry_allocation.keys()

	var ancestries: Array = Library.get_all_ancestries_data()
	var ancestry_ids: Array = []
	for ancestry in ancestries:
		# ancestries are dictionaries, not classes
		ancestry_ids.append(ancestry["id"])

	for allocated_id in allocated_ancestries:
		assert_true(
			allocated_id in ancestry_ids,
			"Ancestry id '%s' in people.json's ancestry_allocation is missing from ancestries.json" % allocated_id
		)

func test_disposable_income_calculation() -> void:
	var data_person = DataPerson.new(
		"1", "Test", "northern", "ancestral_1", {"hunger": 0.5}, 0.25, 0.0, "greedy"
	)
	var total_money = 200.0
	var expected_disposable = total_money * (1.0 - data_person.savings_rate)
	var result = data_person.update_disposable_income(total_money)
	assert_eq(result, expected_disposable, "Disposable income should be calculated correctly.")

func test_cannot_overspend_disposable_income() -> void:
	var data_person = DataPerson.new(
		"2", "Test2", "northern", "ancestral_1", {"hunger": 0.5}, 0.5, 100.0, "greedy"
	)
	var price = 120.0
	var can_afford = data_person.disposable_income >= price
	assert_true(not can_afford, "Person should not be able to spend more than disposable income.")

func test_utility_selection_respects_disposable_income() -> void:
	# Setup a DataPerson with limited disposable income
	var data_person = DataPerson.new(
		"3", "Test3", "northern", "ancestral_1", {"hunger": 1.0}, 0.2, 10.0, "greedy"
	)
	# Setup goods and prices
	var cheap_good = DataGood.new("cheap_food", "Cheap Food", 1.0, "food", "🍞")
	var expensive_good = DataGood.new("luxury", "Luxury", 50.0, "luxury", "💎")
	var goods = [cheap_good, expensive_good]
	var cultures = {"northern": DataCulture.new("northern", [], [0.1, 0.3], [], "hoard", [])}
	var ancestries = {"ancestral_1": {"base_preferences": {}}}
	var prices = {"cheap_food": 5.0, "luxury": 50.0}
	var selected = ComponentGoodUtility.select_best_affordable_good(data_person, goods, cultures, ancestries, prices)
	assert_eq(selected, "cheap_food", "Should select only affordable good based on disposable income.")
