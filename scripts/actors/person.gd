## A person in the simulation that can produce and consume goods
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
	Logger.log_event("person_created", {
		"name": f_name_,
		"job": job_,
		"starting_goods": starting_goods,
		"initial_health": health,
		"initial_happiness": happiness
	}, "Person")
	f_name = f_name_
	job = job_

	# add values from starting goods
	for good in starting_goods:
		stockpile[good] = starting_goods[good]
		Logger.log_resource_change(good, starting_goods[good], starting_goods[good], "Person")

	consumer = ComponentConsumer.new(f_name, stockpile)

func produce() -> void:
	Logger.log_event("production_started", {
		"name": f_name,
		"job": job,
		"current_health": health,
		"current_happiness": happiness
	}, "Person")
	match job:
		"farmer":
			stockpile["grain"] += 10
			Logger.log_resource_change("grain", 10, stockpile["grain"], "Person")

		"water collector":
			stockpile["water"] += 20
			Logger.log_resource_change("water", 20, stockpile["water"], "Person")

		"gold miner":
			stockpile["money"] += 5
			Logger.log_money_change(5, stockpile["money"], "Person")

		"woodcutter":
			stockpile["wood"] += 10
			Logger.log_resource_change("wood", 10, stockpile["wood"], "Person")

		"bureaucrat":
			# Bureaucrats produce bureaucracy for the demesne, not for themselves
			Logger.log_event("bureaucracy_produced", {
				"name": f_name,
				"amount": 5,
				"current_health": health,
				"current_happiness": happiness
			}, "Person")

		_:
			Logger.log_event("no_production_for_job", {
				"name": f_name,
				"job": job
			}, "Person")

func consume() -> void:
	Logger.log_event("consumption_started", {
		"name": f_name,
		"current_health": health,
		"current_happiness": happiness,
		"current_stockpile": stockpile
	}, "Person")

	if consumer.consume():
		# Find the rule that was used for consumption
		for rule in Library.get_all_consumption_rules():
			if stockpile[rule.good_id] < rule.min_consumption_amount:
				continue
			if stockpile[rule.good_id] >= rule.min_held_before_desired_consumption:
				happiness += rule.desired_consumption_happiness_increase
				Logger.log_state_change("happiness", rule.desired_consumption_happiness_increase, happiness, "Person")
				Logger.log_event("desired_consumption_completed", {
					"name": f_name,
					"good": rule.good_id,
					"happiness_increase": rule.desired_consumption_happiness_increase,
					"new_happiness": happiness
				}, "Person")
			else:
				happiness += 1
				Logger.log_state_change("happiness", 1, happiness, "Person")
				Logger.log_event("minimum_consumption_completed", {
					"name": f_name,
					"good": rule.good_id,
					"happiness_increase": 1,
					"new_happiness": happiness
				}, "Person")
			break
	else:
		# Find the rule that failed
		for rule in Library.get_all_consumption_rules():
			if stockpile[rule.good_id] < rule.min_consumption_amount:
				health -= rule.consumption_failure_cost
				Logger.log_state_change("health", -rule.consumption_failure_cost, health, "Person")
				Logger.log_event("consumption_failed", {
					"name": f_name,
					"good": rule.good_id,
					"health_decrease": rule.consumption_failure_cost,
					"new_health": health,
					"current_happiness": happiness
				}, "Person")
				break

		if health <= 0:
			is_alive = false
			Logger.log_event("person_died", {
				"name": f_name,
				"cause": "lack_of_goods",
				"final_health": health,
				"final_happiness": happiness,
				"final_stockpile": stockpile
			}, "Person")

func get_goods_for_sale() -> Dictionary:
	Logger.log_event("calculating_goods_for_sale", {
		"name": f_name,
		"current_stockpile": stockpile
	}, "Person")
	var goods_to_sell: Dictionary = {}

	# determine all goods above threshold
	for rule in Library.get_all_consumption_rules():
		var good_id = rule.good_id
		if stockpile[good_id] > rule.amount_to_hold_before_selling:
			goods_to_sell[good_id] = stockpile[good_id] - rule.amount_to_hold_before_selling
			Logger.log_event("goods_marked_for_sale", {
				"name": f_name,
				"good": good_id,
				"amount": goods_to_sell[good_id],
				"threshold": rule.amount_to_hold_before_selling,
				"current_stockpile": stockpile[good_id]
			}, "Person")

	return goods_to_sell

func get_goods_to_buy() -> Dictionary:
	Logger.log_event("calculating_goods_to_buy", {
		"name": f_name,
		"current_stockpile": stockpile
	}, "Person")
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
				Logger.log_event("goods_marked_for_purchase", {
					"name": f_name,
					"good": good_id,
					"amount": amount_to_buy,
					"threshold": rule.amount_to_hold_before_selling,
					"current_stockpile": stockpile[good_id]
				}, "Person")

	return goods_to_buy

#endregion
