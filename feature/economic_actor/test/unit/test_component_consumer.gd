## Unit tests for the ComponentConsumer class
##
## Last Updated: 2024-06-09
#
# These tests verify that consumption rules are enforced and stockpiles cannot go negative.
#
# Example usage:
#   var consumer = ComponentConsumer.new("Test Person", {"grain": 10})
#   consumer.consume()
class_name TestComponentConsumer
extends ABCTest

var _consumer
var _mock_stockpile
var _original_library

# Mock rule structure
class MockRule:
	var good_id: String
	var desired_consumption_amount: int
	var min_consumption_amount: int
	var min_held_before_desired_consumption: int
	func _init(good_id_, desired_, min_, held_):
		good_id = good_id_
		desired_consumption_amount = desired_
		min_consumption_amount = min_
		min_held_before_desired_consumption = held_

# Mock Library singleton
class MockLibrary:
	static func get_all_consumption_rules():
		return [
			MockRule.new("grain", 5, 2, 3)
		]
	static func get_good_icon(_good_id):
		return "icon"

func before_each() -> void:
	# Patch Library singleton
	_original_library = Library
	var Library = MockLibrary
	_mock_stockpile = {"grain": 0}
	_consumer = ComponentConsumer.new("Test Person", _mock_stockpile)

func after_each() -> void:
	var Library = _original_library
	_consumer = null
	_mock_stockpile = {}

func test_desired_consumption_succeeds() -> void:
	_mock_stockpile["grain"] = 10
	var result = _consumer.consume()
	assert_true(result, "Should consume when enough for desired consumption")
	assert_eq(_mock_stockpile["grain"], 5, "Stockpile should decrease by desired amount")

func test_required_consumption_succeeds() -> void:
	_mock_stockpile["grain"] = 3
	var result = _consumer.consume()
	assert_true(result, "Should consume when enough for required consumption")
	assert_eq(_mock_stockpile["grain"], 1, "Stockpile should decrease by required amount")

func test_consumption_fails_when_insufficient() -> void:
	_mock_stockpile["grain"] = 1
	var result = _consumer.consume()
	assert_eq(result, false, "Should not consume when not enough for required consumption")
	assert_eq(_mock_stockpile["grain"], 1, "Stockpile should not change if consumption fails")

func test_stockpile_never_negative() -> void:
	_mock_stockpile["grain"] = 2
	var result = _consumer.consume()
	assert_true(result, "Should consume exactly required amount")
	assert_eq(_mock_stockpile["grain"], 0, "Stockpile should be zero, not negative")

func test_edge_case_exactly_at_desired_threshold() -> void:
	_mock_stockpile["grain"] = 5
	# min_held_before_desired_consumption is 3, so 5 > 3, and 5 >= 5
	var result = _consumer.consume()
	assert_true(result, "Should consume desired amount when exactly enough")
	assert_eq(_mock_stockpile["grain"], 0, "Stockpile should be zero after desired consumption")
