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
var happiness: int = 5
var job: String = ""
## goods held
var stockpile: Dictionary = {}
var goods_considered_sellable: Array = ["grain", "water"]
## goods to try and buy
var desired_goods: Array = ["grain", "water"]
## max grain desired to hold in stockpile
var max_desired_grain: int = 10
## max water desired to hold in stockpile
var max_desired_water: int = 20
## amount of grain needed each turn to survive
var required_grain: int = 1
## amount of water needed each turn to survive
var required_water: int = 2
## reduction to health when grain need not met
var no_grain_damage: int = 1
## reduction to health when water need not met
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
				" ploughed the fields. ⬆️10🥪."
			))

		"water collector":
			stockpile["water"] += 20
			print(str(
				f_name, 
				" manned the well. ⬆️20💧."
			))
			
		"gold miner":
			stockpile["money"] += 5
			print(str(
				f_name, 
				" used their pick. ⬆️5🪙.",
			))
			
		"woodcutter":
			stockpile["wood"] += 10
			print(str(
				f_name, 
				" felled some trees. ⬆️10🪵.",
			))
			
		_:
			pass

func consume() -> void:
	if stockpile["grain"] >= required_grain:
		if stockpile["grain"] >= required_grain + 4:
			stockpile["grain"] -= required_grain + 2
			happiness += 2
			
			print(str(
				f_name,
				" ate heartily.",
				" ⬇️",
				required_grain + 2, 
				"🥪, ⬆️2🙂"
			))
			
		elif stockpile["grain"] >= required_grain + 2:
			stockpile["grain"] -= required_grain + 1
			happiness += 1
			
			print(str(
				f_name,
				" ate a good meal.",
				" ⬇️",
				required_grain + 1,
				"🥪, ⬆️1🙂"
			))
			
		else:
			stockpile["grain"] -= required_grain
			
			print(str(
				f_name,
				" ate a normal meal.",
				" ⬇️",
				required_grain,
				"🥪."
			))
			
	else:
		stockpile["grain"] = 0
		health -= no_grain_damage
		happiness -= 1
		
		print(str(
			f_name,
			" went hungry. ⬇️",
			no_grain_damage,
			"❤️, ⬇️1🙂"
		))

		if health <= 0:
			is_alive = false
			print(str(
				f_name,
				" died. "
			))
			return

	if stockpile["water"] >= required_water:
		if stockpile["water"] >= required_water + 10:
			stockpile["water"] -= required_water + 5
			happiness += 2
			
			print(str(
				f_name,
				" drank greedily.",
				" ⬇️",
				required_water + 5, 
				"💧, ⬆️2🙂"
			))
			
		elif stockpile["water"] >= required_water + 5:
			stockpile["water"] -= required_water + 2
			happiness += 1
			
			print(str(
				f_name,
				" slaked their thirst.",
				" ⬇️",
				required_water + 2,
				"💧, ⬆️1🙂"
			))
			
		else:
			stockpile["water"] -= required_water
			
			print(str(
				f_name,
				" wet their whistle.",
				" ⬇️",
				required_water,
				"💧."
			))
			
	else:
		stockpile["water"] = 0
		health -= no_water_damage
		happiness -= 1
		
		print(str(
			f_name,
			" remained thirsty. ⬇️",
			no_water_damage,
			"❤️, ⬇️1🙂"
		))
		
		if health <= 0:
			is_alive = false
			print(str(
				f_name,
				" died. "
			))
			return

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
