## Unit tests for DataGood
## Last Updated: 2025-05-05
extends Node

const DataGood = preload("../../data_class/data_good.gd")

var _test_good: DataGood

func _ready() -> void:
	test_constructor()
	test_json_loading()

func test_constructor() -> void:
	_test_good = DataGood.new("food", "Food", 10.0, "basic", "")
	assert(_test_good.id == "food")
	assert(_test_good.f_name == "Food")
	assert(_test_good.base_price == 10.0)
	assert(_test_good.category == "basic")

func test_json_loading() -> void:
	var goods = Library.get_all_goods_data()
	assert(typeof(goods) == TYPE_ARRAY)
	assert(goods.size() > 0)
	for good in goods:
		assert(good is DataGood) 