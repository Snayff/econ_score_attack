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
var good_prices: Dictionary = {
	"grain": 10,
	"water": 10,
	"wood": 20,
}

#endregion


#region FUNCS
func _ready() -> void:
	EventBus.turn_complete.connect(resolve_turn)

	_create_people()

func _create_people() -> void:
	var num_people: int = 3
	var names: Array = [
		"sally", 
		"reginald",
		"estaban"
	]
	var job_allocation: Dictionary = {
		"farmer": 1,
		"water collector": 1,
		"woodcutter": 1,
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
		people.append(Person.new(names[i], jobs[i], starting_goods))

func resolve_turn() -> void:
	var saleable_goods: Dictionary = {}  # { good: { person: { amount: 123, money_made: 123 } } }
	var desired_goods: Dictionary = {}  # { good: { person: { amount: 123 } } }
	
	# logging stuff
	var supply: Dictionary = {}  # {name: { good: amount } }
	var demand: Dictionary = {}  # {name: { good: amount } }
	
	print(">>> Production & Consumption Phase")
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
			
			# update supply for logging
			if person.f_name not in supply:
				supply[person.f_name] = {}
			supply[person.f_name][good] = goods_to_sell[good]

		# get goods people want to buy
		var goods_to_buy: Dictionary = person.get_goods_to_buy()
		for good in goods_to_buy:
			if good not in desired_goods:
				desired_goods[good] = {}
				
			desired_goods[good][person] = goods_to_buy[good]
			
			# update demand for logging
			if person.f_name not in demand:
				demand[person.f_name] = {}
			demand[person.f_name][good] = goods_to_buy[good]
			
	print(">>> Market Setup")
	print(str(
		"Supply: ",
		supply,
		"\nDemand: ", 
		demand
	))

	# conduct sale
	print(">>> Market Opens")
	var purchasers: Array = []
	var amount_to_buy: int = 0
	var sellers: Array = []
	var saleable_remaining: int = 0
	var log_message: String = ""
	
	for good in saleable_goods:
		# no buyers, move on
		if good not in desired_goods:
			continue
		
		# get sellers and randomise order
		sellers = saleable_goods[good].keys()
		sellers.shuffle()
		
		# loop sellers of the good, pick a buyer at random and let them buy
		# all that they want
		for seller in sellers:
			var amount_to_sell: int = saleable_goods[good][seller]["amount"]
			
			# people who want to buy the good in question
			purchasers = desired_goods[good].keys()
			purchasers.shuffle()
			
			for buyer in purchasers:
				log_message = ""
				
				# make purchase
				amount_to_buy = min(floor(buyer.stockpile["money"] / good_prices[good]), desired_goods[good][buyer])
				var cost = good_prices[good] * amount_to_buy
				buyer.stockpile["money"] -= cost
				seller.stockpile["money"] += cost
				
				# buyer doesnt want anything, move to next buyer
				if amount_to_buy == 0:
					continue
				
				# add to buyers stockpile
				if good not in buyer.stockpile:
					buyer.stockpile[good] = 0
				buyer.stockpile[good] += amount_to_buy
				seller.stockpile[good] -= amount_to_buy
				
				# update desired good and purchasers
				desired_goods[good][buyer] -= amount_to_buy
				if desired_goods[good][buyer] <= 0:
					desired_goods[good].erase(buyer)
				
				# update remaining
				var goods_left: int = max(0, amount_to_sell - amount_to_buy)
				saleable_goods[good][seller]["amount"] = goods_left
				saleable_goods[good][seller]["money_made"] += cost
				
				log_message = str(
					seller.f_name,
					" sold ",
					amount_to_buy, 
					" ",
					good,
					" to ",
					buyer.f_name,
					" for 🪙", 
					cost, 
					" (",
					good_prices[good], 
					"🪙 each).",
				)
				print(log_message)
				
				# seller has stock remaining, find new buyer
				if goods_left > 0:
					continue
				
				# sellers stock is empty, find new seller
				elif goods_left == 0:
					break
				
	print(">>> Market Closes")
	var results: Dictionary = {}
	# var saleable_goods: Dictionary = {}  # { good: { person: { amount: 123, money_made: 123 } } }
	for good in saleable_goods.keys():
		for seller in saleable_goods[good]:
			if seller.f_name not in results:
				results[seller.f_name] = 0
			results[seller.f_name] += saleable_goods[good][seller]["money_made"]
	print(str(
		"Sales: ",
		results
	))

	print(">>> Turn Resolved >>>>>>>>>>>>>>>>>>>>")

#endregion
