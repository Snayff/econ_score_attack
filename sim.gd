## class desc
#@icon("")
class_name Sim
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
var people: Array[Person]

#endregion


#region FUNCS
func _ready() -> void:
	EventBus.turn_complete.connect(resolve_turn)

	_create_people()

func _create_people() -> void:
	var num_people: int = 3
	var job_allocation: Dictionary = {
		"farmer": 1,
		"water collector": 1,
	}
	var starting_goods: Dictionary = {
		"money": 100,
		"grain": 3,
		"water": 3,
		"wood": 0,
	}

	# put job allocation into an array
	var jobs: Array[String] = []
	if job_allocation.size() < num_people:
		job_allocation["none"] = num_people - job_allocation.size()
	for key in job_allocation:
		jobs.append(key)

	# assign job and starting goods
	for i in range(num_people):
		people.append(Person.new(jobs[i], starting_goods))

func resolve_turn() -> void:
	var saleable_goods: Dictionary = {}  # { good: { person: { amount: 123, money_made: 123 } } }
	var desired_goods: Dictionary = {}  # { good: { person: { amount: 123 } } }
	
	# simulate each person's turn
	for person in people:
		if !person.is_alive:
			continue

		# produce and consume
		person.produce()
		person.consume()

		# get goods would sell, based on what is left
		var goods_to_sell: Dictionary = person.get_goods_for_sale()
		for good in goods_to_sell:
			# init dict
			if good not in saleable_goods:
				saleable_goods[good] = {}

			# add person's good
			saleable_goods[good][person] = {
				"amount": goods_to_sell[good],
				"money_made": 0
			}

		# get goods would buy
		#var goods_to_buy: Dictionary = person.get_goods_to_buy()
		# TODO: add to desired_goods


	# TODO: loop desired_goods,
	#		look for desired_good in saleable_goods, remove desired # until saleable = 0











#endregion
