## A person in the simulation that can produce and consume goods
##
## Person nodes must always be instantiated using the constructor:
##   Person.new(f_name: String, job: String, starting_goods: Dictionary)
## The job must never be empty or null. This is validated in _ready().
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
var consumer: ComponentConsumer

#endregion


#region FUNCS
func _init(f_name_: String, job_: String, starting_goods: Dictionary) -> void:
	f_name = f_name_
	job = job_

	# Initialise stockpile with all possible goods set to 0
	for good in Library.get_all_goods_data():
		stockpile[good.id] = 0

	# Override with starting goods if provided
	for good in starting_goods:
		stockpile[good] = starting_goods[good]

	consumer = ComponentConsumer.new(f_name, stockpile)

func _ready() -> void:
	## Validates that the job is set and not empty. Logs an error if not.
	assert(job != null and job != "", "Person initialised without a job. This is not allowed.")
	if job == null or job == "":
		Logger.log_event("person_job_invalid", {
			"f_name": f_name,
			"error": "Person initialised without a job. This is not allowed."
		}, "Person")

func produce() -> void:
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
				"amount": 5
			}, "Person")

		_:
			Logger.log_event("no_production_for_job", {
				"name": f_name,
				"job": job
			}, "Person")

func consume() -> void:
	var result = consumer.consume()
	if result.success:
		if result.type == "desired":
			happiness += result.rule.desired_consumption_happiness_increase
			Logger.log_state_change("happiness", result.rule.desired_consumption_happiness_increase, happiness, "Person")
		else:
			happiness += 1
			Logger.log_state_change("happiness", 1, happiness, "Person")
		return
	# If consumption failed
	if result.type == "failure" and result.rule:
		health -= result.rule.consumption_failure_cost
		Logger.log_state_change("health", -result.rule.consumption_failure_cost, health, "Person")
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
	var goods_to_sell: Dictionary = {}

	# determine all goods above threshold
	for rule in Library.get_all_consumption_rules():
		var good_id = rule.good_id
		if stockpile[good_id] > rule.amount_to_hold_before_selling:
			goods_to_sell[good_id] = stockpile[good_id] - rule.amount_to_hold_before_selling

	return goods_to_sell

func get_goods_to_buy() -> Dictionary:
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

	return goods_to_buy

static func from_data_person(data_person: DataPerson, starting_goods: Dictionary = {}) -> Person:
	## Creates a Person node from a DataPerson data class.
	## Args:
	##   data_person (DataPerson): The data class instance to convert.
	##   starting_goods (Dictionary): The starting goods for the person.
	## Returns:
	##   Person: A new Person node with fields mapped from the DataPerson.
	var job = data_person.needs.get("job", "unemployed") if data_person.needs.has("job") else "unemployed"
	var goods_dict = starting_goods.duplicate() if starting_goods.size() > 0 else {"money": data_person.disposable_income}
	var person = Person.new(data_person.f_name, job, goods_dict)
	# Optionally, map other needs or fields as required
	return person

#endregion
