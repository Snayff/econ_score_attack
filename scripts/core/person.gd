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
var thoughts: Dictionary[String, GoodThoughts] = {}

#endregion


#region FUNCS
func _init(f_name_: String, job_: String, starting_goods: Dictionary) -> void:
	f_name = f_name_
	job = job_

	establish_initial_thoughts()
	
	# add values from starting goods
	for good in starting_goods:
		stockpile[good] = starting_goods[good]

func establish_initial_thoughts():
	var grain: GoodThoughts = GoodThoughts.new()
	grain.good_id = "grain"
	grain.consumption_required = 1
	grain.consumption_desired = 2
	grain.requirement_not_met_damage = 1
	grain.min_level_to_hold = 3
	grain.desire_threshold = 10
	
	thoughts[grain.good_id] = grain
	
	var water: GoodThoughts = GoodThoughts.new()
	water.good_id = "water"
	water.consumption_required = 2
	water.consumption_desired = 4
	water.requirement_not_met_damage = 1
	water.min_level_to_hold = 10
	water.desire_threshold = 20
	
	thoughts[water.good_id] = water
	

func produce() -> void:
	match job:
		"farmer":
			stockpile["grain"] += 10
			Logger.info(str(
				f_name, 
				" ploughed the fields. ⬆️10🥪."
			), "Person")

		"water collector":
			stockpile["water"] += 20
			Logger.info(str(
				f_name, 
				" manned the well. ⬆️20💧."
			), "Person")
			
		"gold miner":
			stockpile["money"] += 5
			Logger.info(str(
				f_name, 
				" used their pick. ⬆️5🪙.",
			), "Person")
			
		"woodcutter":
			stockpile["wood"] += 10
			Logger.info(str(
				f_name, 
				" felled some trees. ⬆️10🪵.",
			), "Person")
			
		_:
			pass

func consume() -> void:
	for thought in thoughts.values():
		# FIXME: this is bad as query a static value many times. 
		#	move to some sort of good info and pull from there.
		var icon: String = ""
		match thought.good_id:
			"grain":
				icon = "🥪"
			"water": 
				icon = "💧"
		
		# consume desired amount
		if stockpile[thought.good_id] > thought.desire_threshold:
			stockpile[thought.good_id] -= thought.consumption_desired
			happiness += 2
			
			print(str(
				f_name,
				" consumed ",
				thought.good_id,
				" to their heart's desire. ⬇️",
				thought.consumption_desired, 
				icon,
				", ⬆️2🙂"
			))
		
		# consume required amount
		elif stockpile[thought.good_id] >= thought.consumption_required:
			stockpile[thought.good_id] -= thought.consumption_required
			happiness += 1
			
			print(str(
				f_name,
				" consumed what they needed of ",
				thought.good_id,
				". ⬇️",
				thought.consumption_required, 
				icon,
				", ⬆️1🙂"
			))
		# handle lack of good
		else:
			health -= thought.requirement_not_met_damage
			happiness -= 1
		
			print(str(
				f_name,
				" lacked ",
				thought.consumption_required,
				icon, 
				". ⬇️",
				thought.requirement_not_met_damage,
				"❤️, ⬇️1🙂"
			))
			
			# check if dead and update
			if health <= 0:
				is_alive = false
				print(str(
					f_name,
					" died. "
				))
				return

func get_goods_for_sale() -> Dictionary:
	var goods_to_sell: Dictionary = {}
	
	# TODO: this will need to be changed so that the person only sells down to required-level
	#	*if* they cannot afford to get all required goods up to requirement-level.
	
	# determine all goods above threshold
	for thought in thoughts.values():
		
		if stockpile[thought.good_id] > thought.min_level_to_hold:
			goods_to_sell[thought.good_id] = stockpile[thought.good_id] - thought.min_level_to_hold

	return goods_to_sell

func get_goods_to_buy() -> Dictionary:
	var goods_to_buy: Dictionary = {}
	
	# determine all goods above threshold
	for thought in thoughts.values():
		
		# we already have enough, dont buy more
		if stockpile[thought.good_id] > thought.desire_threshold:
			continue
			
		else:
			
			# TODO: need to prevent spanking all money on 1 required good, leading to abundance, 
			# 	when that leaves another required good short
			
			var amount_to_buy = max(0, thought.desire_threshold - stockpile[thought.good_id])
			if amount_to_buy != 0:
				goods_to_buy[thought.good_id] = amount_to_buy
		
	return goods_to_buy
			



#endregion
