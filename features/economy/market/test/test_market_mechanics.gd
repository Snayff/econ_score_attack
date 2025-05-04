## Integration tests for market mechanics
class_name TestMarketMechanics
extends ABCTest

const Sim = preload("res://scripts/core/sim.gd")
const Demesne = preload("res://scripts/actors/demesne.gd")
const Person = preload("res://scripts/actors/person.gd")

var _sim: Sim
var _demesne: Demesne

func before_each() -> void:
    _demesne = Demesne.new("Test Demesne")
    _sim = Sim.new()
    _sim.demesne = _demesne
    
    # Setup test market conditions
    _sim.good_prices = {
        "grain": 10,
        "water": 5,
        "wood": 15
    }

func after_each() -> void:
    _sim = null
    _demesne = null

func test_basic_market_transaction() -> void:
    var seller = Person.new(
        "Seller",
        "farmer",
        {
            "grain": 20,
            "money": 0
        }
    )
    
    var buyer = Person.new(
        "Buyer",
        "woodcutter",
        {
            "grain": 0,
            "money": 50,
            "wood": 10
        }
    )
    
    _demesne.add_person(seller)
    _demesne.add_person(buyer)
    
    _sim.resolve_turn()
    
    assert_eq(
        seller.stockpile["money"],
        100,
        "Seller should receive money for grain"
    )
    assert_eq(
        buyer.stockpile["grain"],
        10,
        "Buyer should receive grain"
    )

func test_money_conservation() -> void:
    var initial_money = _calculate_total_money()
    _sim.resolve_turn()
    var final_money = _calculate_total_money()
    
    assert_eq(
        initial_money,
        final_money,
        "Total money should remain constant"
    )

func test_multi_person_market() -> void:
    # Add multiple people with different jobs and resources
    var farmer1 = Person.new("Farmer1", "farmer", {"grain": 30, "money": 10})
    var farmer2 = Person.new("Farmer2", "farmer", {"grain": 20, "money": 20})
    var miner = Person.new("Miner", "gold miner", {"money": 100})
    var collector = Person.new("Collector", "water collector", {"water": 50, "money": 30})
    
    _demesne.add_person(farmer1)
    _demesne.add_person(farmer2)
    _demesne.add_person(miner)
    _demesne.add_person(collector)
    
    _sim.resolve_turn()
    
    # Check that resources were exchanged
    assert_true(
        miner.stockpile["grain"] > 0,
        "Miner should have bought grain"
    )
    assert_true(
        farmer1.stockpile["water"] > 0 or farmer2.stockpile["water"] > 0,
        "At least one farmer should have bought water"
    )

func _calculate_total_money() -> float:
    var total = float(_demesne.stockpile.get("money", 0))
    for person in _demesne.get_people():
        total += float(person.stockpile.get("money", 0))
    return total 