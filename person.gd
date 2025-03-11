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
var f_name: String = ""
var is_alive: bool = true
var health: int = 3
var job: String = ""
## goods held
var stockpile: Dictionary = {}
var goods_considered_sellable: Array = ["grain", "water"]
## goods to try and buy
var desired_goods: Array = ["grain", "water"]
var required_grain: int = 1
var required_water: int = 2
var no_grain_damage: int = 1
var no_water_damage: int = 1
#endregion


#region FUNCS
func _init(f_name_: String, job_: String, starting_goods: Dictionary) -> void:
	f_name = f_name_
	job = job_

	# add values from starting goods
	for good in starting_goods:
		stockpile[good] = starting_goods[good]

func produce() -> void:
	match job:
		"farmer":
			stockpile["grain"] += 10
			print(str(
				f_name, 
				" produced 10 grain."
			))

		"water collector":
			stockpile["water"] += 20
			print(str(
				f_name, 
				" produced 20 water."
			))
			
		"gold miner":
			stockpile["money"] += 5
			print(str(
				f_name, 
				" produced 🪙5.",
			))
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
	for good in goods_considered_sellable:
		if stockpile[good] > Constants.NEED_TO_BUY_FLOOR:
			goods_to_sell[good] = stockpile[good] - Constants.NEED_TO_BUY_FLOOR

	return goods_to_sell

func get_goods_to_buy() -> Dictionary:
	var goods_to_buy: Dictionary = {}
	
	for good in desired_goods:
		# if we have 0, buy up to the buy-floor
		if good not in stockpile:
			goods_to_buy[good] = Constants.NEED_TO_BUY_FLOOR
		
		else:
			var amount_to_buy = max(0, Constants.NEED_TO_BUY_FLOOR - stockpile[good])
			if amount_to_buy != 0:
				goods_to_buy[good] = amount_to_buy
		
	return goods_to_buy
			
	




#endregion
