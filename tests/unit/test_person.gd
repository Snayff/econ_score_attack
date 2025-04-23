## Unit tests for the Person class
class_name TestPerson
extends ABCTest

const Person = preload("res://scripts/actors/person.gd")

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