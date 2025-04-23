## class desc
#@icon("")
class_name Person
extends Node

const ComponentConsumer = preload("res://scripts/actors/actor_components/component_consumer.gd")

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
var consumer: ComponentConsumer

#endregion


#region FUNCS
func _init(f_name_: String, job_: String, starting_goods: Dictionary) -> void:
	Logger.debug("Person: Creating " + f_name_ + " as " + job_, "Person")
	f_name = f_name_
	job = job_

	# add values from starting goods
	for good in starting_goods:
		stockpile[good] = starting_goods[good]
		Logger.debug("Person: " + f_name + " starts with " + str(starting_goods[good]) + " " + good, "Person")

	consumer = ComponentConsumer.new(f_name, stockpile)

func produce() -> void:
	Logger.debug("Person: " + f_name + " producing as " + job, "Person")
	match job:
		"farmer":
			stockpile["grain"] += 10
			Logger.debug(str(
				f_name,
				" ploughed the fields. ⬆️10🥪."
			), "Person")

		"water collector":
			stockpile["water"] += 20
			Logger.debug(str(
				f_name,
				" manned the well. ⬆️20💧."
			), "Person")

		"gold miner":
			stockpile["money"] += 5
			Logger.debug(str(
				f_name,
				" used their pick. ⬆️5🪙.",
			), "Person")

		"woodcutter":
			stockpile["wood"] += 10
			Logger.debug(str(
				f_name,
				" felled some trees. ⬆️10🪵.",
			), "Person")

		"bureaucrat":
			# Bureaucrats produce bureaucracy for the demesne, not for themselves
			# This will be handled by the demesne
			Logger.debug(str(
				f_name,
				" filed some paperwork. ⬆️5📋 for the demesne.",
			), "Person")

		_:
			pass

func consume() -> void:
	Logger.debug("Person: " + f_name + " consuming goods", "Person")
	if consumer.consume():
		# Find the rule that was used for consumption
		for rule in Library.get_all_consumption_rules():
			if stockpile[rule.good_id] < rule.min_consumption_amount:
				continue
			if stockpile[rule.good_id] >= rule.min_held_before_desired_consumption:
				happiness += rule.desired_consumption_happiness_increase
				Logger.debug(str(f_name, " is happy with their consumption. ⬆️", rule.desired_consumption_happiness_increase, "🙂"), "Person")
			else:
				happiness += 1
				Logger.debug(str(f_name, " is satisfied with their consumption. ⬆️1🙂"), "Person")
			break
	else:
		# Find the rule that failed
		for rule in Library.get_all_consumption_rules():
			if stockpile[rule.good_id] < rule.min_consumption_amount:
				health -= rule.consumption_failure_cost
				Logger.debug(str(f_name, " is unhappy with their consumption. ⬇️", rule.consumption_failure_cost, "❤️"), "Person")
				break

		if health <= 0:
			is_alive = false
			Logger.debug(str(f_name, " died from lack of goods."), "Person")

func get_goods_for_sale() -> Dictionary:
	Logger.debug("Person: " + f_name + " calculating goods for sale", "Person")
	var goods_to_sell: Dictionary = {}

	# determine all goods above threshold
	for rule in Library.get_all_consumption_rules():
		var good_id = rule.good_id
		if stockpile[good_id] > rule.amount_to_hold_before_selling:
			goods_to_sell[good_id] = stockpile[good_id] - rule.amount_to_hold_before_selling
			Logger.debug("Person: " + f_name + " will sell " + str(goods_to_sell[good_id]) + " " + good_id, "Person")

	return goods_to_sell

func get_goods_to_buy() -> Dictionary:
	Logger.debug("Person: " + f_name + " calculating goods to buy", "Person")
	var goods_to_buy: Dictionary = {}

	# determine all goods above threshold
	for rule in Library.get_all_consumption_rules():
		var good_id = rule.good_id
		# we already have enough, dont buy more
		if stockpile[good_id] > rule.amount_to_hold_before_selling:
			continue
		else:
			var amount_to_buy = max(0, rule.amount_to_hold_before_selling - stockpile[good_id])
			if amount_to_buy != 0:
				goods_to_buy[good_id] = amount_to_buy
				Logger.debug("Person: " + f_name + " needs to buy " + str(amount_to_buy) + " " + good_id, "Person")

	return goods_to_buy




#endregion
