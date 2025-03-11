## class desc
#@icon("")
class_name Person
extends Node


#region SIGNALS

#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
# @export_group("Details")
#endregion


#region VARS
var health: int = 3
var required_grain: int = 1
var required_water: int = 2
var job: String = ""
var stockpile: Dictionary = {}
var is_alive: bool = true
var no_grain_damage: int = 1
var no_water_damage: int = 1
#endregion


#region FUNCS
func _init(job_: String, starting_goods: Dictionary) -> void:
	job = job_

	# add values from starting goods
	for good in starting_goods:
		stockpile[good] = starting_goods[good]

func produce() -> void:
	match job:
		"farmer":
			stockpile["grain"] += 10

		"water collector":
			stockpile["water"] += 20

		_:
			pass

func consume() -> void:
	if stockpile["grain"] >= required_grain:
		stockpile["grain"] -= required_grain
	else:
		stockpile["grain"] = 0
		health -= no_grain_damage

	if health <= 0:
		is_alive = false
		return

	if stockpile["water"] >= required_water:
		stockpile["water"] -= required_water
	else:
		stockpile["water"] = 0
		health -= no_water_damage

	if health <= 0:
		is_alive = false

func get_goods_for_sale() -> Dictionary:
	var goods_to_sell: Dictionary = {}
	# determine all goods above threshold
	for good in stockpile:
		if stockpile[good] > Constants.NEED_TO_BUY_FLOOR:
			goods_to_sell[good] = stockpile[good] - Constants.NEED_TO_BUY_FLOOR

	return goods_to_sell







#endregion
